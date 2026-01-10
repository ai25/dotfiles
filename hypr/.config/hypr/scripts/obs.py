#!/usr/bin/env python3
"""Toggle OBS recording via WebSocket."""

import json
import sys
import hashlib
import base64
import argparse
from pathlib import Path
from websocket import create_connection

HOST = "localhost"
PORT = 4455
PASSWORD = ""


def authenticate(ws, password):
    """Authenticate with OBS WebSocket server."""
    hello = json.loads(ws.recv())

    identify_payload = {"op": 1, "d": {"rpcVersion": 1}}

    if "authentication" in hello["d"]:
        auth_data = hello["d"]["authentication"]
        challenge = auth_data["challenge"]
        salt = auth_data["salt"]

        secret = base64.b64encode(
            hashlib.sha256((password + salt).encode()).digest()
        ).decode()

        auth_response = base64.b64encode(
            hashlib.sha256((secret + challenge).encode()).digest()
        ).decode()

        identify_payload["d"]["authentication"] = auth_response

    ws.send(json.dumps(identify_payload))

    result = json.loads(ws.recv())
    if result["op"] != 2:
        raise Exception("Authentication failed")


def send_request(ws, request_type, request_id="1"):
    """Send a request and return the response."""
    ws.send(
        json.dumps(
            {"op": 6, "d": {"requestType": request_type, "requestId": request_id}}
        )
    )

    while True:
        msg = json.loads(ws.recv())
        if msg["op"] == 7 and msg["d"]["requestId"] == request_id:
            return msg["d"]


def toggle_recording(discard=False):
    try:
        ws = create_connection(f"ws://{HOST}:{PORT}")

        authenticate(ws, PASSWORD)

        status = send_request(ws, "GetRecordStatus", "status")

        if discard:
            if not status["responseData"]["outputActive"]:
                print("Not recording, nothing to discard", file=sys.stderr)
                ws.close()
                return 1

            stop_response = send_request(ws, "StopRecord", "stop")
            output_path = stop_response["responseData"].get("outputPath")

            if output_path:
                path = Path(output_path)
                if path.exists():
                    path.unlink()
                    print(f"Deleted: {output_path}")
                else:
                    print(f"File not found: {output_path}", file=sys.stderr)
            else:
                print("Warning: No output path in response", file=sys.stderr)
        else:
            if status["responseData"]["outputActive"]:
                send_request(ws, "StopRecord", "stop")
                print("Recording stopped")
            else:
                send_request(ws, "StartRecord", "start")
                print("Recording started")

        ws.close()
        return 0

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Toggle OBS recording")
    parser.add_argument(
        "--discard", action="store_true", help="Stop recording and delete the file"
    )
    args = parser.parse_args()

    sys.exit(toggle_recording(discard=args.discard))
