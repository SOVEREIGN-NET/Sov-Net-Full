#!/usr/bin/env pwsh
# Simple 4-Node Test Script

Write-Host "`n=== ZHTP 4-Node Test ===" -ForegroundColor Cyan

$zhtp = "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full\zhtp\target\debug\zhtp.exe"
$configs = "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full\zhtp\configs"

# Kill existing processes
taskkill /F /IM zhtp.exe 2>$null | Out-Null
Start-Sleep -Seconds 2

Write-Host "`nStarting 4 nodes..." -ForegroundColor Yellow

# Start Node 1 (Bootstrap)
Write-Host "Starting Node 1 (port 8080)..." -ForegroundColor Green
$job1 = Start-Job -ScriptBlock { param($exe, $cfg) & $exe node start --config $cfg 2>&1 } -ArgumentList $zhtp, "$configs\test-node1.toml"
Start-Sleep -Seconds 3

# Start Node 2
Write-Host "Starting Node 2 (port 8081)..." -ForegroundColor Green
$job2 = Start-Job -ScriptBlock { param($exe, $cfg) & $exe node start --config $cfg 2>&1 } -ArgumentList $zhtp, "$configs\test-node2.toml"
Start-Sleep -Seconds 3

# Start Node 3
Write-Host "Starting Node 3 (port 8082)..." -ForegroundColor Green
$job3 = Start-Job -ScriptBlock { param($exe, $cfg) & $exe node start --config $cfg 2>&1 } -ArgumentList $zhtp, "$configs\test-node3.toml"
Start-Sleep -Seconds 3

# Start Node 4
Write-Host "Starting Node 4 (port 8083)..." -ForegroundColor Green
$job4 = Start-Job -ScriptBlock { param($exe, $cfg) & $exe node start --config $cfg 2>&1 } -ArgumentList $zhtp, "$configs\test-node4.toml"

Write-Host "`nWaiting for initialization (15 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`n=== Checking Port Bindings ===" -ForegroundColor Cyan
$ports = @(8080, 8081, 8082, 8083)
foreach ($port in $ports) {
    $listening = netstat -ano | Select-String ":$port\s.*LISTENING"
    if ($listening) {
        Write-Host "Port $port - LISTENING" -ForegroundColor Green
    } else {
        Write-Host "Port $port - NOT LISTENING" -ForegroundColor Red
    }
}

Write-Host "`n=== Job Status ===" -ForegroundColor Cyan
Write-Host "Job 1 (Node 1): $($job1.State)" -ForegroundColor $(if ($job1.State -eq "Running") {"Green"} else {"Red"})
Write-Host "Job 2 (Node 2): $($job2.State)" -ForegroundColor $(if ($job2.State -eq "Running") {"Green"} else {"Red"})
Write-Host "Job 3 (Node 3): $($job3.State)" -ForegroundColor $(if ($job3.State -eq "Running") {"Green"} else {"Red"})
Write-Host "Job 4 (Node 4): $($job4.State)" -ForegroundColor $(if ($job4.State -eq "Running") {"Green"} else {"Red"})

Write-Host "`n=== Sample Output from Node 1 ===" -ForegroundColor Cyan
Receive-Job -Job $job1 -Keep | Select-String -Pattern "Port|Binding|error|started|validator" | Select-Object -First 10

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
Write-Host "Nodes are running. To stop:" -ForegroundColor Yellow
Write-Host "  Get-Job | Stop-Job; Get-Job | Remove-Job; taskkill /F /IM zhtp.exe" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to exit (nodes will keep running)..." -ForegroundColor Cyan

# Wait for user
try {
    while ($true) { Start-Sleep -Seconds 10 }
} finally {
    Write-Host "`nCleaning up..." -ForegroundColor Yellow
    Get-Job | Stop-Job
    Get-Job | Remove-Job
}
