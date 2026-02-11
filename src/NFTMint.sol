// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTMint is ERC721, Ownable {
    using Strings for uint256;
    error InsufficientPayment();
    error MaxSupplyReached();
    error WithdrawFailed();
    error ForwardFailed();
    error ZeroAmount();
    error InvalidMintPrice();
    error InvalidMaxSupply();

    // Packed into one slot (saves ~20k gas at deploy, cheaper reads)
    uint64 private _nextTokenId;
    uint64 private _maxSupply;
    uint128 public mintPrice;

    string private _baseTokenURI;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_,
        uint256 mintPrice_,
        uint256 maxSupply_
    ) ERC721(name_, symbol_) Ownable() {
        if (maxSupply_ == 0) revert InvalidMaxSupply();
        if (mintPrice_ > type(uint128).max) revert InvalidMintPrice();
        _baseTokenURI = baseTokenURI_;
        mintPrice = uint128(mintPrice_);
        _maxSupply = uint64(maxSupply_);
        // _nextTokenId left as 0; first mint will use tokenId 1
    }

    function maxSupply() external view returns (uint256) {
        return uint256(_maxSupply);
    }

    function mint() external payable {
        if (msg.value < mintPrice) revert InsufficientPayment();

        uint64 next = _nextTokenId;
        uint64 max = _maxSupply;
        unchecked {
            uint256 tokenId = uint256(next) + 1;
            if (tokenId > max) revert MaxSupplyReached();
            _nextTokenId = uint64(tokenId);
            _safeMint(msg.sender, tokenId);
        }
        _forwardMintPaymentToOwner(msg.value);
    }

    function mintBatch(uint256 amount) external payable {
        if (amount == 0) revert ZeroAmount();
        if (msg.value < mintPrice * amount) revert InsufficientPayment();

        uint64 next = _nextTokenId;
        uint64 max = _maxSupply;
        uint256 startId = uint256(next) + 1;
        if (amount > max - next) revert MaxSupplyReached(); // startId + amount - 1 <= max

        unchecked {
            uint256 endId = startId + amount - 1;
            for (uint256 i = 0; i < amount; ) {
                _safeMint(msg.sender, startId + i);
                ++i;
            }
            _nextTokenId = uint64(endId);
        }
        _forwardMintPaymentToOwner(msg.value);
    }

    function _forwardMintPaymentToOwner(uint256 amount) private {
        if (amount == 0) return;
        address o = owner();
        (bool success, ) = o.call{value: amount}("");
        if (!success) revert ForwardFailed();
    }

    function totalSupply() external view returns (uint256) {
        return _nextTokenId; // already uint64, zero-cost cast to uint256
    }

    function setBaseURI(string calldata baseTokenURI_) external onlyOwner {
        _baseTokenURI = baseTokenURI_;
    }

    function setMintPrice(uint256 mintPrice_) external onlyOwner {
        if (mintPrice_ > type(uint128).max) revert InvalidMintPrice();
        mintPrice = uint128(mintPrice_);
    }

    function withdraw() external onlyOwner {
        address owner_ = owner();
        (bool success, ) = owner_.call{value: address(this).balance}("");
        if (!success) revert WithdrawFailed();
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseTokenURI;
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
            : "";
    }
}
