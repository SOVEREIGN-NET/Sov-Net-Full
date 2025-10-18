# Single Node Test - Quick Validation
# Tests that a single ZHTP node can start and respond to requests

param(
    [string]$Config = ".\zhtp\configs\test-node1.toml",
    [int]$Port = 8080
)

Write-Host "Single Node Test - Quick Validation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set working directory
$projectRoot = "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full"
Set-Location $projectRoot

# Check executable
$exe = ".\zhtp\target\release\zhtp.exe"
if (-Not (Test-Path $exe)) {
    Write-Host "[ERROR] zhtp.exe not found" -ForegroundColor Red
    Write-Host "Run: cd zhtp; cargo build --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Executable found: $exe" -ForegroundColor Green

# Clean test data
Write-Host "Cleaning previous test data..." -ForegroundColor Yellow
if (Test-Path ".\data\test-node1") {
    Remove-Item -Recurse -Force ".\data\test-node1"
}
Write-Host "[OK] Test data cleaned" -ForegroundColor Green
Write-Host ""

# Start node in background
Write-Host "Starting node..." -ForegroundColor Cyan
Write-Host "  Config: $Config" -ForegroundColor Gray
Write-Host "  Port: $Port" -ForegroundColor Gray
Write-Host ""

$job = Start-Job -ScriptBlock {
    param($exe, $config)
    Set-Location "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full"
    & $exe node start --config $config 2>&1
} -ArgumentList $exe, $Config

Write-Host "Waiting for node to initialize (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check if job is still running
if ($job.State -eq "Running") {
    Write-Host "[OK] Node is running (Job ID: $($job.Id))" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Node failed to start or exited early" -ForegroundColor Red
    Write-Host "Job output:" -ForegroundColor Yellow
    Receive-Job -Job $job
    Remove-Job -Job $job
    exit 1
}

Write-Host ""
Write-Host "Testing node endpoints..." -ForegroundColor Cyan

# Test 1: Health check
Write-Host "  Test 1: Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$Port/api/v1/health" -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "    [PASS] Health check successful" -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] Unexpected status code: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "    [FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Node status
Write-Host "  Test 2: Node Status" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9333/api/v1/node/status" -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "    [PASS] Status endpoint successful" -ForegroundColor Green
    } else {
        Write-Host "    [WARN] Unexpected status code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "    [WARN] $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "    (Status endpoint may not be implemented yet)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Test Summary:" -ForegroundColor Cyan
Write-Host "  Node started: [OK]" -ForegroundColor Green
Write-Host "  Health check: See results above" -ForegroundColor Gray
Write-Host ""

# Stop node
Write-Host "Stopping node..." -ForegroundColor Yellow
Stop-Job -Job $job
Remove-Job -Job $job

# Also kill the process to be sure
Get-Process -Name "zhtp" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "[OK] Node stopped" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Run .\scripts\start_test_nodes.ps1 for multi-node testing" -ForegroundColor Cyan
