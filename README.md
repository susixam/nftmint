# NFT Mint — Full Stack

A full-stack NFT minting project built with **Solidity**, **Foundry**, and **React**. Deploys to Base chain.

## Structure

```
├── src/           # Solidity contracts
├── test/          # Foundry tests
├── script/        # Deployment scripts
├── frontend/      # React minting dApp
└── foundry.toml
```

## Prerequisites

- [Foundry](https://getfoundry.sh/) — **Windows users:** Foundry is not available in PowerShell. Use one of:
  - **Git Bash:** Install [Git](https://git-scm.com/download/win), open Git Bash, run:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```
    Then add `C:\Users\<YOU>\.foundry\bin` to your Windows PATH.
  - **WSL:** In WSL terminal, run the same commands. Use `bash -c "~/.foundry/bin/forge build"` from PowerShell, or run `forge` directly from WSL.
  - **From this repo:** Run `.\scripts\install-foundry.ps1` for full instructions.
- [Node.js](https://nodejs.org/) 18+
- Base mainnet ETH — get from [Base Bridge](https://bridge.base.org/) or your exchange

## 1. Install Dependencies

**OpenZeppelin** (via npm, at project root):

```bash
npm install
```

**Foundry** (forge-std for tests/scripts — requires Foundry):

```bash
forge install foundry-rs/forge-std --no-commit
```

## 2. Build & Test

```bash
forge build
forge test
```

**Test contract on all supported chains (fork tests):**
```bash
npm run test:fork          # Base, Ethereum, Sepolia (uses public RPCs)
npm run test:fork:base     # Base only
npm run test:fork:ethereum # Ethereum only
npm run test:fork:sepolia  # Sepolia only
```
With your own RPC (e.g. from `.env`): `forge test --fork-url $BASE_RPC_URL` (and same for `ETHEREUM_RPC_URL`, `SEPOLIA_RPC_URL`).

## 3. Deploy to Base

1. Copy `.env.example` to `.env` and fill in:

```
PRIVATE_KEY=your_wallet_private_key
BASE_RPC_URL=https://base-mainnet.g.alchemy.com/v2/YOUR_KEY
ETHERSCAN_API_KEY=your_etherscan_api_key  # for Basescan verification
```

2. Deploy (and verify on Basescan):

```bash
forge script script/Deploy.s.sol --target-contract DeployScript --rpc-url base --broadcast --verify --delay 15
```

Or use npm: `npm run deploy`

Ensure `ETHERSCAN_API_KEY` or `BASESCAN_API_KEY` is set in `.env` for verification.

**Chain IDs:** Ethereum = 1, Base = 8453, Sepolia = 11155111. If auto-verify fails, run:
```bash
# Ethereum (chain-id 1)
forge verify-contract <CONTRACT_ADDRESS> src/NFTMint.sol:NFTMint --chain-id 1

# Base (chain-id 8453)
forge verify-contract <CONTRACT_ADDRESS> src/NFTMint.sol:NFTMint --chain-id 8453

# Sepolia (chain-id 11155111)
forge verify-contract <CONTRACT_ADDRESS> src/NFTMint.sol:NFTMint --chain-id 11155111
```

**Test on Sepolia first:**
```bash
npm run deploy:sepolia
```

**WSL users:** If you get "Could not find target contract", use the Node.js deploy instead:
```bash
npm install
npm run deploy:node          # Base
npm run deploy:node:sepolia # Sepolia
```

3. Optional env vars for deployment:

```
NFT_NAME=My NFT
NFT_SYMBOL=MNFT
BASE_URI=https://your-metadata-api.com/metadata/
```

## 4. Run the Frontend

1. Copy `frontend/.env.example` to `frontend/.env`
2. Set `VITE_CONTRACT_ADDRESS` to your deployed contract address
3. Optionally set `VITE_WALLETCONNECT_PROJECT_ID` from [WalletConnect Cloud](https://cloud.walletconnect.com)

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173 — connect your wallet (Ethereum, Base, or Sepolia) and mint.

## Contract

- **Standard:** ERC-721 with Enumerable
- **Max supply:** 1000
- **Mint price:** 0.01 ETH
- **Owner:** deployer (can update `baseURI` and withdraw)

## Metadata

Set `BASE_URI` to point to your metadata API. Each token URI will be `{baseURI}{tokenId}`. Example metadata format:

```json
{
  "name": "NFT #1",
  "description": "...",
  "image": "https://...",
  "attributes": [...]
}
```
