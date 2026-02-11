#!/bin/bash
# WSL workaround: run deploy via Windows to avoid "Could not find target contract"
# Usage: ./scripts/deploy-wsl.sh   or   bash scripts/deploy-wsl.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WIN_PATH=$(wslpath -w "$PROJECT_DIR" 2>/dev/null || echo "$PROJECT_DIR")

echo "Running deploy from Windows (WSL workaround)..."
echo "Project path: $WIN_PATH"

cmd.exe /c "cd /d \"$WIN_PATH\" && forge script script/Deploy.s.sol --target-contract DeployScript --rpc-url base --broadcast --verify --delay 15"
