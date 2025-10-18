# Start Multi-Node Mesh Test Environment
# Launches 4 validator nodes for local mesh blockchain testing

Write-Host "[START] Multi-Node Mesh Test Environment" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Set the working directory to the project root
$projectRoot = "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full"
Set-Location $projectRoot

# Check if the executable exists
$exe = ".\zhtp\target\release\zhtp.exe"
if (-Not (Test-Path $exe)) {
    Write-Host "[ERROR] zhtp.exe not found at $exe" -ForegroundColor Red
    Write-Host "Please run 'cd zhtp; cargo build --release' first" -ForegroundColor Yellow
    exit 1
}

# Clean previous test data
Write-Host "[CLEAN] Cleaning previous test data..." -ForegroundColor Yellow
if (Test-Path ".\data\test-node1") { Remove-Item -Recurse -Force ".\data\test-node1" }
if (Test-Path ".\data\test-node2") { Remove-Item -Recurse -Force ".\data\test-node2" }
if (Test-Path ".\data\test-node3") { Remove-Item -Recurse -Force ".\data\test-node3" }
if (Test-Path ".\data\test-node4") { Remove-Item -Recurse -Force ".\data\test-node4" }
Write-Host "[OK] Test data cleaned" -ForegroundColor Green
Write-Host ""

# Start Node 1 (Bootstrap)
Write-Host "[NODE 1] Starting Bootstrap Validator..." -ForegroundColor Cyan
Write-Host "  Port: 8080 | Mesh Port: 9001" -ForegroundColor Gray
$startNode1 = @"
Set-Location '$projectRoot'
`$host.UI.RawUI.WindowTitle = 'Node 1 - Bootstrap Validator'
Write-Host '[NODE 1] Bootstrap Validator' -ForegroundColor Cyan
Write-Host 'API Port: 8080 | Mesh Port: 9001' -ForegroundColor Gray
Write-Host ''
& '$exe' node start --config zhtp\configs\test-node1.toml
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $startNode1
Start-Sleep -Seconds 5  # Give bootstrap node time to initialize

# Start Node 2
Write-Host "[NODE 2] Starting Validator..." -ForegroundColor Cyan
Write-Host "  Port: 8081 | Mesh Port: 9002" -ForegroundColor Gray
$startNode2 = @"
Set-Location '$projectRoot'
`$host.UI.RawUI.WindowTitle = 'Node 2 - Validator'
Write-Host '[NODE 2] Validator' -ForegroundColor Cyan
Write-Host 'API Port: 8081 | Mesh Port: 9002' -ForegroundColor Gray
Write-Host ''
& '$exe' node start --config zhtp\configs\test-node2.toml
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $startNode2
Start-Sleep -Seconds 2

# Start Node 3
Write-Host "[NODE 3] Starting Validator..." -ForegroundColor Cyan
Write-Host "  Port: 8082 | Mesh Port: 9003" -ForegroundColor Gray
$startNode3 = @"
Set-Location '$projectRoot'
`$host.UI.RawUI.WindowTitle = 'Node 3 - Validator'
Write-Host '[NODE 3] Validator' -ForegroundColor Cyan
Write-Host 'API Port: 8082 | Mesh Port: 9003' -ForegroundColor Gray
Write-Host ''
& '$exe' node start --config zhtp\configs\test-node3.toml
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $startNode3
Start-Sleep -Seconds 2

# Start Node 4
Write-Host "[NODE 4] Starting Validator..." -ForegroundColor Cyan
Write-Host "  Port: 8083 | Mesh Port: 9004" -ForegroundColor Gray
$startNode4 = @"
Set-Location '$projectRoot'
`$host.UI.RawUI.WindowTitle = 'Node 4 - Validator'
Write-Host '[NODE 4] Validator' -ForegroundColor Cyan
Write-Host 'API Port: 8083 | Mesh Port: 9004' -ForegroundColor Gray
Write-Host ''
& '$exe' node start --config zhtp\configs\test-node4.toml
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $startNode4

Write-Host ""
Write-Host "[OK] All 4 nodes started!" -ForegroundColor Green
Write-Host ""
Write-Host "[NETWORK] Configuration:" -ForegroundColor Cyan
Write-Host "  Node 1 (Bootstrap): http://localhost:8080 | Mesh: 9001" -ForegroundColor Gray
Write-Host "  Node 2:             http://localhost:8081 | Mesh: 9002" -ForegroundColor Gray
Write-Host "  Node 3:             http://localhost:8082 | Mesh: 9003" -ForegroundColor Gray
Write-Host "  Node 4:             http://localhost:8083 | Mesh: 9004" -ForegroundColor Gray
Write-Host ""
Write-Host "[WAIT] Waiting 10 seconds for network formation..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "[NEXT] Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Run .\scripts\test_mesh.ps1 to test mesh blockchain functionality" -ForegroundColor Gray
Write-Host "  2. Monitor node logs in separate windows" -ForegroundColor Gray
Write-Host "  3. Run .\scripts\stop_nodes.ps1 when finished" -ForegroundColor Gray
Write-Host ""
Write-Host "[TIP] Check node health with:" -ForegroundColor Yellow
Write-Host "  curl http://localhost:8080/api/v1/health" -ForegroundColor Gray
Write-Host ""
