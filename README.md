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

For a full list of features that need implementing/fixing, as well as things that we already have,
go to BLOCKCHAIN_FEATURE_MATRIX.md in /zhtp

## Quick Start

### Prerequisites
- Rust (latest stable)
- Node.js (for web interface)
- Git
- openssl/tls

### Building the Project

```bash
# Navigate to the ZHTP directory
cd zhtp

# Build for development
cargo build

# Build for production (recommended)
cargo build --release
```

### Starting Nodes

The ZHTP network supports **mainnet**, **testnet**, and **dev** networks with specialized node types:

#### **MAINNET Nodes** (Production Network - Chain ID: 1)

```bash
# Full Node - Complete blockchain with API access
./target/release/zhtp node start --network mainnet --config configs/mainnet-full-node.toml

# Validator Node - Block production and consensus (Maximum Security)
./target/release/zhtp node start --network mainnet --config configs/validator-node.toml

# Storage Node - Distributed storage and DHT participation
./target/release/zhtp node start --network mainnet --config configs/storage-node.toml

# Edge Node - Mesh networking and ISP bypass (Pure Mesh Mode)
./target/release/zhtp node start --network mainnet --config configs/edge-node.toml
```

#### **TESTNET Nodes** (Testing Network - Chain ID: 2)

```bash
# Full Node - Testing and development
./target/release/zhtp node start --network testnet --config configs/testnet-full-node.toml

# Validator Node - Testnet consensus participation
./target/release/zhtp node start --network testnet --config configs/testnet-validator-node.toml

# Storage Node - Storage testing and development
./target/release/zhtp node start --network testnet --config configs/testnet-storage-node.toml

# Edge Node - Mesh networking testing (IoT/Mobile)
./target/release/zhtp node start --network testnet --config configs/testnet-edge-node.toml
```

#### **DEV/LOCAL Nodes** (Development - Chain ID: 99)

```bash
# Quick development node
./target/release/zhtp node start --network dev

# Multi-node local testing (4 nodes)
cd scripts
./start_test_nodes.ps1  # Windows PowerShell
# or
./start_test_nodes.sh   # Linux/macOS
```

### Windows-Specific Commands

On Windows, use `.exe` extension:

```powershell
# Development build
.\target\debug\zhtp.exe node start --network mainnet --config configs\mainnet-full-node.toml

# Production build (recommended)
.\target\release\zhtp.exe node start --network mainnet --config configs\mainnet-full-node.toml
```

### Node Type Selection Guide

| Node Type | Purpose | Network Mode | Best For |
|-----------|---------|--------------|----------|
| **Full Node** | Complete blockchain access | Hybrid | API servers, dApps, explorers |
| **Validator** | Block production & consensus | Hybrid | Staking, security, governance |
| **Storage** | Distributed storage (IPFS-like) | Hybrid | Data providers, DHT participation |
| **Edge** | Mesh networking & ISP bypass | Pure Mesh | Rural connectivity, censorship resistance |

### Network Isolation

- **Mainnet** (chain_id=1): Production network with maximum security
- **Testnet** (chain_id=2): Testing network with high security
- **Local-Test** (chain_id=99): Development network with medium security

Each network has complete isolation with separate:
- Chain IDs (prevents replay attacks)
- Network IDs
- Bootstrap nodes
- Data directories
- Configuration profiles

### CLI Help

```bash
# View all available commands
./target/release/zhtp --help

# View node startup options
./target/release/zhtp node start --help
```

#### *****API*****
Go to `/zhtp/native_zhtp_api_complete.md` for the 30 REST APIs currently available.



### Running Individual Components

Each library can be tested independently:

```bash
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

## Network Features

### 🌐 Bluetooth Mesh Networking
- **Cross-platform support**: Windows (GATT), macOS (Core Bluetooth), Linux (BlueZ)
- **Encrypted discovery**: No MAC address exposure
- **Multi-protocol**: TCP/IP, Bluetooth LE, WiFi Direct, LoRaWAN

### 💰 SOV Token Rewards
- **Routing**: 1 SOV/MB + 5 SOV per hop
- **Storage**: 10 SOV/GB/month
- **Bandwidth**: 100 SOV/GB shared + 10 SOV/hour uptime
- **Quality bonuses**: +50% for >95% success rate

### 🔒 Post-Quantum Security
- **Signatures**: CRYSTALS-Dilithium (levels 2-5)
- **Key Exchange**: CRYSTALS-Kyber (512-1024 bits)
- **Encryption**: AES-256-GCM
- **Zero-Knowledge**: Plonky2 circuits

### 🛡️ Privacy Features
- Encrypted mesh communications
- Ephemeral Bluetooth addresses
- Zero-knowledge identity proofs
- No raw MAC address exposure

## System Requirements

### Mainnet Validator
- **CPU**: 8+ cores
- **RAM**: 16GB+ 
- **Storage**: 500GB+ SSD
- **Network**: Stable connection, port 9333 open

### Testnet/Development
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 100GB+ SSD
- **Network**: Port 9334 (testnet) or 8080-8083 (local-test)

### Edge Node (Mesh)
- **CPU**: 2+ cores
- **RAM**: 2GB+
- **Storage**: 10GB+
- **Bluetooth**: BLE 4.0+ adapter

## Documentation

- **Full Feature Matrix**: `/zhtp/BLOCKCHAIN_FEATURE_MATRIX.md`
- **API Documentation**: `/zhtp/native_zhtp_api_complete.md`
- **Network Verification**: `/zhtp/configs/TESTNET_MAINNET_VERIFICATION.md`
- **Configuration Guide**: `/zhtp/configs/README.md`

## Project Status

- ✅ Blockchain core (UTXO + smart contracts)
- ✅ Post-quantum cryptography (Dilithium + Kyber)
- ✅ Cross-platform Bluetooth mesh
- ✅ SOV token economics and rewards
- ✅ Testnet/Mainnet separation
- ✅ Zero-knowledge proofs (Plonky2)
- ⏳ Multi-node testing (in progress)
- ⏳ Production deployment (pending testing)

## Contributing

This is an active development project. See individual library READMEs for specific contribution guidelines.