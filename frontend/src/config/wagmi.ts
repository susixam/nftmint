import { getDefaultConfig, getDefaultWallets } from "@rainbow-me/rainbowkit";
import { zerionWallet } from "@rainbow-me/rainbowkit/wallets";
import { base, sepolia } from "wagmi/chains";

const { wallets: defaultWallets } = getDefaultWallets();
const walletsWithZerion = defaultWallets.map((group, i) =>
  i === 0
    ? { ...group, wallets: [...group.wallets, zerionWallet] }
    : group
);

export const config = getDefaultConfig({
  appName: "NFT Mint",
  projectId: import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || "YOUR_PROJECT_ID",
  chains: [base, sepolia],
  wallets: walletsWithZerion,
});
