#!/bin/bash

# Configuration
CLIPSHARE_URL="${CLIPSHARE_URL:-https://clipshare.ai6media.site}"
TEMP_DIR="${TEMP_DIR:-/tmp}"
PASSWORD="${CLIPSHARE_PASSWORD:-1234}"

# Check dependencies
check_dependencies() {
    local missing_deps=()
    local warnings=()
    
    if ! command -v openssl >/dev/null 2>&1; then
        missing_deps+=("openssl")
    fi
    
    if ! command -v wl-paste >/dev/null 2>&1; then
        missing_deps+=("wl-clipboard")
    fi
    
    if ! command -v base64 >/dev/null 2>&1; then
        missing_deps+=("base64")
    fi
    
    if ! command -v xxd >/dev/null 2>&1; then
        missing_deps+=("xxd")
    fi
    
    # Check for PBKDF2 support
    if command -v openssl >/dev/null 2>&1; then
        if ! openssl kdf -help 2>/dev/null | grep -q "PBKDF2"; then
            if ! command -v python3 >/dev/null 2>&1; then
                warnings+=("python3 (recommended for PBKDF2 - will use slower fallback)")
            fi
        fi
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        notify "✗ Error: Missing dependencies: ${missing_deps[*]}"
        echo "Please install: ${missing_deps[*]}"
        exit 1
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo "Warning: Consider installing: ${warnings[*]}"
    fi
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Clipshare" "$1" -t 3000
    else
        echo "Clipshare: $1"
    fi
}

# Calculate clipboard ID using the same method as Android
calculate_clipboard_id() {
    local password="$1"
    local salt="clipshare"
    local salted_password="${salt}${password}"
    
    echo -n "$salted_password" | openssl dgst -sha256 -hex | cut -d' ' -f2
}

# Generate random bytes
generate_random_bytes() {
    local count="$1"
    openssl rand -hex "$count" | xxd -r -p | base64 -w 0
}

# Derive key using PBKDF2
derive_key() {
    local password="$1"
    local salt_hex="$2"
    local iterations=100000
    local key_length=32
    
    # Try modern kdf command first
    if openssl kdf -help 2>/dev/null | grep -q "PBKDF2"; then
        local salt_binary=$(echo "$salt_hex" | xxd -r -p | base64 -w 0)
        echo -n "$password" | openssl kdf -keylen "$key_length" -kdfopt digest:SHA256 -kdfopt pass:stdin -kdfopt salt:"$salt_binary" -kdfopt iter:"$iterations" PBKDF2 | xxd -p -c 256
    else
        # Fallback: use Python if available
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import hashlib
import binascii
import sys

def pbkdf2(password, salt_hex, iterations, key_length):
    salt = binascii.unhexlify('$salt_hex')
    key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, $iterations, $key_length)
    return binascii.hexlify(key).decode()

password = sys.stdin.read().strip()
print(pbkdf2(password, '$salt_hex', $iterations, $key_length))
" <<< "$password"
        else
            # Last resort: manual PBKDF2 implementation with OpenSSL
            derive_key_manual "$password" "$salt_hex" "$iterations" "$key_length"
        fi
    fi
}

# Manual PBKDF2 implementation using OpenSSL HMAC
derive_key_manual() {
    local password="$1"
    local salt_hex="$2"
    local iterations="$3"
    local key_length="$4"
    
    local salt_binary=$(echo "$salt_hex" | xxd -r -p)
    local block_count=$(( (key_length + 31) / 32 ))  # SHA256 produces 32-byte blocks
    local derived_key=""
    
    for ((i=1; i<=block_count; i++)); do
        # Create salt + block number (big-endian 4 bytes)
        local block_num=$(printf "%08x" $i | xxd -r -p)
        local salt_block="${salt_binary}${block_num}"
        
        # First iteration: HMAC(password, salt || block_num)
        local prev_hash=$(echo -n "$salt_block" | openssl dgst -sha256 -hmac "$password" -binary | xxd -p -c 256)
        local xor_result="$prev_hash"
        
        # Remaining iterations
        for ((j=2; j<=iterations; j++)); do
            prev_hash=$(echo "$prev_hash" | xxd -r -p | openssl dgst -sha256 -hmac "$password" -binary | xxd -p -c 256)
            # XOR with previous result
            xor_result=$(printf "%064s" "$xor_result" | xxd -r -p | xxd -p -c 32)
            local temp_xor=""
            for ((k=0; k<64; k+=2)); do
                local byte1="0x${xor_result:$k:2}"
                local byte2="0x${prev_hash:$k:2}"
                local xor_byte=$(printf "%02x" $((byte1 ^ byte2)))
                temp_xor="${temp_xor}${xor_byte}"
            done
            xor_result="$temp_xor"
        done
        
        derived_key="${derived_key}${xor_result}"
    done
    
    # Truncate to desired length
    echo "${derived_key:0:$((key_length * 2))}"
}

