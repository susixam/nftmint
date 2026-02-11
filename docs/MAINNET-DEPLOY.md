# Mainnet deployment – chains and estimated cost

Deploy is **one contract-creation tx**. No pre-mint unless you set `MINT_ON_DEPLOY=1`.

**Deployment gas (this contract):** ~**2,177,334** gas (deploy only).

Costs below are **estimates**. Check a gas tracker before sending.

---

## Chains and estimated deploy cost (USD)

| Chain            | Chain ID | Native token | Typical gas price | Est. deploy cost (USD) | Notes                    |
|------------------|----------|--------------|-------------------|-------------------------|--------------------------|
| **Ethereum**    | 1        | ETH          | 5–50 gwei         | **$3 – $150**           | Depends heavily on load  |
| **Arbitrum One**| 42161    | ETH          | ~0.1 gwei         | **$0.50 – $3**          | L2, very cheap           |
| **Optimism**    | 10       | ETH          | ~0.001 gwei       | **$0.20 – $1**          | L2, very cheap           |
| **Base**        | 8453     | ETH          | ~0.001 gwei       | **$0.20 – $1**          | L2, very cheap           |
| **Polygon**     | 137      | MATIC        | 30–200 gwei       | **$0.10 – $1**          | Sidechain, cheap         |
| **BNB Chain**   | 56       | BNB         | 3–10 gwei         | **$0.50 – $2**          | EVM, cheap               |
| **Avalanche C** | 43114    | AVAX         | 25 nAVAX          | **$0.20 – $1**          | EVM, cheap               |
| **Linea**       | 59144    | ETH          | very low          | **$0.10 – $0.50**       | L2                       |
| **zkSync Era**  | 324      | ETH          | very low          | **$0.10 – $0.50**       | L2 (verify may differ)  |

- **ETH** assumed ~$2,500–3,500; **MATIC** ~$0.30–0.50; **BNB** ~$600–700; **AVAX** ~$25–35.
- L2s (Arbitrum, Optimism, Base, Linea, zkSync) are usually **under ~$1–3** for this deploy.
- Ethereum mainnet can be **$5–150** depending on gas price (check [Etherscan Gas Tracker](https://etherscan.io/gastracker)).

---

## How to deploy on each mainnet

### 1. Add RPC and Etherscan to `.env`

Use a public RPC or one from [Alchemy](https://alchemy.com), [Infura](https://infura.io), [QuickNode](https://quicknode.com), etc.

```env
# Pick the chain you want (one at a time)
RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY          # Ethereum
# RPC_URL=https://arb-mainnet.g.alchemy.com/v2/YOUR_KEY         # Arbitrum
# RPC_URL=https://opt-mainnet.g.alchemy.com/v2/YOUR_KEY         # Optimism
# RPC_URL=https://base-mainnet.g.alchemy.com/v2/YOUR_KEY        # Base
# RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR_KEY    # Polygon
# RPC_URL=https://bnb-mainnet.g.alchemy.com/v2/YOUR_KEY        # BNB (if supported) or https://bsc-dataseed.binance.org/
# RPC_URL=https://avax-mainnet.g.alchemy.com/v2/YOUR_KEY       # Avalanche

ETHERSCAN_API_KEY=your_etherscan_api_key
# Get keys at: Etherscan, Arbiscan, Optimistic Etherscan, Basescan, Polygonscan, BscScan, Snowtrace, etc.
```

### 2. Run deploy (single tx, no pre-mint)

```bash
forge script script/Deploy.s.sol --target-contract DeployScript --rpc-url mainnet --broadcast --verify --delay 15
```

`mainnet` must match an RPC alias (see `foundry.toml`). If you use a single `RPC_URL` in `.env`, add a `mainnet` profile that uses it.

### 3. Or use chain-specific RPC alias

```bash
# Ethereum
forge script script/Deploy.s.sol --target-contract DeployScript --rpc-url ethereum --broadcast --verify --delay 15

# Arbitrum
forge script script/Deploy.s.sol --target-contract DeployScript --rpc-url arbitrum --broadcast --verify --delay 15

# Base
forge script script/Deploy.s.sol --target-contract DeployScript --rpc-url base --broadcast --verify --delay 15
```

(Add the same RPC/etherscan entries for each chain in `foundry.toml` so `--rpc-url` and `--verify` work.)

---

## Cost formula (for your own numbers)

- **Deploy cost in native token** ≈ `2_177_334 × gas_price_in_wei`
- **In USD** ≈ (above) × (native token price in USD)

Example (Ethereum): 2,177,334 × 20 gwei = 0.0435 ETH → at $3,000/ETH ≈ **$130**.

---

## Summary

- **Cheapest for testing:** Base, Optimism, Arbitrum, Polygon, Linea (~**$0.10 – $3**).
- **Most expensive:** Ethereum mainnet (~**$3 – $150** depending on gas).
- Always check the chain’s gas tracker and token price right before deploying.
