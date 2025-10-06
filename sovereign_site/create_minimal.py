import json

# Create a minimal version with just the essential HTML
minimal_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Sovereign Network</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <header>
        <h1>The Sovereign Network</h1>
        <p>Decentralized Internet That Pays You</p>
    </header>
    <main>
        <section>
            <h2>Welcome</h2>
            <p>Join the revolution. Build the mesh. Get rewarded.</p>
        </section>
    </main>
</body>
</html>"""

minimal_css = """body {
    margin: 0;
    padding: 20px;
    font-family: system-ui, sans-serif;
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
    color: white;
}

header {
    text-align: center;
    padding: 40px 0;
}

h1 {
    font-size: 3rem;
    background: linear-gradient(to right, #22d3ee, #3b82f6);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

main {
    max-width: 800px;
    margin: 0 auto;
}
"""

# Create registration payload
registration_data = {
    "domain": "sovereign-network.zhtp",
    "owner": "sovereign_network_team",
    "content_mappings": {
        "/": {
            "content": minimal_html,
            "content_type": "text/html"
        },
        "/style.css": {
            "content": minimal_css,
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

# Write to file
with open('register_minimal.json', 'w', encoding='utf-8') as f:
    json.dump(registration_data, f, indent=2)

print(f"✅ Minimal registration payload created!")
print(f"HTML size: {len(minimal_html)} bytes")
print(f"CSS size: {len(minimal_css)} bytes")
print(f"Total content: {len(minimal_html) + len(minimal_css)} bytes")