# Encrypt data using AES-GCM (compatible with Android)
encrypt_data() {
    local data="$1"
    local password="$2"
    
    echo "Debug: Starting encryption of ${#data} bytes" >&2
    
    # Generate 16-byte salt
    local salt_b64=$(openssl rand -base64 16 | tr -d '\n')
    local salt_hex=$(echo "$salt_b64" | base64 -d | xxd -p -c 256)
    echo "Debug: Generated salt: $salt_hex" >&2
    
    # Derive key
    local key_hex=$(derive_key "$password" "$salt_hex")
    if [[ -z "$key_hex" ]]; then
        echo "Debug: Key derivation failed" >&2
        return 1
    fi
    echo "Debug: Derived key length: ${#key_hex} hex chars" >&2
    
    # Generate 12-byte IV for GCM
    local iv_b64=$(openssl rand -base64 12 | tr -d '\n')
    local iv_hex=$(echo "$iv_b64" | base64 -d | xxd -p -c 256)
    echo "Debug: Generated IV: $iv_hex" >&2
    
    # Create temporary files
    local temp_plaintext="$TEMP_DIR/clipshare_plaintext_$"
    local temp_encrypted="$TEMP_DIR/clipshare_encrypted_$"
    local temp_result="$TEMP_DIR/clipshare_result_$"
    
    # Write plaintext to file
    printf '%s' "$data" > "$temp_plaintext"
    
    # Check if AES-GCM is available, fallback to CBC if not
    if openssl enc -aes-256-gcm -help >/dev/null 2>&1; then
        echo "Debug: Using AES-GCM" >&2
        # OpenSSL AES-GCM encryption
        if ! openssl enc -aes-256-gcm -K "$key_hex" -iv "$iv_hex" -in "$temp_plaintext" -out "$temp_encrypted" 2>/dev/null; then
            echo "Debug: AES-GCM encryption failed" >&2
            rm -f "$temp_plaintext" "$temp_encrypted" "$temp_result"
            return 1
        fi
    else
        echo "Debug: AES-GCM not available, using CBC (less secure)" >&2
        # Fallback to CBC mode (less secure but more compatible)
        if ! openssl enc -aes-256-cbc -K "$key_hex" -iv "${iv_hex}00000000" -in "$temp_plaintext" -out "$temp_encrypted" 2>/dev/null; then
            echo "Debug: AES-CBC encryption failed" >&2
            rm -f "$temp_plaintext" "$temp_encrypted" "$temp_result"
            return 1
        fi
    fi
    
    local encrypted_file_size=$(wc -c < "$temp_encrypted" 2>/dev/null || echo 0)
    echo "Debug: Encrypted file size: $encrypted_file_size bytes" >&2
    
    # Combine salt + iv + encrypted_data
    {
        echo -n "$salt_b64" | base64 -d
        echo -n "$iv_b64" | base64 -d
        cat "$temp_encrypted"
    } > "$temp_result"
    
    # Base64 encode the result
    local result=$(base64 -w 0 < "$temp_result")
    local result_size=${#result}
    echo "Debug: Final base64 result size: $result_size chars" >&2
    
    # Cleanup
    rm -f "$temp_plaintext" "$temp_encrypted" "$temp_result"
    
    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    else
        echo "Debug: Encryption produced empty result" >&2
        return 1
    fi
}

# Decrypt data using AES-GCM (compatible with Android)
decrypt_data() {
    local encrypted_b64="$1"
    local password="$2"
    
    local temp_encrypted="$TEMP_DIR/clipshare_decrypt_$$"
    
    # Decode base64
    echo "$encrypted_b64" | base64 -d > "$temp_encrypted"
    
    # Extract components
    local salt_hex=$(dd if="$temp_encrypted" bs=1 count=16 2>/dev/null | xxd -p -c 256)
    local iv_hex=$(dd if="$temp_encrypted" bs=1 skip=16 count=12 2>/dev/null | xxd -p -c 256)
    
    # Extract encrypted data (skip first 28 bytes: 16 salt + 12 iv)
    local temp_cipher="$TEMP_DIR/clipshare_cipher_$$"
    dd if="$temp_encrypted" bs=1 skip=28 of="$temp_cipher" 2>/dev/null
    
    # Derive key
    local key_hex=$(derive_key "$password" "$salt_hex")
    
    # Decrypt
    local temp_decrypted="$TEMP_DIR/clipshare_decrypted_$$"
    if openssl enc -aes-256-gcm -d -K "$key_hex" -iv "$iv_hex" -in "$temp_cipher" -out "$temp_decrypted" 2>/dev/null; then
        local result=$(cat "$temp_decrypted")
        rm -f "$temp_encrypted" "$temp_cipher" "$temp_decrypted"
        echo "$result"
        return 0
    else
        rm -f "$temp_encrypted" "$temp_cipher" "$temp_decrypted"
        return 1
    fi
}

# Create JSON content (matching Android format)
create_json_content() {
    local text="$1"
    # Escape quotes and newlines for JSON
    local escaped_text=$(echo "$text" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    echo "{\"Text\":\"$escaped_text\"}"
}

# Parse JSON content
parse_json_content() {
    local json="$1"
    # Simple JSON parsing - extract Text field
    echo "$json" | sed -n 's/.*"Text":"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g' | sed 's/\\"/"/g' | sed 's/\\\\/\\/g'
}

send_content() {
    if [[ -z "$PASSWORD" ]]; then
        notify "✗ Error: CLIPSHARE_PASSWORD environment variable not set"
        exit 1
    fi
    
    local clipboard_content=""
    
    if command -v wl-paste >/dev/null 2>&1; then
        # Check if clipboard has content
        if ! wl-paste -l >/dev/null 2>&1; then
            notify "✗ Error: Clipboard is empty!"
            exit 1
        fi
        
        clipboard_content=$(wl-paste 2>/dev/null)
    else
        notify "✗ Error: wl-clipboard is not installed"
        exit 1
    fi
    
    if [[ -z "$clipboard_content" ]]; then
        notify "✗ Error: Clipboard is empty"
        exit 1
    fi
    
    # Debug: show original content size
    local original_size=${#clipboard_content}
    echo "Debug: Original clipboard content size: $original_size bytes"
    
    # Calculate clipboard ID
    local clipboard_id=$(calculate_clipboard_id "$PASSWORD")
    echo "Debug: Clipboard ID: $clipboard_id"
    
    # Create JSON content
    local json_content=$(create_json_content "$clipboard_content")
    local json_size=${#json_content}
    echo "Debug: JSON content size: $json_size bytes"
    
    # Encrypt the content
    local encrypted_content=$(encrypt_data "$json_content" "$PASSWORD")
    if [[ $? -ne 0 || -z "$encrypted_content" ]]; then
        notify "✗ Error: Failed to encrypt content"
        exit 1
    fi
    
    local encrypted_size=${#encrypted_content}
    echo "Debug: Encrypted content size: $encrypted_size bytes"
    
    # Send to server
    local response=$(printf '%s' "$encrypted_content" | curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/octet-stream" \
        --data-binary @- \
        "$CLIPSHARE_URL/clipboard/$clipboard_id")
    
    local http_code="${response: -3}"
    
    case "$http_code" in
        200)
            notify "✓ Clipboard sent successfully (original: ${original_size}B, encrypted: ${encrypted_size}B)"
            return 0
            ;;
        400)
            notify "✗ Error: Invalid content or ID"
            return 1
            ;;
        413|429)
            notify "✗ Error: Content too large or storage full"
            return 1
            ;;
        *)
            notify "✗ Error: Server returned $http_code"
            return 1
            ;;
    esac
}

set_clipboard() {
    local content="$1"
    
    if command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$content" | wl-copy
        notify "✓ Text copied to clipboard"
    else
        notify "✗ Error: wl-clipboard is not installed"
        return 1
    fi
    
    return 0
}

receive_content() {
    if [[ -z "$PASSWORD" ]]; then
        notify "✗ Error: CLIPSHARE_PASSWORD environment variable not set"
        exit 1
    fi
    
    # Calculate clipboard ID
    local clipboard_id=$(calculate_clipboard_id "$PASSWORD")
    
    local temp_file="$TEMP_DIR/clipshare_response_$$"
    
    # Download content
    local response=$(curl -s -w "%{http_code}" \
        -o "$temp_file" \
        "$CLIPSHARE_URL/clipboard/$clipboard_id")
    local http_code="$response"
    
    case "$http_code" in
        200)
            local encrypted_content=$(cat "$temp_file")
            rm -f "$temp_file"
            
            # Decrypt content
            local decrypted_content=$(decrypt_data "$encrypted_content" "$PASSWORD")
            if [[ $? -ne 0 ]]; then
                notify "✗ Error: Failed to decrypt content"
                return 1
            fi
            
            # Parse JSON and extract text
            local text_content=$(parse_json_content "$decrypted_content")
            
            # Set clipboard
            set_clipboard "$text_content"
            return $?
            ;;
        404)
            notify "✗ No clipboard content found"
            ;;
        401)
            notify "✗ Error: Unauthorized clipboard ID"
            ;;
        *)
            notify "✗ Error: Server returned $http_code"
            ;;
    esac
    
    rm -f "$temp_file"
    return 1
}

