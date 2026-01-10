#!/usr/bin/env python3

import os
import sys
import json
import base64
import hashlib
import subprocess
import argparse
import requests
import mimetypes
from pathlib import Path
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.backends import default_backend

class ClipshareClient:
    def __init__(self, url=None, password=None, max_size=None):
        self.url = url or os.getenv('CLIPSHARE_URL', 'https://clipshare.ai6media.site')
        self.password = password or os.getenv('CLIPSHARE_PASSWORD')
        self.max_size = max_size or int(os.getenv('MAX_SIZE', 10 * 1024 * 1024))  # 10MB default
        
        if not self.password:
            raise ValueError("Password required: set CLIPSHARE_PASSWORD environment variable")
        
        self.clipboard_id = self._calculate_clipboard_id(self.password)
    
    def _calculate_clipboard_id(self, password: str) -> str:
        """Calculate clipboard ID using the same method as Android client"""
        salt = "clipshare"
        salted_password = f"{salt}{password}"
        return hashlib.sha256(salted_password.encode()).hexdigest()
    
    def _derive_key(self, password: str, salt: bytes) -> bytes:
        """Derive encryption key using PBKDF2 - same as Android"""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,  # 256 bits
            salt=salt,
            iterations=100000,
            backend=default_backend()
        )
        return kdf.derive(password.encode())
    
    def _encrypt(self, data: bytes, password: str) -> str:
        """Encrypt binary data using AES-GCM - compatible with Android"""
        # Generate 16-byte salt
        salt = os.urandom(16)
        
        # Derive key using PBKDF2
        key = self._derive_key(password, salt)
        
        # Generate 12-byte nonce for GCM
        nonce = os.urandom(12)
        
        # Encrypt with AES-GCM
        aesgcm = AESGCM(key)
        encrypted_data = aesgcm.encrypt(nonce, data, None)
        
        # Combine salt + nonce + encrypted_data
        result = salt + nonce + encrypted_data
        
        # Base64 encode
        return base64.b64encode(result).decode('ascii')
    
    def _decrypt(self, encrypted_data: str, password: str) -> bytes:
        """Decrypt data using AES-GCM - compatible with Android"""
        # Decode base64
        data = base64.b64decode(encrypted_data)
        
        # Extract components
        salt = data[:16]
        nonce = data[16:28]
        encrypted = data[28:]
        
        # Derive key
        key = self._derive_key(password, salt)
        
        # Decrypt with AES-GCM
        aesgcm = AESGCM(key)
        decrypted_data = aesgcm.decrypt(nonce, encrypted, None)
        
        return decrypted_data
    
    def _get_clipboard_types(self) -> list:
        """Get available clipboard MIME types"""
        try:
            # Try wl-paste (Wayland)
            result = subprocess.run(['wl-paste', '-l'], 
                                  capture_output=True, 
                                  text=True, 
                                  check=True)
            return [t.strip() for t in result.stdout.strip().split('\n') if t.strip()]
        except (subprocess.CalledProcessError, FileNotFoundError):
            try:
                # Try xclip (X11) - get available targets
                result = subprocess.run(['xclip', '-o', '-t', 'TARGETS', '-selection', 'clipboard'], 
                                      capture_output=True, 
                                      text=True, 
                                      check=True)
                return [t.strip() for t in result.stdout.strip().split('\n') if t.strip()]
            except (subprocess.CalledProcessError, FileNotFoundError):
                return []
    
    def _resolve_uri_content(self, uri_content: str) -> tuple:
        """Convert URI content to actual file content if needed"""
        lines = uri_content.strip().split('\n')
        
        # Handle file:// URIs
        for line in lines:
            if line.startswith('file://'):
                file_path = line[7:]  # Remove 'file://' prefix
                try:
                    path = Path(file_path)
                    if path.exists() and path.is_file():
                        # Check if it's a directory
                        if path.is_dir():
                            self._notify("✗ Error: Cannot send directory")
                            return None, None
                        
                        # Read file content
                        with open(path, 'rb') as f:
                            content = f.read()
                        
                        # Guess MIME type
                        mime_type, _ = mimetypes.guess_type(str(path))
                        if not mime_type:
                            mime_type = 'application/octet-stream'
                        
                        print(f"Debug: Resolved URI to file: {path} ({mime_type}, {len(content)} bytes)")
                        return content, mime_type
                except Exception as e:
                    print(f"Debug: Failed to read file {file_path}: {e}")
        
        # If not a resolvable URI, return as text
        return uri_content.encode('utf-8'), 'text/plain'
    
    def _get_clipboard_content(self) -> tuple:
        """Get content from system clipboard, returns (data, mime_type)"""
        types = self._get_clipboard_types()
        
        if not types:
            raise RuntimeError("Clipboard appears to be empty")
        
        print(f"Debug: Available clipboard types: {types}")
        
        # Check if clipboard contains URI list and resolve it
        if "text/uri-list" in types:
            try:
                if self._is_wayland():
                    # Get URI content first
                    result = subprocess.run(['wl-paste', '-t', 'text/uri-list'], 
                                          capture_output=True, 
                                          text=True, 
                                          check=True)
                    uri_content = result.stdout
                    
                    # Try to resolve URI to actual content
                    resolved_content, resolved_type = self._resolve_uri_content(uri_content)
                    if resolved_content is not None:
                        # Copy resolved content back to clipboard for consistency
                        subprocess.run(['wl-copy', '--type', resolved_type], 
                                     input=resolved_content, 
                                     check=True)
                        return resolved_content, resolved_type
                else:
                    # X11 - similar approach with xclip
                    result = subprocess.run(['xclip', '-o', '-t', 'text/uri-list', '-selection', 'clipboard'], 
                                          capture_output=True, 
                                          text=True, 
                                          check=True)
                    uri_content = result.stdout
                    
                    resolved_content, resolved_type = self._resolve_uri_content(uri_content)
                    if resolved_content is not None:
                        subprocess.run(['xclip', '-t', resolved_type, '-selection', 'clipboard'], 
                                     input=resolved_content, 
                                     check=True)
                        return resolved_content, resolved_type
            except Exception as e:
                print(f"Debug: URI resolution failed: {e}")
        
        # Determine best content type to retrieve
        preferred_types = [
            'image/png', 'image/jpeg', 'image/gif', 'image/bmp', 'image/svg+xml',
            'text/html', 'text/plain', 'text/uri-list'
        ]
        
        chosen_type = None
        for pref_type in preferred_types:
            if pref_type in types:
                chosen_type = pref_type
                break
        
        if not chosen_type:
            # Default to first available type
            chosen_type = types[0]
        
        print(f"Debug: Using clipboard type: {chosen_type}")
        
        try:
            if self._is_wayland():
                # Wayland - get content with specific type
                result = subprocess.run(['wl-paste', '-t', chosen_type], 
                                      capture_output=True, 
                                      check=True)
                content = result.stdout
            else:
                # X11 - get content with specific type
                result = subprocess.run(['xclip', '-o', '-t', chosen_type, '-selection', 'clipboard'], 
                                      capture_output=True, 
                                      check=True)
                content = result.stdout
            
            return content, chosen_type
            
        except subprocess.CalledProcessError:
            # Fallback to default clipboard content
            try:
                if self._is_wayland():
                    result = subprocess.run(['wl-paste'], 
                                          capture_output=True, 
                                          text=True, 
                                          check=True)
                    return result.stdout.encode('utf-8'), 'text/plain'
                else:
                    result = subprocess.run(['xclip', '-o', '-selection', 'clipboard'], 
                                          capture_output=True, 
                                          text=True, 
                                          check=True)
                    return result.stdout.encode('utf-8'), 'text/plain'
            except subprocess.CalledProcessError:
                raise RuntimeError("Failed to get clipboard content")
    
    def _is_wayland(self) -> bool:
        """Check if running under Wayland"""
        return 'WAYLAND_DISPLAY' in os.environ or 'wl-paste' in str(subprocess.run(['which', 'wl-paste'], capture_output=True))
    
    def _set_clipboard_content(self, content: bytes, mime_type: str):
        """Set system clipboard content with proper MIME type"""
        try:
            if self._is_wayland():
                # Wayland - set content with MIME type
                if mime_type.startswith('text/'):
                    # For text content, use text mode
                    subprocess.run(['wl-copy', '--type', mime_type], 
                                 input=content.decode('utf-8'), 
                                 text=True, 
                                 check=True)
                else:
                    # For binary content, use binary mode
                    subprocess.run(['wl-copy', '--type', mime_type], 
                                 input=content, 
                                 check=True)
            else:
                # X11 - set content with MIME type
                if mime_type.startswith('text/'):
                    subprocess.run(['xclip', '-t', mime_type, '-selection', 'clipboard'], 
                                 input=content.decode('utf-8'), 
                                 text=True, 
                                 check=True)
                else:
                    subprocess.run(['xclip', '-t', mime_type, '-selection', 'clipboard'], 
                                 input=content, 
                                 check=True)
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to set clipboard content: {e}")
    
    def _notify(self, message: str):
        """Send desktop notification"""
        try:
            subprocess.run(['notify-send', 'Clipshare', message, '-t', '3000'], 
                         check=False)
        except FileNotFoundError:
            print(f"Clipshare: {message}")
    
    def send_clipboard(self):
        """Send clipboard content to server"""
        try:
            # Get clipboard content with MIME type
            clipboard_data, mime_type = self._get_clipboard_content()
            
            if not clipboard_data:
                self._notify("✗ Error: Clipboard is empty")
                return False
            
            content_size = len(clipboard_data)
            print(f"Debug: Original clipboard content size: {content_size} bytes ({mime_type})")
            
            # Check size limit
            if content_size > self.max_size:
                self._notify(f"✗ Error: Content too large ({content_size} bytes, max {self.max_size})")
                return False
            
            # Create content object with both data and metadata
            if mime_type.startswith('text/'):
                # For text content, store as text in JSON
                content_obj = {
                    "Text": clipboard_data.decode('utf-8'),
                    "MimeType": mime_type
                }
            else:
                # For binary content, store as base64 in JSON
                content_obj = {
                    "Data": base64.b64encode(clipboard_data).decode('ascii'),
                    "MimeType": mime_type
                }
            
            json_content = json.dumps(content_obj, ensure_ascii=False)
            json_bytes = json_content.encode('utf-8')
            
            print(f"Debug: JSON content size: {len(json_bytes)} bytes")
            
            # Encrypt content
            encrypted_content = self._encrypt(json_bytes, self.password)
            
            print(f"Debug: Encrypted content size: {len(encrypted_content)} chars")
            
            # Send to server
            response = requests.post(
                f"{self.url}/clipboard/{self.clipboard_id}",
                data=encrypted_content,
                headers={'Content-Type': 'application/octet-stream'},
                timeout=10
            )
            
            if response.status_code == 200:
                content_desc = f"{mime_type}" + (f" ({content_size}B)" if not mime_type.startswith('text/') else "")
                self._notify(f"✓ Clipboard sent successfully: {content_desc}")
                return True
            elif response.status_code == 400:
                self._notify("✗ Error: Invalid content or ID")
                return False
            elif response.status_code in [413, 429]:
                self._notify("✗ Error: Content too large or storage full")
                return False
            else:
                self._notify(f"✗ Error: Server returned {response.status_code}")
                return False
                
        except Exception as e:
            self._notify(f"✗ Error: {str(e)}")
            return False
    
    def receive_clipboard(self):
        """Receive clipboard content from server"""
        try:
            # Download content from server
            response = requests.get(
                f"{self.url}/clipboard/{self.clipboard_id}",
                timeout=10
            )
            
            if response.status_code == 200:
                encrypted_content = response.text
                
                print(f"Debug: Received encrypted content size: {len(encrypted_content)} chars")
                
                # Decrypt content
                decrypted_bytes = self._decrypt(encrypted_content, self.password)
                
                print(f"Debug: Decrypted content size: {len(decrypted_bytes)} bytes")
                
                # Parse JSON and extract content
                content_obj = json.loads(decrypted_bytes.decode('utf-8'))
                
                mime_type = content_obj.get("MimeType", "text/plain")
                
                if "Text" in content_obj:
                    # Text content
                    content_data = content_obj["Text"].encode('utf-8')
                    content_desc = "text"
                elif "Data" in content_obj:
                    # Binary content (base64 encoded)
                    content_data = base64.b64decode(content_obj["Data"])
                    content_desc = mime_type
                else:
                    # Legacy format - assume text
                    content_data = content_obj.get("Text", "").encode('utf-8')
                    content_desc = "text"
                
                # Set clipboard with proper MIME type
                self._set_clipboard_content(content_data, mime_type)
                
                self._notify(f"✓ Clipboard received: {content_desc} ({len(content_data)} bytes)")
                return True
                
            elif response.status_code == 404:
                self._notify("✗ No clipboard content found")
                return False
            elif response.status_code == 401:
                self._notify("✗ Error: Unauthorized clipboard ID")
                return False
            else:
                self._notify(f"✗ Error: Server returned {response.status_code}")
                return False
                
        except Exception as e:
            self._notify(f"✗ Error: {str(e)}")
            return False
    
    def test_encryption(self):
        """Test encryption/decryption round-trip"""
        test_data = "Hello, World! This is a test with special chars: áéíóú 🌟"
        test_bytes = test_data.encode('utf-8')
        
        print(f"Original: {test_data}")
        print(f"Original size: {len(test_bytes)} bytes")
        
        try:
            # Test encryption
            encrypted = self._encrypt(test_bytes, self.password)
            print(f"✓ Encryption successful")
            print(f"Encrypted size: {len(encrypted)} chars")
            
            # Test decryption
            decrypted_bytes = self._decrypt(encrypted, self.password)
            decrypted = decrypted_bytes.decode('utf-8')
            
            if decrypted == test_data:
                print("✓ Decryption successful")
                print("✓ Round-trip test PASSED")
                return True
            else:
                print("✗ Decryption failed - data mismatch")
                print(f"Expected: {test_data}")
                print(f"Got: {decrypted}")
                return False
                
        except Exception as e:
            print(f"✗ Encryption/decryption failed: {e}")
            return False

