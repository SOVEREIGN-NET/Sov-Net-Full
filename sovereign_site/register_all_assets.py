#!/usr/bin/env python3
"""
Register all Sovereign Network site files to Web4 DHT
This creates a complete registration payload with all assets
"""

import json
import os
import base64
import mimetypes
from pathlib import Path

# Source directory
SOURCE_DIR = Path("../Sovereign-Network-Site/dist")

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
        '.map': 'application/json',
    }
    return type_map.get(ext, 'application/octet-stream')

def process_file(filepath, web_path):
    """Process a single file and return its content mapping."""
    content_type = get_content_type(filepath)
    is_binary = content_type.startswith('image/') or content_type.startswith('application/octet-stream')
    
    try:
        if is_binary:
            with open(filepath, 'rb') as f:
                content = base64.b64encode(f.read()).decode('utf-8')
        else:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
        
        size_kb = len(content) / 1024
        print(f"  ✓ {web_path} ({size_kb:.1f} KB) - {content_type}")
        
        return {
            "content": content,
            "content_type": content_type
        }
    except Exception as e:
        print(f"  ✗ Error reading {filepath}: {e}")
        return None

def scan_and_register():
    """Scan all files and create registration payload."""
    
    print("=" * 70)
    print("🌐 Sovereign Network - Complete Site Registration")
    print("=" * 70)
    print()
    
    content_mappings = {}
    total_size = 0
    
    # Process index.html
    index_path = SOURCE_DIR / "index.html"
    if index_path.exists():
        print("📄 Processing index.html...")
        mapping = process_file(index_path, "/")
        if mapping:
            content_mappings["/"] = mapping
            total_size += len(mapping["content"])
    
    # Process all files in assets
    assets_dir = SOURCE_DIR / "assets"
    if assets_dir.exists():
        print(f"\n📁 Processing assets directory...")
        all_files = list(assets_dir.rglob("*"))
        asset_files = [f for f in all_files if f.is_file()]
        
        print(f"Found {len(asset_files)} asset files\n")
        
        for asset_file in sorted(asset_files):
            relative_path = asset_file.relative_to(SOURCE_DIR)
            web_path = "/" + str(relative_path).replace("\\", "/")
            
            mapping = process_file(asset_file, web_path)
            if mapping:
                content_mappings[web_path] = mapping
                total_size += len(mapping["content"])
    
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
    output_file = "register_complete_site.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
    
    file_size_mb = os.path.getsize(output_file) / (1024 * 1024)
    
    print("\n" + "=" * 70)
    print(f"✅ Registration payload created: {output_file}")
    print(f"📊 Total files: {len(content_mappings)}")
    print(f"📦 Payload size: {file_size_mb:.2f} MB")
    print(f"💾 Content size: {total_size / (1024 * 1024):.2f} MB")
    print()
    
    if file_size_mb > 10:
        print("⚠️  WARNING: Payload exceeds 10 MB - may need chunked registration")
        print("    Consider registering in batches or using direct DHT upload")
    else:
        print("🎯 Ready to register with:")
        print(f'   curl -X POST http://localhost:9333/api/v1/web4/domains/register \\')
        print(f'        -H "Content-Type: application/json" -d @{output_file}')
    print("=" * 70)

if __name__ == "__main__":
    scan_and_register()
