// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {NFTMint} from "../src/NFTMint.sol";

contract DeployScript is Script {
    function run() external {
        string memory pkStr = vm.envString("PRIVATE_KEY");
        bytes memory pkBytes = bytes(pkStr);
        bool hasHexPrefix = pkBytes.length >= 2 && pkBytes[0] == "0" && (pkBytes[1] == "x" || pkBytes[1] == "X");
        uint256 deployerPrivateKey = hasHexPrefix
            ? vm.parseUint(pkStr)
            : vm.parseUint(string(abi.encodePacked("0x", pkStr)));

        string memory name = vm.envOr("NFT_NAME", string("NFT Mint"));
        string memory symbol = vm.envOr("NFT_SYMBOL", string("MINT"));
        string memory baseURI = vm.envOr(
            "BASE_URI",
            string("https://api.example.com/metadata/")
        );
        uint256 mintPrice = vm.envOr("MINT_PRICE", uint256(0.001 ether));
        uint256 maxSupply = vm.envOr("MAX_SUPPLY", uint256(5));
        bool mintOnDeploy = vm.envOr("MINT_ON_DEPLOY", uint256(0)) != 0;

        vm.startBroadcast(deployerPrivateKey);

        NFTMint nft = new NFTMint(name, symbol, baseURI, mintPrice, maxSupply);

        if (mintOnDeploy) {
            nft.mintBatch{value: mintPrice * maxSupply}(maxSupply);
            console.log("Minted", maxSupply, "NFTs to deployer");
        }

        console.log("NFTMint deployed at:", address(nft));

        vm.stopBroadcast();
    }
}
