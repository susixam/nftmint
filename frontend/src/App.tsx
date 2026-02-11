import { useState, useEffect } from "react";
import { ConnectButton, useChainModal } from "@rainbow-me/rainbowkit";
import {
  useAccount,
  useChainId,
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
} from "wagmi";
import { NFTMINT_ABI } from "./abis/NFTMint";
import "@rainbow-me/rainbowkit/styles.css";

const CONTRACT_ADDRESS = (import.meta.env.VITE_CONTRACT_ADDRESS || "") as `0x${string}`;
const isValidAddress = /^0x[a-fA-F0-9]{40}$/.test(CONTRACT_ADDRESS);
const hasContract = CONTRACT_ADDRESS && isValidAddress;

function MintSection() {
  const { address } = useAccount();
  const [amount, setAmount] = useState(1);

  const { data: name } = useReadContract({
    address: hasContract ? CONTRACT_ADDRESS : undefined,
    abi: NFTMINT_ABI,
    functionName: "name",
  });
  const { data: symbol } = useReadContract({
    address: hasContract ? CONTRACT_ADDRESS : undefined,
    abi: NFTMINT_ABI,
    functionName: "symbol",
  });
  const { data: mintPrice } = useReadContract({
    address: hasContract ? CONTRACT_ADDRESS : undefined,
    abi: NFTMINT_ABI,
    functionName: "mintPrice",
  });
  const { data: maxSupply } = useReadContract({
    address: hasContract ? CONTRACT_ADDRESS : undefined,
    abi: NFTMINT_ABI,
    functionName: "maxSupply",
  });
  const { data: totalSupply, refetch: refetchTotalSupply } = useReadContract({
    address: hasContract ? CONTRACT_ADDRESS : undefined,
    abi: NFTMINT_ABI,
    functionName: "totalSupply",
  });
  const { data: userBalance, refetch: refetchUserBalance } = useReadContract({
    address: hasContract ? CONTRACT_ADDRESS : undefined,
    abi: NFTMINT_ABI,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
  });

  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  useEffect(() => {
    if (isSuccess) {
      refetchTotalSupply();
      refetchUserBalance();
      setAmount(1);
    }
  }, [isSuccess, refetchTotalSupply, refetchUserBalance]);

  const remaining = maxSupply != null && totalSupply != null ? Number(maxSupply) - Number(totalSupply) : 0;

  useEffect(() => {
    if (remaining > 0 && amount > remaining) {
      setAmount(remaining);
    }
  }, [remaining, amount]);

  const safeAmount = Math.min(Math.max(1, amount), Math.max(0, remaining));
  const totalCost = mintPrice && safeAmount > 0 ? BigInt(mintPrice) * BigInt(safeAmount) : 0n;

  const handleMint = () => {
    if (!hasContract || totalCost === 0n || safeAmount <= 0) return;
    if (safeAmount === 1) {
      writeContract({
        address: CONTRACT_ADDRESS,
        abi: NFTMINT_ABI,
        functionName: "mint",
        value: totalCost,
      });
    } else {
      writeContract({
        address: CONTRACT_ADDRESS,
        abi: NFTMINT_ABI,
        functionName: "mintBatch",
        args: [BigInt(safeAmount)],
        value: totalCost,
      });
    }
  };

  const formatEth = (wei: bigint) => {
    const n = Number(wei) / 1e18;
    return n >= 0.01 ? n.toFixed(3) : n.toFixed(4);
  };

  const errorMessage =
    error?.message?.includes("InsufficientPayment")
      ? "Insufficient payment. Send the required ETH."
      : error?.message?.includes("MaxSupplyReached")
        ? "Max supply reached."
        : error?.message?.includes("ForwardFailed")
          ? "Payment transfer failed. Try again."
          : error?.message?.includes("ZeroAmount")
            ? "Amount must be at least 1."
            : error?.message;

  if (!hasContract) {
    return (
      <div className="card warning">
        <p>
          {CONTRACT_ADDRESS && !isValidAddress
            ? "Invalid contract address format (expected 0x + 40 hex chars)."
            : "Set VITE_CONTRACT_ADDRESS in frontend/.env to your deployed contract address."}
        </p>
      </div>
    );
  }

  return (
    <div className="card">
      {(name || symbol) && (
        <p className="collection-name">
          {[name, symbol].filter(Boolean).join(" · ")}
        </p>
      )}
      <h2>Mint NFT</h2>
      <div className="stats">
        <span>Minted: {totalSupply?.toString() ?? "—"} / {maxSupply?.toString() ?? "—"}</span>
        <span>Remaining: {remaining}</span>
        <span>Your balance: {userBalance?.toString() ?? "0"}</span>
        <span>Price: {mintPrice ? `${formatEth(mintPrice)} ETH` : "—"} each</span>
      </div>

      {remaining > 0 && (
        <>
          <div className="amount-row">
            <label htmlFor="mint-amount">Amount</label>
            <input
              id="mint-amount"
              type="number"
              min={1}
              max={remaining}
              value={amount}
              onChange={(e) => {
                const val = Math.floor(Number(e.target.value) || 0);
                setAmount(Math.max(1, Math.min(remaining, val)));
              }}
            />
          </div>
          <p className="total-cost">
            Total: {formatEth(totalCost)} ETH
          </p>
          <button
            className="mint-btn"
            onClick={handleMint}
            disabled={isPending || isConfirming || !address || safeAmount <= 0}
          >
            {isPending || isConfirming
              ? "Confirming..."
              : !address
                ? "Connect wallet"
                : `Mint ${safeAmount} ${safeAmount === 1 ? "NFT" : "NFTs"}`}
          </button>
        </>
      )}

      {remaining <= 0 && (
        <p className="sold-out">Sold out</p>
      )}

      {isSuccess && <p className="success">Minted successfully!</p>}
      {errorMessage && <p className="error">{errorMessage}</p>}
    </div>
  );
}

function Header() {
  const chainId = useChainId();
  const { openChainModal } = useChainModal();
  const chainName = chainId === 8453 ? "Base" : chainId === 11155111 ? "Sepolia" : `Chain ${chainId}`;

  return (
    <header>
      <h1>NFT Mint</h1>
      <div className="header-actions">
        {openChainModal && (
          <button type="button" className="chain-btn" onClick={openChainModal}>
            {chainName}
          </button>
        )}
        <ConnectButton />
      </div>
    </header>
  );
}

function App() {
  return (
    <div className="app">
      <Header />
      <main>
        <MintSection />
      </main>
    </div>
  );
}

export default App;
