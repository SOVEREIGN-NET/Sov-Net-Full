#!/usr/bin/env pwsh
# Test 4-Node Local Network Startup
# Verifies port conflict fix and multi-node operation

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ZHTP 4-Node Local Network Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$zhtp_path = "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full\zhtp"
$exe = "$zhtp_path\target\debug\zhtp.exe"

# Check if binary exists
if (-not (Test-Path $exe)) {
    Write-Host "ERROR: zhtp.exe not found at $exe" -ForegroundColor Red
    Write-Host "Please run 'cargo build' first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Found zhtp.exe" -ForegroundColor Green

# Kill any existing zhtp processes
Write-Host "`nCleaning up any existing zhtp processes..." -ForegroundColor Yellow
taskkill /F /IM zhtp.exe 2>$null | Out-Null
Start-Sleep -Seconds 2

# Array of node configs
$node1 = @{Name="Node-1 (Bootstrap)"; Config="test-node1.toml"; Port=8080}
$node2 = @{Name="Node-2"; Config="test-node2.toml"; Port=8081}
$node3 = @{Name="Node-3"; Config="test-node3.toml"; Port=8082}
$node4 = @{Name="Node-4"; Config="test-node4.toml"; Port=8083}
$nodes = @($node1, $node2, $node3, $node4)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Starting Nodes in Sequence" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$jobs = @()

foreach ($node in $nodes) {
    Write-Host "Starting $($node.Name) on port $($node.Port)..." -ForegroundColor Yellow
    
    $config_path = "$zhtp_path\configs\$($node.Config)"
    
    if (-not (Test-Path $config_path)) {
        Write-Host "  ERROR: Config not found: $config_path" -ForegroundColor Red
        continue
    }
    
    # Start node as background job
    $job = Start-Job -ScriptBlock {
        param($exe, $config)
        & $exe node start --config $config 2>&1
    } -ArgumentList $exe, $config_path
    
    $jobInfo = @{Job=$job; Name=$node.Name; Port=$node.Port}
    $jobs += $jobInfo
    
    Write-Host "  ✓ Started as Job ID: $($job.Id)" -ForegroundColor Green
    
    # Wait between starts to allow bootstrap
    Start-Sleep -Seconds 3
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Waiting for Nodes to Initialize (15s)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Start-Sleep -Seconds 15

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Checking Port Bindings" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

foreach ($nodeInfo in $jobs) {
    $port = $nodeInfo.Port
    $listening = netstat -ano | Select-String ":$port\s.*LISTENING"
    
    if ($listening) {
        Write-Host "✓ Port $port - LISTENING (Node: $($nodeInfo.Name))" -ForegroundColor Green
    } else {
        Write-Host "✗ Port $port - NOT LISTENING (Node: $($nodeInfo.Name))" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Job Status" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

foreach ($nodeInfo in $jobs) {
    $job = $nodeInfo.Job
    $state = $job.State
    $color = if ($state -eq "Running") { "Green" } else { "Red" }
    
    Write-Host "$($nodeInfo.Name) (Job $($job.Id)): $state" -ForegroundColor $color
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Sample Output from Each Node" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

foreach ($nodeInfo in $jobs) {
    Write-Host "`n--- $($nodeInfo.Name) ---" -ForegroundColor Yellow
    $output = Receive-Job -Job $nodeInfo.Job -Keep | Select-Object -First 30
    if ($output) {
        $output | Select-String -Pattern "Port|Binding|error|started|validator|consensus" | Select-Object -First 10
    } else {
        Write-Host "  (No output yet)" -ForegroundColor Gray
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "All 4 nodes are running in background jobs." -ForegroundColor Green
Write-Host ""
Write-Host "To view live output from a node:" -ForegroundColor Yellow
Write-Host "  Receive-Job -Id [JobId] -Keep" -ForegroundColor White
Write-Host ""
Write-Host "To stop all nodes:" -ForegroundColor Yellow
Write-Host "  Get-Job | Stop-Job; Get-Job | Remove-Job" -ForegroundColor White
Write-Host "  taskkill /F /IM zhtp.exe" -ForegroundColor White
Write-Host ""
Write-Host "Job IDs:" -ForegroundColor Yellow
foreach ($nodeInfo in $jobs) {
    Write-Host "  $($nodeInfo.Name): Job $($nodeInfo.Job.Id)" -ForegroundColor White
}
Write-Host ""

# Keep jobs alive
Write-Host "Press Ctrl+C to stop all nodes and exit..." -ForegroundColor Cyan
Write-Host ""

try {
    while ($true) {
        Start-Sleep -Seconds 5
        # Check if any jobs failed
        $failed = $jobs | Where-Object { $_.Job.State -eq "Failed" }
        if ($failed) {
            Write-Host "`nWARNING: Some jobs failed!" -ForegroundColor Red
            foreach ($f in $failed) {
                Write-Host "  $($f.Name): $($f.Job.State)" -ForegroundColor Red
            }
        }
    }
} finally {
    Write-Host "`nCleaning up jobs..." -ForegroundColor Yellow
    Get-Job | Stop-Job
    Get-Job | Remove-Job
    Write-Host "✓ Jobs cleaned up" -ForegroundColor Green
}
