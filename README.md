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

#### Option 1: Quick Start Script (Recommended)
```bash
# Linux/macOS
./start-node.sh

# Windows
start-node.bat
```

#### Option 2: Manual Node Type Selection
```bash
# Navigate to the ZHTP directory
cd zhtp

# Build the project
cargo build --release

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

#### Identity API
- `POST /api/identity/create` - Create new identities (human/device/organization)
- `GET /api/identity/status` - Check identity service status

#### Blockchain API
- `GET /api/blockchain/status` - Get blockchain status
- `GET /api/blockchain/balance/{address}` - Check address balance
- `GET /api/blockchain/validators` - List active validators
- `POST /api/blockchain/transaction` - Submit transactions

#### Protocol API
- `GET /api/protocol/status` - Check protocol handler status
- `POST /api/protocol/message` - Send protocol messages

#### Storage API
- `GET /api/storage/status` - Check storage service status

### Testing the API

Test the server with curl or any HTTP client:

```powershell
# Check server status
curl http://localhost:9333/api/identity/status

# Create a new identity
curl -X POST http://localhost:9333/api/identity/create `
  -H "Content-Type: application/json" `
  -d '{"identity_type": "human", "name": "Test User"}'

# Check blockchain status
curl http://localhost:9333/api/blockchain/status
```

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
## Development Workflow

### Building All Components
```powershell
# Build workspace (from root directory)
cargo build --workspace

# Run all tests
cargo test --workspace
```

## Architecture Overview

The SOVEREIGN_NET follows a modular architecture:

1. **ZHTP Server** - Central orchestrator and API gateway
2. **Core Libraries** - Modular blockchain components
3. **Post-Quantum Security** - CRYSTALS cryptography throughout
4. **Zero-Knowledge Proofs** - Privacy-preserving transactions
5. **Distributed Storage** - Mesh networking with DHT
6. **Economic Layer** - Token mechanics and governance

## Key Features

- **Post-Quantum Cryptography** - Future-proof security
- **Zero-Knowledge Proofs** - Privacy-preserving transactions  
- **Byzantine Fault Tolerance** - Robust consensus mechanisms
- **DAO Governance** - Decentralized decision making
- **Multi-Identity Support** - Humans, devices, and organizations
- **Mesh Networking** - P2P communication with LoRaWAN
- **Smart Contracts** - Programmable blockchain logic

## Documentation

- Check individual `README.md` files in each library directory
- See `BUGS.md` files for known issues and solutions
- Review `examples/` directories for usage patterns
- Check `docs/` directories for detailed documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

See individual library directories for specific licensing information.

## Support

For issues and questions:
- Check the `BUGS.md` files in relevant libraries
- Review existing GitHub issues
- Create new issues with detailed descriptions