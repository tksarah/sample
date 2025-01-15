// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
 
contract DemoNFT is ERC721, ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 private _nextTokenId;
    mapping(address => uint256[]) private listTokenId;
    string private baseURI;

    constructor(
        address initialOwner,
        string memory baseURI_
    ) ERC721("DemoNFT", "DNFT") Ownable(initialOwner) {
        setBaseURI(baseURI_);
    }

    /// @dev the function can be called by anyone
    function safeMint(address to) public {
        uint256 tokenId = _nextTokenId++;
        uint256[] storage _listTokenId = listTokenId[to];
        _listTokenId.push(tokenId);
        _safeMint(to, tokenId);
    }

    function getListTokenId(address _owner) public view returns(uint256[] memory){
        return listTokenId[_owner];
    }

    // Helper function to remove tokenId from array
    function _removeTokenFromList(address owner, uint256 tokenId) internal {
        uint256[] storage tokens = listTokenId[owner];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                // Move the last element to the position we want to delete
                tokens[i] = tokens[tokens.length - 1];
                // Remove the last element
                tokens.pop();
                break;
            }
        }
    }

    // Override _update to handle listTokenId updates during transfers
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        address from = super._update(to, tokenId, auth);
        
        // If this is a transfer (not a mint or burn)
        if (from != address(0) && to != address(0)) {
            // Remove tokenId from sender's list
            _removeTokenFromList(from, tokenId);
            // Add tokenId to recipient's list
            listTokenId[to].push(tokenId);
        }
        // If this is a burn
        else if (to == address(0)) {
            _removeTokenFromList(from, tokenId);
        }
        
        return from;
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory baseURI_) public {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI_ = _baseURI();

        // Since this collection only uses a single metadata for all NFTs that have been minted, we will return a unique uri for those
        uint256 uniqueId = 0;
        return string.concat(baseURI_, uniqueId.toString(), ".json");
    }

}