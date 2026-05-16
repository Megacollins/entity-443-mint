// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Entity443Collection is ERC721URIStorage, Ownable {
    uint256 public constant MAX_SUPPLY = 69;
    uint256 public constant MINT_PRICE = 2_000_000; // 2 USDC (6 decimals)

    IERC20 public immutable usdc;

    uint256 private _tokenIdCounter;
    mapping(address => bool) public hasMinted;
    string[3] public tokenURIs;

    event Minted(address indexed to, uint256 indexed tokenId, string tokenURI);

    constructor(string[3] memory _tokenURIs)
        ERC721("ENTITY_443 Collection", "E443")
        Ownable(msg.sender)
    {
        // USDC contract on Arc Testnet
        usdc = IERC20(0x3600000000000000000000000000000000000000);
        tokenURIs = _tokenURIs;
    }

    function mint() external {
        require(!hasMinted[msg.sender], "One mint per wallet");
        require(_tokenIdCounter < MAX_SUPPLY, "Sold out");
        require(
            usdc.transferFrom(msg.sender, address(this), MINT_PRICE),
            "USDC payment failed"
        );

        hasMinted[msg.sender] = true;
        uint256 tokenId = _tokenIdCounter++;
        string memory uri = tokenURIs[tokenId % 3];

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit Minted(msg.sender, tokenId, uri);
    }

    function totalMinted() external view returns (uint256) {
        return _tokenIdCounter;
    }

    function remaining() external view returns (uint256) {
        return MAX_SUPPLY - _tokenIdCounter;
    }

    function withdraw() external onlyOwner {
        uint256 balance = usdc.balanceOf(address(this));
        require(balance > 0, "Nothing to withdraw");
        usdc.transfer(owner(), balance);
    }
}
