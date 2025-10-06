#!/usr/bin/env python3
import hashlib
import json

def calculate_hash(filepath):
    """Calculate SHA-256 hash and return first 16 hex chars"""
    with open(filepath, 'rb') as f:
        content = f.read()
        full_hash = hashlib.sha256(content).hexdigest()
        return full_hash[:16]  # First 16 characters

# Calculate hashes for each file
html_hash = calculate_hash('index.html')
css_hash = calculate_hash('style.css')

print(f"HTML hash: {html_hash}")
print(f"CSS hash: {css_hash}")

# Create registration payload
payload = {
    "domain": "sovereign-network.zhtp",
    "owner": "sovereign_network_team",
    "content_mappings": {
        "/": html_hash,
        "/style.css": css_hash
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
with open('register.json', 'w') as f:
    json.dump(payload, f, indent=2)

print("\nRegistration payload saved to register.json")
print(json.dumps(payload, indent=2))
