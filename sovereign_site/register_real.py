#!/usr/bin/env python3
import json

# Read the actual content files
with open('index.html', 'r', encoding='utf-8') as f:
    html_content = f.read()

with open('style.css', 'r', encoding='utf-8') as f:
    css_content = f.read()

# Create registration payload with actual content
payload = {
    "domain": "sovereign-network.zhtp",
    "owner": "sovereign_network_team",
    "content_mappings": {
        "/": {
            "content": html_content,
            "content_type": "text/html"
        },
        "/style.css": {
            "content": css_content,
            "content_type": "text/css"
        }
    },
    "metadata": {
        "title": "The Sovereign Network - Official Site",
        "description": "Decentralized mesh network that pays you for participation",
        "category": "official",
        "tags": ["sovereign-network", "mesh", "blockchain", "web4"],
        "public": True
    }
}

# Save payload to file
with open('register_payload.json', 'w', encoding='utf-8') as f:
    json.dump(payload, f, indent=2)

print("Registration payload created successfully!")
print(f"HTML content: {len(html_content)} bytes")
print(f"CSS content: {len(css_content)} bytes")
