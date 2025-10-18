# Test All Testnet Node Configurations
# Verifies that all 5 testnet node types can start successfully

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTNET CONFIGURATION TEST SUITE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$zhtpPath = "C:\Users\sethr\Desktop\SOVEREIGN\Sov-Net-Full\zhtp"
$configPath = "$zhtpPath\configs"
$exePath = "$zhtpPath\target\debug\zhtp.exe"

# Check if executable exists
if (-not (Test-Path $exePath)) {
    Write-Host "ERROR: zhtp.exe not found at $exePath" -ForegroundColor Red
    Write-Host "Run 'cargo build' first!" -ForegroundColor Yellow
    exit 1
}

# List of testnet configs to test
$configs = @(
    "testnet-full-node.toml",
    "testnet-validator-node.toml",
    "testnet-storage-node.toml",
    "testnet-edge-node.toml",
    "testnet-bootstrap-node.toml"
)

$results = @()

foreach ($config in $configs) {
    $configFile = Join-Path $configPath $config
    
    Write-Host "`n----------------------------------------" -ForegroundColor Yellow
    Write-Host "Testing: $config" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    
    # Check if config exists
    if (-not (Test-Path $configFile)) {
        Write-Host "  [FAIL] Config file not found!" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Config = $config
            Status = "MISSING"
            ChainID = "N/A"
            NetworkID = "N/A"
            APIPort = "N/A"
        }
        continue
    }
    
    # Read config to verify chain_id and network_id
    $chainId = (Select-String -Path $configFile -Pattern "chain_id\s*=\s*(\d+)" | ForEach-Object { $_.Matches.Groups[1].Value })
    $networkId = (Select-String -Path $configFile -Pattern 'network_id\s*=\s*"([^"]+)"' | ForEach-Object { $_.Matches.Groups[1].Value })
    $apiPort = (Select-String -Path $configFile -Pattern "api_port\s*=\s*(\d+)" | ForEach-Object { $_.Matches.Groups[1].Value })
    
    Write-Host "  Chain ID: $chainId (Expected: 2)" -ForegroundColor $(if ($chainId -eq "2") { "Green" } else { "Red" })
    Write-Host "  Network ID: $networkId (Expected: zhtp-testnet)" -ForegroundColor $(if ($networkId -eq "zhtp-testnet") { "Green" } else { "Red" })
    Write-Host "  API Port: $apiPort (Expected: 9334)" -ForegroundColor $(if ($apiPort -eq "9334") { "Green" } else { "Red" })
    
    # Try to start the node (timeout after 10 seconds)
    Write-Host "`n  Starting node..." -ForegroundColor Cyan
    
    $job = Start-Job -ScriptBlock {
        param($exe, $cfg)
        & $exe node start --config $cfg 2>&1
    } -ArgumentList $exePath, $configFile
    
    # Wait up to 10 seconds for startup
    $timeout = 10
    $started = $false
    $output = ""
    
    for ($i = 0; $i -lt $timeout; $i++) {
        Start-Sleep -Seconds 1
        $jobOutput = Receive-Job -Job $job
        $output += $jobOutput
        
        if ($jobOutput -match "Started|Running|Listening|Initialized") {
            $started = $true
            Write-Host "  [SUCCESS] Node started!" -ForegroundColor Green
            break
        }
        
        if ($jobOutput -match "error|Error|ERROR|panic|failed to bind") {
            Write-Host "  [FAIL] Startup error detected!" -ForegroundColor Red
            break
        }
    }
    
    # Stop the job
    Stop-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
    
    # Check for errors in output
    $hasErrors = $output -match "error|Error|ERROR|panic"
    
    if ($started -and -not $hasErrors) {
        Write-Host "  [PASS] Configuration valid!" -ForegroundColor Green
        $status = "PASS"
    } elseif ($hasErrors) {
        Write-Host "  [FAIL] Errors in output!" -ForegroundColor Red
        Write-Host "`n  Error details:" -ForegroundColor Red
        $output | Select-String -Pattern "error|Error|ERROR|panic" | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        $status = "ERROR"
    } else {
        Write-Host "  [WARN] Timeout - couldn't verify startup" -ForegroundColor Yellow
        $status = "TIMEOUT"
    }
    
    $results += [PSCustomObject]@{
        Config = $config
        Status = $status
        ChainID = $chainId
        NetworkID = $networkId
        APIPort = $apiPort
    }
}

# Summary
Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$results | Format-Table -AutoSize

$passCount = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$totalCount = $results.Count

Write-Host "`nResults: $passCount/$totalCount configs passed" -ForegroundColor $(if ($passCount -eq $totalCount) { "Green" } else { "Yellow" })

if ($passCount -eq $totalCount) {
    Write-Host "`n[SUCCESS] All testnet configurations are valid!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n[WARNING] Some configurations need attention!" -ForegroundColor Yellow
    exit 1
}
