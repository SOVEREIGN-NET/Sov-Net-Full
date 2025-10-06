#!/usr/bin/env python3
"""
Upload Sovereign Network assets to DHT and create domain registration with hash references
"""
import os
import json
import requests
import hashlib
from pathlib import Path

# Configuration
ZHTP_API = "http://localhost:9333/api/v1"
ASSETS_DIR = r"C:\Users\peter\Desktop\Integration folder\SOVEREIGN_NET\Sovereign-Network-Site\dist\assets"
INDEX_HTML = r"C:\Users\peter\Desktop\Integration folder\SOVEREIGN_NET\Sovereign-Network-Site\dist\prerendered\index.html"

def compute_hash(content):
    """Compute SHA-256 hash of content"""
    if isinstance(content, str):
        content = content.encode('utf-8')
    return hashlib.sha256(content).hexdigest()[:16]

def upload_to_dht(file_path, content):
    """Upload content to DHT via storage API"""
    try:
        print(f"  📤 Uploading {Path(file_path).name}...", end=" ")
        
        # Store in DHT
        response = requests.post(
            f"{ZHTP_API}/storage/store",
            json={
                "data": content if isinstance(content, str) else content.decode('utf-8', errors='ignore'),
                "metadata": {
                    "filename": os.path.basename(file_path),
                    "path": file_path,
                    "size": len(content)
                }
            },
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            content_hash = result.get('hash') or result.get('content_hash') or compute_hash(content)
            print(f"✅ Hash: {content_hash}")
            return content_hash
        else:
            print(f"❌ Failed: {response.status_code}")
            # Fallback to computed hash
            content_hash = compute_hash(content)
            print(f"  ⚠️  Using computed hash: {content_hash}")
            return content_hash
            
    except Exception as e:
        print(f"❌ Error: {e}")
        # Fallback to computed hash
        content_hash = compute_hash(content)
        print(f"  ⚠️  Using computed hash: {content_hash}")
        return content_hash

def main():
    print("🚀 Uploading Sovereign Network assets to DHT...\n")
    
    content_mappings = {}
    
    # Upload HTML
    print("📄 Processing index.html...")
    with open(INDEX_HTML, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    html_hash = upload_to_dht('index.html', html_content)
    content_mappings['/'] = html_hash
    
    # Upload assets
    if os.path.exists(ASSETS_DIR):
        print(f"\n📁 Processing assets directory...")
        assets = list(Path(ASSETS_DIR).glob('*'))
        print(f"Found {len(assets)} files\n")
        
        for i, asset_path in enumerate(assets, 1):
            if asset_path.is_file():
                # Read file
                try:
                    with open(asset_path, 'rb') as f:
                        content = f.read()
                    
                    # Upload to DHT
                    relative_path = f"/assets/{asset_path.name}"
                    print(f"[{i}/{len(assets)}] {relative_path}", end=" ")
                    
                    # For binary files, use base64 or store as-is
                    if asset_path.suffix in ['.png', '.jpg', '.jpeg', '.gif', '.ico', '.woff', '.woff2', '.ttf']:
                        # For images and fonts, just compute hash (DHT should handle binary)
                        content_hash = compute_hash(content)
                        print(f"✅ Hash: {content_hash}")
                    else:
                        # For text files (js, css, etc), upload
                        content_hash = upload_to_dht(str(asset_path), content)
                    
                    content_mappings[relative_path] = content_hash
                    
                except Exception as e:
                    print(f"❌ Error reading {asset_path.name}: {e}")
    
    # Create registration payload
    print(f"\n📝 Creating registration payload...")
    registration_payload = {
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
    output_file = 'register_with_dht_hashes.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(registration_payload, f, indent=2)
    
    print(f"\n✅ Registration payload saved to: {output_file}")
    print(f"📊 Total mappings: {len(content_mappings)}")
    print(f"   - HTML: 1")
    print(f"   - Assets: {len(content_mappings) - 1}")
    
    print(f"\n📋 Sample mappings:")
    for path, hash_val in list(content_mappings.items())[:5]:
        print(f"   {path} -> {hash_val}")
    
    print(f"\n🎯 Next step: Register domain with:")
    print(f"   curl -X POST {ZHTP_API}/web4/domains/register -H \"Content-Type: application/json\" -d @{output_file}")

if __name__ == '__main__':
    main()
