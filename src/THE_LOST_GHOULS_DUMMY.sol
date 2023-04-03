// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "src/ITurnstile.sol";


contract THE_LOST_GHOULS_DUMMY is ERC721Enumerable, ERC2981, Ownable {
    
    uint256 public constant MAX_ID = 420;

    address private ghoulsMultiSig = 0x4C9046aa11eD7a7D336CA6c6dCD148181c9304D3;
    string public baseUri;
    address public distributor;

    //uint256 public immutable CSRID;

    constructor(string memory _setBaseUri) 
        ERC721(
            "THE-LOST-GHOULS",
            unicode"G̴̢̢̡̨̢̨̘̺͔̺̘̙̻̟͇͔͖̹̠͔̟̗͍̣̱̺̱̭̦͕̜̲̰͔͎̟̳̙̩̤̻̹̞̮̟͈̬̯̺̪͍͓̬̗̻͚͎̑̀͗̔͒͆̾̅͂̄̿̀͑̈́̔̓̽͐͊̐̃̉̐͗̏̏̑̒̌̀͌̑̈́̓̆́͂̉̀̀̐͗͛͐̕̚͘̕͠͝͝͝͠ͅḨ̸̭̣͉͎̬͎̼̪͍̪̜̺̜̿͐͊̔̍́ͅĻ̸̡̡̛̟̘͙͈͙̙̺̠͍̮̫̬̗̱̳̬̱̬̘̪̘͇͓͈̠̺̞̯͖̘̱͉̬̟̬̗̝̲͎͛̑̉̀̔̏̀̇͆͌̒̈́̓͒́̈́̈̈́͐͌͑͂̔̅̽͑͒̀̚͜͝Š̶̡̛̩̗̖̖̣͓̭̣͕̬̟͕͕̙̘̃͗͐̄͆̈́͐́͆͛̏̒̌̃͐͌̅̋̽̑̆͊͛̄͒̔̋̈͆͐̂̈́̈́̌̅̈͊̽͊̐̾͋̆̓̔͂͆̕̕̚̚͝͝͝͠͠͠"
        ){
            baseUri = _setBaseUri;
            //_setDefaultRoyalty(ghoulsMultiSig, uint96(690));
            //CSRID = block.chainid == 7700 ? ITurnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44).register(ghoulsMultiSig) : 0;
            distributor = msg.sender;
        }

    modifier onlyDistributor() {
        require(distributor == _msgSender(), "THE-LOST-GHOULS: caller is not the distributor");
        _;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")) : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    // minting should be called from the distributor contract which assigns an ID and gives it to the caller
    function mintFromDistributor(address to, uint256 id) external onlyDistributor {
        require(id<=MAX_ID && id != 0, "THE-LOST-GHOULS: invalid ID");
        _mint(to, id);
    }

    // including this in the dummy
    function burn(uint256 id) public {
        _burn(id);
    }

    ////////////////////////////////// Owner only functions //////////////////////////////////

    function updateRoyalties(address newghoulsMultiSig, uint96 newNumerator) external onlyOwner {
        _setDefaultRoyalty(newghoulsMultiSig, newNumerator);
    }

    function setDistributor(address newDistributor) external onlyOwner {
        distributor = newDistributor;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseUri = newBaseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC2981) returns (bool) {
        return  interfaceId == type(IERC721Enumerable).interfaceId ||
                interfaceId == type(IERC2981).interfaceId ||
                super.supportsInterface(interfaceId);
    }
}
