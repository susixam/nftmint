// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NFTMint} from "../src/NFTMint.sol";

contract NFTMintTest is Test {
    NFTMint public nft;

    address public owner = address(1);
    address public user = address(2);

    string constant NAME = "Test NFT";
    string constant SYMBOL = "TNFT";
    string constant BASE_URI = "https://api.test.com/nft/";

    function setUp() public {
        vm.prank(owner);
        nft = new NFTMint(NAME, SYMBOL, BASE_URI, 0.001 ether, 5);
    }

    function test_InitialState() public view {
        assertEq(nft.name(), NAME);
        assertEq(nft.symbol(), SYMBOL);
        assertEq(nft.owner(), owner);
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.maxSupply(), 5);
        assertEq(nft.mintPrice(), 0.001 ether);
    }

    function test_Mint_Success() public {
        vm.deal(user, 1 ether);
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(user);
        nft.mint{value: 0.001 ether}();

        assertEq(nft.ownerOf(1), user);
        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.tokenURI(1), string.concat(BASE_URI, "1.json"));
        assertEq(owner.balance, ownerBalanceBefore + 0.001 ether);
    }

    /// @notice When a user mints, deployer (owner) receives the mint payment immediately
    function test_DeployerReceivesEthWhenUserMints() public {
        vm.deal(user, 1 ether);
        uint256 deployerBefore = owner.balance;
        uint256 userBefore = user.balance;

        vm.prank(user);
        nft.mint{value: 0.001 ether}();

        assertEq(owner.balance, deployerBefore + 0.001 ether, "Deployer should receive 0.001 ETH");
        assertEq(user.balance, userBefore - 0.001 ether, "User should pay 0.001 ETH");
        assertEq(nft.ownerOf(1), user, "User should own the minted NFT");
    }

    function test_Mint_InsufficientPayment() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert(NFTMint.InsufficientPayment.selector);
        nft.mint{value: 0.0005 ether}();
    }

    function test_MintBatch_Success() public {
        vm.deal(user, 1 ether);
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(user);
        nft.mintBatch{value: 0.005 ether}(5);

        assertEq(nft.ownerOf(1), user);
        assertEq(nft.ownerOf(5), user);
        assertEq(nft.balanceOf(user), 5);
        assertEq(nft.totalSupply(), 5);
        assertEq(owner.balance, ownerBalanceBefore + 0.005 ether);
    }

    function test_MintBatch_InsufficientPayment() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert(NFTMint.InsufficientPayment.selector);
        nft.mintBatch{value: 0.002 ether}(5);
    }

    function test_MintBatch_ExceedsMaxSupply() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert(NFTMint.MaxSupplyReached.selector);
        nft.mintBatch{value: 0.01 ether}(6);
    }

    function test_MintBatch_ZeroAmount_Reverts() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert(NFTMint.ZeroAmount.selector);
        nft.mintBatch{value: 0}(0);
    }

    function test_Constructor_MaxSupplyZero_Reverts() public {
        vm.expectRevert(NFTMint.InvalidMaxSupply.selector);
        new NFTMint(NAME, SYMBOL, BASE_URI, 0.001 ether, 0);
    }

    function test_SetMintPrice_Overflow_Reverts() public {
        vm.prank(owner);
        vm.expectRevert(NFTMint.InvalidMintPrice.selector);
        nft.setMintPrice(uint256(type(uint128).max) + 1);
    }

    function test_Mint_MaxSupply() public {
        vm.deal(user, 1 ether);
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(user);
            nft.mint{value: 0.001 ether}();
        }

        vm.prank(user);
        vm.expectRevert(NFTMint.MaxSupplyReached.selector);
        nft.mint{value: 0.001 ether}();
    }

    function test_SetBaseURI_OnlyOwner() public {
        vm.prank(owner);
        nft.setBaseURI("https://new-uri.com/");

        vm.deal(user, 1 ether);
        vm.prank(user);
        nft.mint{value: 0.001 ether}();

        assertEq(nft.tokenURI(1), "https://new-uri.com/1.json");
    }

    function test_SetBaseURI_RevertWhenNotOwner() public {
        vm.prank(user);
        vm.expectRevert();
        nft.setBaseURI("https://new-uri.com/");
    }

    function test_SetMintPrice_OnlyOwner() public {
        vm.prank(owner);
        nft.setMintPrice(0.002 ether);
        assertEq(nft.mintPrice(), 0.002 ether);

        vm.deal(user, 1 ether);
        vm.prank(user);
        nft.mint{value: 0.002 ether}();
        assertEq(nft.ownerOf(1), user);
    }

    function test_SetMintPrice_FreeMint() public {
        vm.prank(owner);
        nft.setMintPrice(0);
        vm.deal(user, 1 ether);
        vm.prank(user);
        nft.mint{value: 0}();
        assertEq(nft.ownerOf(1), user);
    }

    function test_Withdraw() public {
        vm.deal(address(nft), 0.001 ether);
        uint256 balanceBefore = owner.balance;
        vm.prank(owner);
        nft.withdraw();
        assertEq(owner.balance, balanceBefore + 0.001 ether);
    }

    function test_Withdraw_RevertWhenNotOwner() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        nft.mint{value: 0.001 ether}();

        vm.prank(user);
        vm.expectRevert();
        nft.withdraw();
    }
}