def check_dependencies():
    """Check if required dependencies are available"""
    missing = []
    
    # Check Python modules
    try:
        import cryptography
    except ImportError:
        missing.append("python3-cryptography")
    
    try:
        import requests
    except ImportError:
        missing.append("python3-requests")
    
    # Check clipboard tools
    clipboard_available = False
    try:
        subprocess.run(['wl-paste', '--version'], 
                      capture_output=True, check=True)
        clipboard_available = True
    except (subprocess.CalledProcessError, FileNotFoundError):
        try:
            subprocess.run(['xclip', '-version'], 
                          capture_output=True, check=True)
            clipboard_available = True
        except (subprocess.CalledProcessError, FileNotFoundError):
            pass
    
    if not clipboard_available:
        missing.append("wl-clipboard or xclip")
    
    if missing:
        print(f"✗ Missing dependencies: {', '.join(missing)}")
        print("\nInstall with:")
        if "python3-cryptography" in missing or "python3-requests" in missing:
            print("  pip3 install cryptography requests")
        if "wl-clipboard or xclip" in missing:
            print("  # On Ubuntu/Debian: sudo apt install wl-clipboard")
            print("  # On Arch: sudo pacman -S wl-clipboard")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Send/Receive encrypted clipboard content from clipshare server"
    )
    parser.add_argument('-s', '--send', action='store_true', 
                       help='Send clipboard content')
    parser.add_argument('-r', '--receive', action='store_true', 
                       help='Receive clipboard content')
    parser.add_argument('-t', '--test', action='store_true', 
                       help='Test encryption/decryption')
    parser.add_argument('--url', 
                       help='Server URL (default: env CLIPSHARE_URL)')
    parser.add_argument('--password', 
                       help='Password for encryption (default: env CLIPSHARE_PASSWORD)')
    parser.add_argument('--max-size', type=int,
                       help='Maximum content size in bytes (default: env MAX_SIZE or 10MB)')
    
    args = parser.parse_args()
    
    if not any([args.send, args.receive, args.test]):
        parser.print_help()
        sys.exit(1)
    
    # Check dependencies
    check_dependencies()
    
    try:
        client = ClipshareClient(args.url, args.password, args.max_size)
        
        if args.test:
            success = client.test_encryption()
            sys.exit(0 if success else 1)
        elif args.send:
            success = client.send_clipboard()
            sys.exit(0 if success else 1)
        elif args.receive:
            success = client.receive_clipboard()
            sys.exit(0 if success else 1)
            
    except ValueError as e:
        print(f"✗ Error: {e}")
        print("\nSet password with: export CLIPSHARE_PASSWORD='your_password'")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1) 

if __name__ == "__main__":
    main()
