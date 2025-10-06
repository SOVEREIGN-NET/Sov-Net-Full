#!/usr/bin/env python3
"""
Register Sovereign Network site in chunks to avoid payload size limits.
Strategy: Register domain with essential files first, then update with more files in batches.
"""

import json
import os
import base64
import mimetypes
from pathlib import Path
import subprocess
import time

SOURCE_DIR = Path("../Sovereign-Network-Site/dist")
SERVER_URL = "http://localhost:9333/api/v1/web4/domains/register"

def get_content_type(filepath):
    """Determine content type from file extension."""
    content_type, _ = mimetypes.guess_type(filepath)
    if content_type:
        return content_type
    ext = os.path.splitext(filepath)[1].lower()
    type_map = {
        '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript',
        '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg',
        '.map': 'application/json',
    }
    return type_map.get(ext, 'application/octet-stream')

def read_file_content(filepath):
    """Read and encode file content."""
    content_type = get_content_type(filepath)
    is_binary = content_type.startswith('image/')
    
    if is_binary:
        with open(filepath, 'rb') as f:
            return base64.b64encode(f.read()).decode('utf-8'), content_type
    else:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read(), content_type

def create_batch(files_dict, batch_name):
    """Create a registration batch."""
    content_mappings = {}
    total_size = 0
    
    for web_path, file_path in files_dict.items():
        content, content_type = read_file_content(file_path)
        content_mappings[web_path] = {
            "content": content,
            "content_type": content_type
        }
        total_size += len(content)
        print(f"  + {web_path} ({len(content)/1024:.1f} KB)")
    
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
    
    filename = f"batch_{batch_name}.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
    
    size_mb = os.path.getsize(filename) / (1024 * 1024)
    print(f"  📦 Batch size: {size_mb:.2f} MB")
    return filename, size_mb

def register_in_batches():
    """Register site in manageable batches."""
    
    print("=" * 70)
    print("🌐 Chunked Registration Strategy")
    print("=" * 70)
    print()
    
    assets_dir = SOURCE_DIR / "assets"
    
    # Batch 1: Essential files only (HTML, CSS, main JS, logo)
    print("📦 BATCH 1: Essential files")
    batch1_files = {
        "/": SOURCE_DIR / "index.html",
        "/assets/index.BaRf_7uT.css": assets_dir / "index.BaRf_7uT.css",
        "/assets/index.DwjF3mSV.js": assets_dir / "index.DwjF3mSV.js",
        "/assets/logo.BnCcuAut.png": assets_dir / "logo.BnCcuAut.png",
    }
    batch1_file, batch1_size = create_batch(batch1_files, "1_essential")
    print()
    
    # Batch 2: React and vendor libraries (critical for app to work)
    print("📦 BATCH 2: Core libraries")
    batch2_files = {
        "/assets/react-vendor.CzsvKnaC.js": assets_dir / "react-vendor.CzsvKnaC.js",
        "/assets/router-vendor.BMAF8fxi.js": assets_dir / "router-vendor.BMAF8fxi.js",
        "/assets/icons-vendor.CevNhbq0.js": assets_dir / "icons-vendor.CevNhbq0.js",
        "/assets/animation-vendor.DC65dgkg.js": assets_dir / "animation-vendor.DC65dgkg.js",
    }
    batch2_file, batch2_size = create_batch(batch2_files, "2_vendors")
    print()
    
    # Batch 3: Page components (smaller JS files)
    print("📦 BATCH 3: Page components")
    batch3_files = {}
    for js_file in assets_dir.glob("*Page*.js"):
        if not js_file.name.endswith('.map'):
            web_path = f"/assets/{js_file.name}"
            batch3_files[web_path] = js_file
    batch3_file, batch3_size = create_batch(batch3_files, "3_pages")
    print()
    
    print("=" * 70)
    print("Summary:")
    print(f"  Batch 1 (Essential): {batch1_size:.2f} MB")
    print(f"  Batch 2 (Libraries): {batch2_size:.2f} MB")
    print(f"  Batch 3 (Pages): {batch3_size:.2f} MB")
    print()
    
    if batch1_size > 10 or batch2_size > 10 or batch3_size > 10:
        print("⚠️  Some batches still exceed 10 MB limit!")
        print("    Need to split into smaller batches or increase server limit.")
    else:
        print("✅ All batches under 10 MB - ready to register!")
        print()
        print("To register:")
        print(f"  1. curl -X POST {SERVER_URL} -H 'Content-Type: application/json' -d @{batch1_file}")
        print(f"  2. Wait for registration, then register additional batches")
        print("     (Note: Current system may overwrite - need update API)")
    print("=" * 70)

if __name__ == "__main__":
    register_in_batches()
