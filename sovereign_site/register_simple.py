#!/usr/bin/env python3
import json

# Create a simplified version with just the core content
# Strip out the massive inline SVG animations and JavaScript

simplified_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Sovereign Network - Decentralized Internet</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <div class="min-h-screen bg-slate-900 text-white">
        <header class="bg-slate-800 border-b border-slate-700 sticky top-0 z-50">
            <div class="container mx-auto px-4">
                <div class="flex items-center justify-between h-16">
                    <div class="flex items-center space-x-2">
                        <span class="text-xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                            The Sovereign Network
                        </span>
                    </div>
                </div>
            </div>
        </header>
        
        <main>
            <section class="relative min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-950 to-purple-900">
                <div class="container mx-auto px-4 text-center">
                    <h1 class="text-6xl md:text-8xl font-black mb-8">
                        <span class="bg-gradient-to-r from-white via-cyan-200 to-blue-200 bg-clip-text text-transparent">
                            An Internet that pays you
                        </span>
                        <br>
                        <span class="bg-gradient-to-r from-cyan-400 via-blue-400 to-purple-400 bg-clip-text text-transparent">
                            to use it
                        </span>
                    </h1>
                    <p class="text-xl md:text-2xl text-slate-300 mb-12 max-w-4xl mx-auto">
                        Join the revolution. Build the mesh. Get rewarded.
                    </p>
                </div>
            </section>
        </main>
    </div>
</body>
</html>"""

# Read the actual CSS file
with open('style.css', 'r', encoding='utf-8') as f:
    css_content = f.read()

# Create registration payload with ContentMapping format
payload = {
    "domain": "sovereign-network.zhtp",
    "owner": "sovereign_network_team",
    "content_mappings": {
        "/": {
            "content": simplified_html,
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

# Save to file
with open('register_simple.json', 'w', encoding='utf-8') as f:
    json.dump(payload, f, indent=2)

html_size = len(simplified_html)
css_size = len(css_content)
total_size = html_size + css_size

print(f"✅ Simplified registration payload created!")
print(f"HTML: {html_size:,} bytes (simplified)")
print(f"CSS: {css_size:,} bytes")
print(f"Total: {total_size:,} bytes")
print(f"\nSaved to: register_simple.json")
