# Stop Multi-Node Mesh Test Environment
# Terminates all test validator nodes

Write-Host "🛑 Stopping Multi-Node Mesh Test Environment" -ForegroundColor Red
Write-Host "==============================================" -ForegroundColor Red
Write-Host ""

# Find and stop all zhtp processes
$processes = Get-Process -Name "zhtp" -ErrorAction SilentlyContinue

if ($processes) {
    Write-Host "Found $($processes.Count) node process(es)" -ForegroundColor Yellow
    
    foreach ($process in $processes) {
        Write-Host "🛑 Stopping process $($process.Id)..." -ForegroundColor Red
        Stop-Process -Id $process.Id -Force
    }
    
    Start-Sleep -Seconds 2
    Write-Host "✅ All nodes stopped" -ForegroundColor Green
} else {
    Write-Host "No running nodes found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 To clean test data, run:" -ForegroundColor Cyan
Write-Host "  Remove-Item -Recurse -Force .\data\test-node*" -ForegroundColor Gray
Write-Host ""
