// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/token/onft/IONFT721.sol";
import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/token/onft/ONFT721Core.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// NOTE: this ONFT contract has no public minting logic.
// must implement your own minting logic in child classes
contract AlphaWolf is Ownable, ONFT721Core, ERC721Enumerable, IONFT721, Pausable {
        using Counters for Counters.Counter;
        using Strings for uint256;
    
    Counters.Counter private _tokenIdCounter;

        uint256 public MINT_PRICE = 0.01 ether;
        string public baseExtension = ".json";
        uint256 public maxSupply = 10000;

    string private baseURI = "ipfs://QmdZivUMzM3SYfCqQg1tEfVWdP8vNAtHpDENAwnCnZnEDM/";
    
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _minGasToTransfer, 
        address _lzEndpoint) 
        
    ERC721(
        _name, 
        _symbol) 
    ONFT721Core(
        _minGasToTransfer, 
        _lzEndpoint) {
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

    function mint(uint256 amount) public payable {
        require(!paused(), "Contract is paused, please try again later");
        require(amount > 0);
        uint256 supply = totalSupply();
        require(supply + amount <= maxSupply);

        if (msg.sender != owner()) {
            // require(amount <= 3, "You can only mint 3 at once.");
            require(msg.value >= MINT_PRICE * amount);
        }

        for (uint256 i = 1; i <= amount; i++) {
            _safeMint(msg.sender, supply + i);
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721Core, ERC721Enumerable, IERC165) returns (bool) {
        return interfaceId == type(IONFT721).interfaceId || super.supportsInterface(interfaceId);
    }

    function _debitFrom(address _from, uint16, bytes memory, uint _tokenId) internal virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        require(ERC721.ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");
        _transfer(_from, address(this), _tokenId);
    }

    function _creditTo(uint16, address _toAddress, uint _tokenId) internal virtual override {
        require(!_exists(_tokenId) || (_exists(_tokenId) && ERC721.ownerOf(_tokenId) == address(this)));
        if (!_exists(_tokenId)) {
            _safeMint(_toAddress, _tokenId);
        } else {
            _transfer(address(this), _toAddress, _tokenId);
        }
    }
}
