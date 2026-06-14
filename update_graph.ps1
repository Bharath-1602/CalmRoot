# PowerShell Script to Update CalmRoot Knowledge Graph
Write-Host "🌿 Updating CalmRoot Knowledge Graph..." -ForegroundColor Green

$pythonPath = "graphify-out\.graphify_python"
if (Test-Path $pythonPath) {
    $python = Get-Content $pythonPath -Raw
    Write-Host "Using resolved Python interpreter: $python" -ForegroundColor Cyan
    & $python -m graphify . --update
} else {
    Write-Host "Running default graphify command..." -ForegroundColor Cyan
    graphify . --update
}

Write-Host "✅ Update completed successfully!" -ForegroundColor Green
