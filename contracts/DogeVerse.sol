//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


contract DogeVerse is ERC721Enumerable, Ownable {
    using Strings for uint256;


    string baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.069 ether;
    uint256 public maxSupply = 8888;
    uint256 public freeMintLimit = 800;
    uint256 public maxMintAmount = 15;
    uint256 public limitPerWallet = 1;
    string public notRevealedUri;
    bool public paused = true;
    bool public revealed = false;



    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }


  // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

  // public

    function mint(uint256 _mintAmount) public payable {
        require(!paused);
        uint256 supply = totalSupply();
        require(_mintAmount > 0);
        uint256 ownerTokenCount = balanceOf(msg.sender);

        if (supply <= freeMintLimit) {
            require(supply + _mintAmount <= freeMintLimit);
            require(ownerTokenCount < limitPerWallet);
            require(_mintAmount <= limitPerWallet);
        } else {
            require(_mintAmount <= maxMintAmount);
            require(supply + _mintAmount <= maxSupply);
            require(msg.value >= cost * _mintAmount, "Not enough funds");  
        }
        
        for(uint256 i = 1; i <= _mintAmount; i++) {
        _safeMint(msg.sender, supply + i);
        }
    }
    

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
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
        
        if(revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }


    //only owner
    function reveal() public onlyOwner {
        revealed = true;
    }


    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }


    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }


    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }


    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }


    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }


    function pause(bool _state) public onlyOwner {
        paused = _state;
    }


    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}