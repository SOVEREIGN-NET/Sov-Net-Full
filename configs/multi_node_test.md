# Multi-Node Mesh Blockchain Test Setup

## Overview
Test configuration for running 4 local nodes to verify mesh blockchain consensus and synchronization.

## Node Configuration

### Node 1 (Validator 1 - Primary)
- **Port**: 8080
- **Mesh Port**: 9001
- **Role**: Validator, Bootstrap Node
- **Identity**: Will be generated on first run
- **Config**: `configs/testnet/node1.toml`

### Node 2 (Validator 2)
- **Port**: 8081
- **Mesh Port**: 9002
- **Role**: Validator
- **Bootstrap Peer**: localhost:9001 (Node 1)
- **Config**: `configs/testnet/node2.toml`

### Node 3 (Validator 3)
- **Port**: 8082
- **Mesh Port**: 9003
- **Role**: Validator
- **Bootstrap Peer**: localhost:9001 (Node 1)
- **Config**: `configs/testnet/node3.toml`

### Node 4 (Validator 4)
- **Port**: 8083
- **Mesh Port**: 9004
- **Role**: Validator
- **Bootstrap Peer**: localhost:9001 (Node 1)
- **Config**: `configs/testnet/node4.toml`

## Test Scenarios

### 1. Network Formation (5 minutes)
- Start Node 1 (bootstrap node)
- Start Nodes 2, 3, 4
- Verify all nodes discover each other
- Check peer discovery messages
- Verify mesh network connectivity

### 2. Mesh Blockchain Creation (5 minutes)
```bash
# Create mesh blockchain via Node 1 API
curl -X POST http://localhost:8080/api/v1/mesh/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test-mesh-1",
    "validators": [
      "node1_identity",
      "node2_identity",
      "node3_identity",
      "node4_identity"
    ],
    "block_time_ms": 3000,
    "consensus_threshold": 0.67
  }'
```

### 3. Transaction Submission (10 minutes)
```bash
# Submit test transactions to the mesh
for i in {1..10}; do
  curl -X POST http://localhost:8080/api/v1/mesh/{mesh_id}/transaction \
    -H "Content-Type: application/json" \
    -d '{
      "transaction_data": "test_tx_'$i'",
      "sender": "test_sender",
      "nonce": '$i'
    }'
  sleep 1
done
```

### 4. Block Production (15 minutes)
- Verify validators take turns proposing blocks
- Check consensus messages (Proposal, Prevote, Precommit, Commit)
- Verify 67% threshold for block finalization
- Monitor block height progression
- Verify all nodes have same chain

### 5. Consensus Testing (20 minutes)
- **Normal Case**: All 4 validators online → blocks finalize
- **Fault Tolerance**: Stop 1 validator → blocks still finalize (3/4 > 67%)
- **No Consensus**: Stop 2 validators → blocks don't finalize (2/4 < 67%)
- **Recovery**: Restart stopped validators → chain continues

### 6. Mesh Sync to Global (15 minutes)
```bash
# Trigger mesh sync
curl -X POST http://localhost:8080/api/v1/mesh/{mesh_id}/sync
```
- Verify recursive proof generation
- Check proof aggregation (O(1) size)
- Verify sync to global blockchain
- Validate proof verification on global chain

### 7. Sync Proof Retrieval (5 minutes)
```bash
# Get sync proof
curl http://localhost:8080/api/v1/mesh/{mesh_id}/sync/proof
```
- Verify proof size is O(1)
- Check proof contains: root hash, height, recursive proof
- Validate proof can be verified independently

### 8. Status Monitoring (5 minutes)
```bash
# Check mesh status from each node
for port in 8080 8081 8082 8083; do
  curl http://localhost:$port/api/v1/mesh/{mesh_id}/status
done
```
- Verify all nodes report same block height
- Check validator participation rates
- Monitor consensus round progression

## Expected Results

### Network Health
- ✅ All 4 nodes discover each other within 10 seconds
- ✅ Mesh connectivity established
- ✅ Health reports show good network quality

### Consensus
- ✅ Blocks finalize with 3+ validators online
- ✅ Blocks don't finalize with only 2 validators
- ✅ Chain continues after validator restart
- ✅ All nodes have identical block hashes

### Sync Proofs
- ✅ Proof size is O(1) (constant, ~few KB regardless of mesh size)
- ✅ Proof generation takes < 1 second for 1000 blocks
- ✅ Proof verification takes < 100ms
- ✅ Sync to global blockchain succeeds

### API Endpoints
- ✅ Create mesh: Returns mesh_id
- ✅ Submit transaction: Returns tx_hash
- ✅ Produce block: Returns block_height and block_hash
- ✅ Get status: Returns accurate validator and block info
- ✅ Get sync proof: Returns valid recursive proof

## Logging Checkpoints

### Successful Messages to Watch For
```
🔷 Mesh network initialized
🌐 Peer discovered: [peer_id]
📡 Consensus message received from node: [node_id]
✅ Consensus message processed successfully
🎉 Consensus reached for block at height X
⛓️  Block finalized: height X, hash: [hash]
🔒 Generating recursive sync proof...
✅ Sync proof generated (size: X bytes)
🌍 Mesh synced to global blockchain at height X
```

### Error Messages to Address
```
❌ Consensus message processing failed
⚠️  Consensus threshold not met (X% < 67%)
⚠️  Validator timeout: [validator_id]
❌ Proof generation failed
❌ Mesh sync failed
```

## Performance Benchmarks

### Target Metrics
- **Block Time**: 3 seconds (configurable)
- **Finalization Time**: 6-9 seconds (2-3 rounds)
- **Proof Generation**: < 1 second for 1000 blocks
- **Proof Verification**: < 100ms
- **Proof Size**: < 10 KB (constant)
- **Transaction Throughput**: 100+ tx/sec per mesh
- **Validator Response Time**: < 500ms

### Failure Thresholds
- **Block Time** > 10 seconds → investigate consensus delays
- **Finalization** > 30 seconds → check network or validator issues
- **Proof Generation** > 5 seconds → investigate proof circuit
- **Proof Size** > 100 KB → aggregation not working correctly

## Cleanup
```bash
# Stop all nodes
# Clear test data
rm -rf data/node*/
rm -rf logs/node*/
```

## Next Steps After Validation
1. Deploy to actual testnet with remote validators
2. Test with higher validator counts (10, 20, 50)
3. Stress test with high transaction volumes
4. Test network partitions and recovery
5. Benchmark long-running stability (24+ hours)
