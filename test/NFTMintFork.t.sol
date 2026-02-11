// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NFTMint} from "../src/NFTMint.sol";

/**
 * Fork tests: deploy and run core contract calls on each supported chain.
 * One test per chain so "forge test --match-contract NFTMintForkTest" verifies Base, Ethereum, Sepolia.
 * Uses public RPCs (no .env required).
 */
contract NFTMintForkTest is Test {
    address public owner = address(0xBEEF);
    address public user = address(0x1234);
    string constant NAME = "Fork NFT";
    string constant SYMBOL = "FNFT";
    string constant BASE_URI = "https://api.test.com/nft/";

    function _deployAndRunCalls() internal {
        vm.prank(owner);
        NFTMint nft = new NFTMint(NAME, SYMBOL, BASE_URI, 0.001 ether, 10);

        assertEq(nft.name(), NAME);
        assertEq(nft.symbol(), SYMBOL);
        assertEq(nft.owner(), owner);
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.maxSupply(), 10);
        assertEq(nft.mintPrice(), 0.001 ether);

        vm.deal(user, 10 ether);
        uint256 ownerBefore = owner.balance;

        vm.prank(user);
        nft.mint{value: 0.001 ether}();
        assertEq(nft.ownerOf(1), user);
        assertEq(nft.totalSupply(), 1);
        assertEq(owner.balance, ownerBefore + 0.001 ether);

        vm.prank(user);
        nft.mintBatch{value: 0.003 ether}(3);
        assertEq(nft.ownerOf(2), user);
        assertEq(nft.ownerOf(4), user);
        assertEq(nft.totalSupply(), 4);
        assertEq(owner.balance, ownerBefore + 0.004 ether);

        vm.prank(user);
        vm.expectRevert(NFTMint.InsufficientPayment.selector);
        nft.mint{value: 0.0001 ether}();
    }

    function test_Fork_Base() public {
        vm.createSelectFork("https://mainnet.base.org");
        _deployAndRunCalls();
    }

    function test_Fork_Ethereum() public {
        vm.createSelectFork("https://cloudflare-eth.com");
        _deployAndRunCalls();
    }

    function test_Fork_Sepolia() public {
        vm.createSelectFork("https://ethereum-sepolia.publicnode.com");
        _deployAndRunCalls();
    }
}