send_clipboard() {
    if ! curl -s --connect-timeout 5 "$CLIPSHARE_URL/" >/dev/null; then
        notify "✗ Error: Cannot reach clipshare server"
        exit 1
    fi
    
    send_content 
}

receive_clipboard() {
    if ! curl -s --connect-timeout 5 "$CLIPSHARE_URL/" >/dev/null; then
        notify "✗ Error: Cannot reach clipshare server"
        exit 1
    fi
    
    receive_content
}

# Check dependencies before running
check_dependencies

case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [options]"
        echo "Send/Receive encrypted clipboard content from clipshare server"
        echo ""
        echo "Environment variables:"
        echo "  CLIPSHARE_URL      Server URL (default: https://clipshare.ai6media.site)"
        echo "  CLIPSHARE_PASSWORD Password for encryption (required)"
        echo "  TEMP_DIR          Temporary directory (default: /tmp)"
        echo ""
        echo "Options:"
        echo "  -h, --help        Show this help"
        echo "  -s, --send        Send clipboard"
        echo "  -r, --receive     Receive clipboard"
        echo "  -t, --test        Test encryption/decryption"
        echo ""
        echo "Example:"
        echo "  CLIPSHARE_PASSWORD='your_password' $0 --send"
        exit 0
        ;;
    -t|--test)
        if [[ -z "$PASSWORD" ]]; then
            echo "✗ Error: CLIPSHARE_PASSWORD environment variable not set"
            exit 1
        fi
        
        echo "Testing encryption/decryption..."
        test_data="Hello, World! This is a test message with special chars: áéíóú 🌟"
        
        echo "Original: $test_data"
        echo "Original size: ${#test_data} bytes"
        
        encrypted=$(encrypt_data "$test_data" "$PASSWORD")
        if [[ $? -eq 0 && -n "$encrypted" ]]; then
            echo "✓ Encryption successful"
            echo "Encrypted size: ${#encrypted} chars"
            
            decrypted=$(decrypt_data "$encrypted" "$PASSWORD")
            if [[ $? -eq 0 && "$decrypted" == "$test_data" ]]; then
                echo "✓ Decryption successful"
                echo "✓ Round-trip test PASSED"
            else
                echo "✗ Decryption failed or data mismatch"
                echo "Expected: $test_data"
                echo "Got: $decrypted"
            fi
        else
            echo "✗ Encryption failed"
        fi
        exit 0
        ;;
    -s|--send)
        send_clipboard
        ;;
    -r|--receive)
        receive_clipboard
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
