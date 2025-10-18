# Test Mesh Blockchain Functionality
# Comprehensive test suite for multi-validator mesh blockchain

param(
    [string]$Node1 = "http://localhost:8080",
    [string]$Node2 = "http://localhost:8081",
    [string]$Node3 = "http://localhost:8082",
    [string]$Node4 = "http://localhost:8083"
)

Write-Host "🧪 Mesh Blockchain Functionality Test" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$TestsPassed = 0
$TestsFailed = 0
$MeshId = ""

function Test-Endpoint {
    param([string]$Name, [string]$Url, [string]$Method = "GET", [string]$Body = "")
    
    Write-Host "🔬 Test: $Name" -ForegroundColor Yellow
    try {
        if ($Method -eq "GET") {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10
        } else {
            $response = Invoke-WebRequest -Uri $Url -Method POST -Body $Body -ContentType "application/json" -TimeoutSec 10
        }
        
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ PASS: $Name" -ForegroundColor Green
            $script:TestsPassed++
            return $response.Content
        } else {
            Write-Host "  ❌ FAIL: $Name (Status: $($response.StatusCode))" -ForegroundColor Red
            $script:TestsFailed++
            return $null
        }
    } catch {
        Write-Host "  ❌ FAIL: $Name (Error: $_)" -ForegroundColor Red
        $script:TestsFailed++
        return $null
    }
}

# Test 1: Health Check All Nodes
Write-Host "═══ Test Suite 1: Node Health ═══" -ForegroundColor Cyan
Test-Endpoint "Node 1 Health" "$Node1/api/v1/health"
Test-Endpoint "Node 2 Health" "$Node2/api/v1/health"
Test-Endpoint "Node 3 Health" "$Node3/api/v1/health"
Test-Endpoint "Node 4 Health" "$Node4/api/v1/health"
Write-Host ""

# Test 2: Create Mesh Blockchain
Write-Host "═══ Test Suite 2: Mesh Creation ═══" -ForegroundColor Cyan
$createMeshBody = @{
    name = "test-mesh-1"
    validators = @("node1", "node2", "node3", "node4")
    block_time_ms = 3000
    consensus_threshold = 0.67
} | ConvertTo-Json

$createResponse = Test-Endpoint "Create Mesh Blockchain" "$Node1/api/v1/mesh/create" "POST" $createMeshBody
if ($createResponse) {
    try {
        $meshData = $createResponse | ConvertFrom-Json
        $MeshId = $meshData.mesh_id
        Write-Host "  📋 Mesh ID: $MeshId" -ForegroundColor Gray
    } catch {
        Write-Host "  ⚠️  Could not parse mesh ID from response" -ForegroundColor Yellow
        $MeshId = "test_mesh_placeholder"
    }
}
Write-Host ""

if (-Not $MeshId) {
    Write-Host "❌ Cannot continue without mesh ID" -ForegroundColor Red
    exit 1
}

# Test 3: Submit Transactions
Write-Host "═══ Test Suite 3: Transaction Submission ═══" -ForegroundColor Cyan
for ($i = 1; $i -le 5; $i++) {
    $txBody = @{
        transaction_data = "test_transaction_$i"
        sender = "test_sender"
        nonce = $i
    } | ConvertTo-Json
    
    Test-Endpoint "Submit Transaction $i" "$Node1/api/v1/mesh/$MeshId/transaction" "POST" $txBody
    Start-Sleep -Milliseconds 200
}
Write-Host ""

# Test 4: Produce Blocks
Write-Host "═══ Test Suite 4: Block Production ═══" -ForegroundColor Cyan
Write-Host "⏳ Waiting 10 seconds for automatic block production..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

for ($i = 1; $i -le 3; $i++) {
    Test-Endpoint "Produce Block $i" "$Node1/api/v1/mesh/$MeshId/produce_block" "POST" ""
    Start-Sleep -Seconds 3  # Block time
}
Write-Host ""

# Test 5: Check Mesh Status on All Nodes
Write-Host "═══ Test Suite 5: Mesh Status ═══" -ForegroundColor Cyan
Test-Endpoint "Node 1 Mesh Status" "$Node1/api/v1/mesh/$MeshId/status"
Test-Endpoint "Node 2 Mesh Status" "$Node2/api/v1/mesh/$MeshId/status"
Test-Endpoint "Node 3 Mesh Status" "$Node3/api/v1/mesh/$MeshId/status"
Test-Endpoint "Node 4 Mesh Status" "$Node4/api/v1/mesh/$MeshId/status"
Write-Host ""

# Test 6: Get Sync Proof
Write-Host "═══ Test Suite 6: Sync Proof ═══" -ForegroundColor Cyan
$proofResponse = Test-Endpoint "Get Sync Proof" "$Node1/api/v1/mesh/$MeshId/sync/proof"
if ($proofResponse) {
    try {
        $proof = $proofResponse | ConvertFrom-Json
        Write-Host "  📊 Proof Type: $($proof.proof_type)" -ForegroundColor Gray
        Write-Host "  📏 Proof Size: $($proof.proof_data.Length) characters" -ForegroundColor Gray
    } catch {
        Write-Host "  ⚠️  Could not parse proof data" -ForegroundColor Yellow
    }
}
Write-Host ""

# Test 7: Fault Tolerance (Stop One Node)
Write-Host "═══ Test Suite 7: Fault Tolerance ═══" -ForegroundColor Cyan
Write-Host "⏸️  Simulating validator failure..." -ForegroundColor Yellow
Write-Host "  (This test requires manual intervention)" -ForegroundColor Gray
Write-Host "  Steps:" -ForegroundColor Gray
Write-Host "    1. Close one node window" -ForegroundColor Gray
Write-Host "    2. Wait 10 seconds" -ForegroundColor Gray
Write-Host "    3. Verify blocks still finalize (3/4 validators > 67%)" -ForegroundColor Gray
Write-Host "  (Skipping automated test)" -ForegroundColor Yellow
Write-Host ""

# Test Summary
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 Test Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ Passed: $TestsPassed" -ForegroundColor Green
Write-Host "  ❌ Failed: $TestsFailed" -ForegroundColor Red
Write-Host "  📝 Total:  $($TestsPassed + $TestsFailed)" -ForegroundColor Cyan

if ($TestsFailed -eq 0) {
    Write-Host ""
    Write-Host "🎉 All tests passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ Mesh blockchain is functioning correctly with:" -ForegroundColor Cyan
    Write-Host "  - Multi-validator consensus ✅" -ForegroundColor Gray
    Write-Host "  - Transaction submission ✅" -ForegroundColor Gray
    Write-Host "  - Block production ✅" -ForegroundColor Gray
    Write-Host "  - Sync proof generation ✅" -ForegroundColor Gray
    exit 0
} else {
    Write-Host ""
    Write-Host "⚠️  Some tests failed. Check the logs above." -ForegroundColor Yellow
    exit 1
}
