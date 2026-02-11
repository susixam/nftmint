#!/usr/bin/env node
/**
 * Node.js deploy script - works on WSL when forge script fails.
 * Run: forge build && node scripts/deploy-node.js
 * Requires: npm install ethers dotenv
 */
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import "dotenv/config";

const __dirname = dirname(fileURLToPath(import.meta.url));

// Support --chain sepolia or --chain base (default: base)
const chainIdx = process.argv.indexOf("--chain");
const chain = chainIdx >= 0 && process.argv[chainIdx + 1] ? process.argv[chainIdx + 1] : process.env.CHAIN || "base";
const projectRoot = join(__dirname, "..");

async function deploy() {
  let ethers;
  try {
    ethers = await import("ethers");
  } catch {
    console.error("Missing ethers. Run: npm install ethers dotenv");
    process.exit(1);
  }

  const privateKey = process.env.PRIVATE_KEY;
  const rpcUrl =
    chain === "sepolia"
      ? (process.env.SEPOLIA_RPC_URL || "https://rpc.sepolia.org")
      : (process.env.BASE_RPC_URL || "https://mainnet.base.org");
  const name = process.env.NFT_NAME || "NFT Mint";
  const symbol = process.env.NFT_SYMBOL || "MINT";
  const baseURI =
    process.env.BASE_URI || "https://api.example.com/metadata/";
  const mintPriceWei = process.env.MINT_PRICE
    ? ethers.parseEther(process.env.MINT_PRICE)
    : ethers.parseEther("0.001");
  const maxSupply = process.env.MAX_SUPPLY ? BigInt(process.env.MAX_SUPPLY) : 5n;

  if (!privateKey) {
    console.error("Set PRIVATE_KEY in .env");
    process.exit(1);
  }

  // Normalize private key (add 0x if missing)
  const pk = privateKey.startsWith("0x") ? privateKey : "0x" + privateKey;

  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(pk, provider);

  const artifactPath = join(
    projectRoot,
    "out/NFTMint.sol/NFTMint.json"
  );
  const artifact = JSON.parse(readFileSync(artifactPath, "utf8"));
  const bytecode = artifact.bytecode?.object || artifact.bytecode;
  const abi = artifact.abi;

  if (!bytecode) {
    console.error("Build first: forge build");
    process.exit(1);
  }

  const chainName = chain === "sepolia" ? "Sepolia" : "Base";
  console.log("Deploying NFTMint to", chainName + "...");
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);
  const nft = await factory.deploy(name, symbol, baseURI, mintPriceWei, maxSupply);
  await nft.waitForDeployment();
  const address = await nft.getAddress();
  console.log("NFTMint deployed at:", address);

  const mintOnDeploy = process.env.MINT_ON_DEPLOY === "1";
  if (mintOnDeploy) {
    const batchValue = mintPriceWei * maxSupply;
    console.log("Minting", maxSupply.toString(), "NFTs...");
    const tx = await nft.mintBatch(maxSupply, { value: batchValue });
    await tx.wait();
    console.log("Minted", maxSupply.toString(), "NFTs to deployer");
  }
  console.log("Done!");
}

deploy().catch((err) => {
  console.error(err);
  process.exit(1);
});
