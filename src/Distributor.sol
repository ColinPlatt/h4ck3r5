// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/THE_LOST_GHOULS.sol";

import "src/ITurnstile.sol";

contract Distributor is Ownable {

    uint256 public constant MAX_MINT = 2000;
    uint256 public constant MINT_COST = 269 ether;

    IERC721 public immutable ampliceGhouls;

    bool public publicSaleOpen;
    
    THE_LOST_GHOULS public immutable lostGhouls;  // we can only set this once, if we mess up we need to redeploy and update the NFT contract
    
    // we group the bools to determine if an NFT has minted from both collections to save storage

    mapping(uint256 => bool) public earlyMintedByIds;
    mapping(address => uint8) public mintedByAddress;

    uint16[2000] public ids;
    uint16 private index;
    
    constructor(
        address _lostGhouls,
        address _ampliceGhouls
    ) {
        lostGhouls = THE_LOST_GHOULS(_lostGhouls);
        ampliceGhouls = IERC721(_ampliceGhouls);
        if(block.chainid == 7700) ITurnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44).assign(lostGhouls.CSRID());
    }

    // Owner can withdraw CANTO sent to this contract
    function withdraw(uint256 amount) external onlyOwner{
        bool success;
        address to = owner();

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    function _pickPseudoRandomUniqueId(uint256 seed) private returns (uint256 id) {
        uint256 len = ids.length - index++;
        require(len > 0, 'Mint closed');
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(seed, block.timestamp))) % len;
        id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
        ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
        ids[len - 1] = 0;
    }

    function ampliceMint(uint256 id) public payable {
        require(msg.sender == ampliceGhouls.ownerOf(id), "Caller not owner of Id");
        require(!earlyMintedByIds[id], "Already claimed");
        require(msg.value >= MINT_COST, "Insufficient payment");
        mintedByAddress[msg.sender]++;

        earlyMintedByIds[id] = true;

        lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)*id)+1);

    }

    function publicMint(uint8 amt) public payable {
        // owner not subjected to maxes
        if(msg.sender != owner()){
            require(publicSaleOpen, "Not yet open to public");
            require(amt <= 5 , "Max 5 mints");
            require(mintedByAddress[msg.sender]+amt <= 5, "Max 5 per address");
            require(msg.value >= amt * MINT_COST, "Insufficient payment");
            mintedByAddress[msg.sender] += amt;
        }

        for(uint256 i = 0; i<amt; ++i) {

            lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)*i)+1);
        }

    }

    function openPublic() public onlyOwner() {
        publicSaleOpen = true;
    }

}