// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/token/onft/ONFT721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Interface of the UniversalONFT standard
contract AlphaWolf is ONFT721, Pausable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    uint public nextMintId;
    uint public maxMintId;
    

    Counters.Counter private _tokenIdCounter;

    uint256 public MINT_PRICE = 0.01 ether;
    string public baseExtension = ".json";
    uint256 public maxSupply = 10000;

    string private baseURI = "ipfs://QmdZivUMzM3SYfCqQg1tEfVWdP8vNAtHpDENAwnCnZnEDM/";

    /// @notice Constructor for the UniversalONFT
    /// @param _name the name of the token
    /// @param _symbol the token symbol
    /// @param _layerZeroEndpoint handles message transmission across chains
    /// @param _startMintId the starting mint number on this chain
    /// @param _endMintId the max number of mints on this chain
    constructor(string memory _name, string memory _symbol, uint256 _minGasToTransfer, address _layerZeroEndpoint, uint _startMintId, uint _endMintId) ONFT721(_name, _symbol, _minGasToTransfer, _layerZeroEndpoint) {
        _tokenIdCounter.increment();
        nextMintId = _startMintId;
        maxMintId = _endMintId;
            
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

    /// @notice Mint your ONFT
    function mint(address to, uint256 amount) external payable {
        require(!paused(), "Contract is paused, please try again later");
        require(nextMintId <= maxMintId, "UniversalONFT721: max mint limit reached");
        require(amount > 0);
        

        if (msg.sender != owner()) {
            // require(amount <= 3, "You can only mint 3 at once.");
            require(msg.value >= MINT_PRICE * amount);
        }

        uint newId = nextMintId;
        nextMintId++;

        for (uint256 i = 1; i <= amount; i++) {
            _safeMint(msg.sender, newId);

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
