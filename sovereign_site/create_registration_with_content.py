#!/usr/bin/env python3
"""
Create proper Web4 domain registration payload with embedded content.
This will generate JSON with actual content that gets stored in DHT during registration.
"""

import json
import os
import base64
import mimetypes

# Source directory
SOURCE_DIR = "../Sovereign-Network-Site/dist"

# Essential files to include (keeping it small to avoid payload size issues)
ESSENTIAL_FILES = [
    "index.html",  # Main HTML
    "assets/index.BaRf_7uT.css",  # Main CSS
    "assets/logo.BnCcuAut.png",  # Logo image
]

def get_content_type(filepath):
    """Determine content type from file extension."""
    content_type, _ = mimetypes.guess_type(filepath)
    if content_type:
        return content_type
    
    # Fallback mappings
    ext = os.path.splitext(filepath)[1].lower()
    type_map = {
        '.html': 'text/html',
        '.css': 'text/css',
        '.js': 'application/javascript',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.ico': 'image/x-icon',
    }
    return type_map.get(ext, 'application/octet-stream')

def read_file_content(filepath):
    """Read file content as string (text files) or base64 (binary files)."""
    full_path = os.path.join(SOURCE_DIR, filepath)
    
    if not os.path.exists(full_path):
        print(f"❌ File not found: {full_path}")
        return None
    
    content_type = get_content_type(filepath)
    is_binary = content_type.startswith('image/') or content_type.startswith('application/octet-stream')
    
    try:
        if is_binary:
            with open(full_path, 'rb') as f:
                content = base64.b64encode(f.read()).decode('utf-8')
            print(f"✅ Read binary file: {filepath} ({len(content)} bytes base64)")
        else:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            print(f"✅ Read text file: {filepath} ({len(content)} bytes)")
        
        return content
    except Exception as e:
        print(f"❌ Error reading {filepath}: {e}")
        return None

def create_registration_payload():
    """Create registration payload with embedded content."""
    
    print("\n📦 Creating Web4 Registration Payload with Embedded Content\n")
    print("=" * 60)
    
    content_mappings = {}
    
    for filepath in ESSENTIAL_FILES:
        # Determine the path in the domain (/ for index.html, /assets/... for others)
        if filepath == "index.html":
            path = "/"
        else:
            path = "/" + filepath.replace("\\", "/")
        
        print(f"\nProcessing: {filepath}")
        print(f"  Path: {path}")
        
        content = read_file_content(filepath)
        if content is None:
            continue
        
        content_type = get_content_type(filepath)
        print(f"  Type: {content_type}")
        
        content_mappings[path] = {
            "content": content,
            "content_type": content_type
        }
    
    # Create registration payload
    payload = {
        "domain": "sovereign-network.zhtp",
        "owner": "sovereign_network_team",
        "content_mappings": content_mappings,
        "metadata": {
            "title": "The Sovereign Network - Official Site",
            "description": "Decentralized mesh network that pays you for participation",
            "category": "official",
            "tags": ["sovereign-network", "mesh", "blockchain", "web4"],
            "public": True
        }
    }
    
    # Save to file
    output_file = "register_with_embedded_content.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
    
    print("\n" + "=" * 60)
    print(f"✅ Registration payload saved to: {output_file}")
    print(f"📊 Total content mappings: {len(content_mappings)}")
    print(f"📦 Payload size: {os.path.getsize(output_file):,} bytes")
    print("\n🎯 Next step: Register domain with:")
    print(f'   curl -X POST http://localhost:9333/api/v1/web4/domains/register -H "Content-Type: application/json" -d @{output_file}')
    print()

if __name__ == "__main__":
    create_registration_payload()
