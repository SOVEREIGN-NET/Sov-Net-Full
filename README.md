# SOVEREIGN_NET

A distributed post-quantum blockchain network with advanced privacy features and zero-knowledge proofs.

## Project Structure

This repository contains multiple interconnected libraries and services:

### Core Libraries
- **`lib-blockchain/`** - Core blockchain implementation with UTXO model and smart contracts
- **`lib-consensus/`** - Byzantine fault-tolerant consensus mechanisms with DAO governance
- **`lib-crypto/`** - Post-quantum cryptography (CRYSTALS-Kyber, CRYSTALS-Dilithium)
- **`lib-identity/`** - Identity management for humans, devices, and organizations
- **`lib-economy/`** - Economic models, rewards, and token mechanics
- **`lib-network/`** - P2P networking with DHT integration and LoRaWAN support
- **`lib-proofs/`** - Zero-knowledge proof systems and verification
- **`lib-protocols/`** - Communication protocols and message handling
- **`lib-storage/`** - Distributed storage with mesh networking capabilities

## Quick Start

### Prerequisites
- Rust (latest stable)
- Node.js (for web interface)
- Git

### Running Different Node Types

SOVEREIGN_NET supports multiple node types optimized for different use cases:


#### Option 1 Manual Node Type Selection
```bash
# Navigate to the ZHTP directory
cd zhtp

# Build the project
cargo build 

# Start test node****

./target/debug/zhtp.exe node start
^^^^^^^^^^^^^^^^^^^^^^^
#"./target/debug/zhtp.exe" this is how you use the cli for now you can use --help to see the current commands.

# Start different node types:

# Full Node (complete functionality)
zhtp --node-type full

# Validator Node (consensus participation)
zhtp --node-type validator

# Storage Node (distributed storage)
zhtp --node-type storage

# Edge Node (mesh networking)
zhtp --node-type edge

# Development Node (testing)
zhtp --node-type dev
```

#### Option 3: Custom Configuration
```bash
# Use custom config file
zhtp --config ./my-custom-config.toml

# Override specific settings
zhtp --node-type validator --mesh-port 33445
```

### Node Type Overview

| Node Type | Purpose | Resources | Special Features |
|-----------|---------|-----------|------------------|
| **Full** | Complete blockchain functionality | 4GB RAM, 1TB storage | All components, API endpoints |
| **Validator** | Consensus participation | 8GB RAM, 2TB storage | Block validation, staking required |
| **Storage** | Distributed storage services | 2GB RAM, 10TB storage | High storage capacity, DHT focus |
| **Edge** | Mesh networking, ISP bypass | 1GB RAM, 200GB storage | Pure mesh mode, long-range relays |
| **Dev** | Development and testing | 512MB RAM, 50GB storage | Fast blocks, relaxed security |

The server will start on `http://localhost:9333` with the following endpoints:

#### *****API*****
go to /zhtp/native_zhtp_api_complete.md those are the 30 apis that should work right now.



### Running Individual Components

Each library can be tested independently:

```powershell
# Test blockchain functionality
cd lib-blockchain
cargo test

# Test consensus mechanisms
cd lib-consensus  
cargo test

# Test cryptographic functions
cd lib-crypto
cargo test

# Run specific examples
cd lib-blockchain
cargo run --example full_consensus_integration
```