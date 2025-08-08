#!/usr/bin/env python3
"""
Simple script to send directory watch command to InjectionNext CLI server
Usage: python3 notify-watch.py /path/to/project
"""

import socket
import struct
import sys
import os

def send_watch_command(project_path, host='127.0.0.1', port=8887):
    """Send a projectRoot command to the injection server"""
    try:
        # Create socket connection
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        sock.connect((host, port))
        
        # Send handshake: INJECTION_VERSION (4001) and INJECTION_KEY
        injection_version = 4001
        # Include home directory suffix so server extracts '/Users/<name>' as expected
        home_dir = os.path.expanduser('~')
        injection_key = f"{home_dir}/SimpleSocket.mm"  # INJECTION_KEY = __FILE__ + user home suffix
        key_bytes = injection_key.encode('utf-8')
        
        # Send version (4 bytes, little endian)
        sock.send(struct.pack('<i', injection_version))
        
        # Send key length (4 bytes, little endian)
        sock.send(struct.pack('<i', len(key_bytes)))
        
        # Send key data
        sock.send(key_bytes)
        
        # Now send the projectRoot command
        # InjectionResponse.projectRoot = 5 (from InjectionClient.h)
        command = 5
        path_bytes = project_path.encode('utf-8')
        
        # Send command (4 bytes, little endian)
        sock.send(struct.pack('<i', command))
        
        # Send path length (4 bytes, little endian) 
        sock.send(struct.pack('<i', len(path_bytes)))
        
        # Send path data
        sock.send(path_bytes)
        
        print(f"✅ Sent watch command for: {project_path}")
        sock.close()
        
    except ConnectionRefusedError:
        print("❌ Connection refused - is the injection CLI server running?")
        print("   Make sure InjectionNext GUI app is running")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False
    
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python3 notify-watch.py /path/to/project [port]")
        print("Default port: 8887")
        sys.exit(1)
    
    # Resolve to a proper absolute path (expand '~' if used)
    project_path = os.path.abspath(os.path.expanduser(sys.argv[1]))
    port = int(sys.argv[2]) if len(sys.argv) == 3 else 8887
    
    if not os.path.exists(project_path):
        print(f"❌ Path does not exist: {project_path}")
        sys.exit(1)
    
    success = send_watch_command(project_path, port=port)
    sys.exit(0 if success else 1)