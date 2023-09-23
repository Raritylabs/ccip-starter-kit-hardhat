// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AlphaWolf is ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    uint256 public MINT_PRICE = 0.01 ether;
    string public baseExtension = ".json";
    uint256 public maxSupply = 10000;

    string private baseURI = "ipfs://QmdZivUMzM3SYfCqQg1tEfVWdP8vNAtHpDENAwnCnZnEDM/";

    constructor() ERC721("Alpha Wolf", "AWC") {
        _tokenIdCounter.increment();
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public payable {
        require(!paused(), "Contract is paused, please try again later");
        require(amount > 0);
        uint256 supply = totalSupply();
        require(supply + amount <= maxSupply);

        if (msg.sender != owner()) {
            // require(amount <= 3, "You can only mint 3 at once.");
            require(msg.value >= MINT_PRICE * amount);
        }

        for (uint256 i = 1; i <= amount; i++) {
            _safeMint(to, supply + i);
        }

        require(payable(owner()).send(address(this).balance));
    }

    function withdraw() public onlyOwner() {
        require(address(this).balance > 0, "Balance is zero");
        payable(owner()).transfer(address(this).balance);
    }

    function setMintPrice(uint256 newMintPrice) external onlyOwner {
        MINT_PRICE = newMintPrice;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }
}
