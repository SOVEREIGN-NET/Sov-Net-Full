#!/usr/bin/env python3
"""
Register Sovereign Network with ALL essential JavaScript files in one batch.
This includes HTML, CSS, all JS (excluding source maps and images for now).
"""

import json
import os
import base64
import mimetypes
from pathlib import Path

SOURCE_DIR = Path("../Sovereign-Network-Site/dist")

def get_content_type(filepath):
    content_type, _ = mimetypes.guess_type(filepath)
    if content_type:
        return content_type
    ext = os.path.splitext(filepath)[1].lower()
    return {
        '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript',
        '.json': 'application/json', '.png': 'image/png',
    }.get(ext, 'application/octet-stream')

def read_file(filepath):
    content_type = get_content_type(filepath)
    is_binary = content_type.startswith('image/')
    
    if is_binary:
        with open(filepath, 'rb') as f:
            return base64.b64encode(f.read()).decode('utf-8'), content_type
    else:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read(), content_type

print("=" * 70)
print("🚀 Registering Sovereign Network - JavaScript Bundle")
print("=" * 70)
print()

content_mappings = {}
assets_dir = SOURCE_DIR / "assets"

# Add index.html
print("📄 Adding index.html...")
content, ctype = read_file(SOURCE_DIR / "index.html")
content_mappings["/"] = {"content": content, "content_type": ctype}

# Add CSS
print("🎨 Adding CSS...")
content, ctype = read_file(assets_dir / "index.BaRf_7uT.css")
content_mappings["/assets/index.BaRf_7uT.css"] = {"content": content, "content_type": ctype}

# Add ALL JavaScript files (no source maps)
print("📦 Adding JavaScript bundles...")
js_files = [f for f in assets_dir.glob("*.js") if not f.name.endswith('.map')]
for js_file in sorted(js_files):
    web_path = f"/assets/{js_file.name}"
    content, ctype = read_file(js_file)
    content_mappings[web_path] = {"content": content, "content_type": ctype}
    print(f"  + {js_file.name} ({len(content)/1024:.1f} KB)")

# Add logo
print("🖼️  Adding logo...")
content, ctype = read_file(assets_dir / "logo.BnCcuAut.png")
content_mappings["/assets/logo.BnCcuAut.png"] = {"content": content, "content_type": ctype}

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

output_file = "register_js_bundle.json"
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(payload, f, indent=2)

size_mb = os.path.getsize(output_file) / (1024 * 1024)

print()
print("=" * 70)
print(f"✅ Registration created: {output_file}")
print(f"📊 Total files: {len(content_mappings)}")
print(f"📦 Payload size: {size_mb:.2f} MB")
print()
if size_mb < 10:
    print("✅ Under 10 MB limit - ready to register!")
    print()
    print("To register:")
    print(f'  curl -X POST http://localhost:9333/api/v1/web4/domains/register \\')
    print(f'       -H "Content-Type: application/json" -d @{output_file}')
else:
    print(f"⚠️  Exceeds 10 MB limit by {size_mb - 10:.2f} MB")
print("=" * 70)
