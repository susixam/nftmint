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
  const rpcUrl = process.env.SEPOLIA_RPC_URL || "https://rpc.sepolia.org";
  const name = process.env.NFT_NAME || "NFT Mint";
  const symbol = process.env.NFT_SYMBOL || "MINT";
  const baseURI =
    process.env.BASE_URI || "https://api.example.com/metadata/";
  const mintPriceWei = process.env.MINT_PRICE
    ? ethers.parseEther(process.env.MINT_PRICE)
    : ethers.parseEther("0.001");

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

  console.log("Deploying NFTMint to Sepolia...");
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);
  const nft = await factory.deploy(name, symbol, baseURI, mintPriceWei);
  await nft.waitForDeployment();
  const address = await nft.getAddress();
  console.log("NFTMint deployed at:", address);

  const batchValue = mintPriceWei * 5n;
  console.log("Minting 5 NFTs...");
  const tx = await nft.mintBatch(5, { value: batchValue });
  await tx.wait();
  console.log("Minted 5 NFTs to deployer");
  console.log("Done!");
}

deploy().catch((err) => {
  console.error(err);
  process.exit(1);
});
