# Install Foundry for Windows (PowerShell)
# Foundry does not support PowerShell natively - this script guides you through installation.

Write-Host "=== Foundry Installation for Windows ===" -ForegroundColor Cyan
Write-Host ""

$foundryPath = "$env:USERPROFILE\.foundry\bin"
$foundryExists = Test-Path "$foundryPath\forge.exe"

if ($foundryExists) {
    Write-Host "Foundry appears to be installed at: $foundryPath" -ForegroundColor Green
    Write-Host "Add it to your PATH to use 'forge' from any terminal:" -ForegroundColor Yellow
    Write-Host "  [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$foundryPath', 'User')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Then restart your terminal and run: forge build" -ForegroundColor Yellow
    exit 0
}

Write-Host "Foundry is NOT installed. Choose one of these options:" -ForegroundColor Yellow
Write-Host ""
Write-Host "OPTION 1: Git Bash (recommended)" -ForegroundColor Cyan
Write-Host "  1. Install Git for Windows: https://git-scm.com/download/win"
Write-Host "  2. Open Git Bash and run:"
Write-Host "     curl -L https://foundry.paradigm.xyz | bash"
Write-Host "     foundryup"
Write-Host "  3. Add to Windows PATH: $env:USERPROFILE\.foundry\bin"
Write-Host ""
Write-Host "OPTION 2: WSL (Windows Subsystem for Linux)" -ForegroundColor Cyan
Write-Host "  1. Open WSL terminal"
Write-Host "  2. Run: curl -L https://foundry.paradigm.xyz | bash"
Write-Host "  3. Run: foundryup"
Write-Host "  4. Use forge from WSL: wsl ~/.foundry/bin/forge build"
Write-Host ""
Write-Host "OPTION 3: Manual download" -ForegroundColor Cyan
Write-Host "  1. Go to: https://github.com/foundry-rs/foundry/releases"
Write-Host "  2. Download the 'foundry_*.zip' for Windows (x86_64)"
Write-Host "  3. Extract and add the folder to your PATH"
Write-Host ""
Write-Host "OPTION 4: Add WSL Foundry to PATH (if already installed in WSL)" -ForegroundColor Cyan
Write-Host "  If you installed via WSL, forge is at: wsl_path ~/.foundry/bin"
Write-Host "  Run from PowerShell: bash -c '~/.foundry/bin/forge build'"
Write-Host ""
