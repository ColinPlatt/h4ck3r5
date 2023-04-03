// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/THE_LOST_GHOULS.sol";
import "src/ThresholdGhouls.sol";

import "src/ITurnstile.sol";

contract Distributor is Ownable {

    uint256 public constant MAX_MINT = 420;
    uint256 public constant MINT_COST = 169 ether;

    IERC721 public immutable ampliceGhouls;
    IERC721 public immutable cantofornians;
    IERC721 public immutable pepperHeads;
    ThresholdGhouls public immutable thresholdGhouls;

    address public constant FEE_RECEIVER = 0x0152DE0F97Da0E2c00F9c228A9beC048981646c9;

    bool public publicSaleOpen;
    
    THE_LOST_GHOULS public immutable lostGhouls;  // we can only set this once, if we mess up we need to redeploy and update the NFT contract
    
    // we group the bools to determine if an NFT has minted from both collections to save storage

    struct earlyMints {
        bool amplices;
        bool cantofornians;
        bool pepperHeads;
    }

    uint8 ampliceCounter;

    mapping(uint256 => earlyMints) public earlyMinted;
    mapping(address => bool) public earlyMintedByThresholds;
    mapping(address => uint8) public mintedByAddress;

    uint16[MAX_MINT] public ids;
    uint16 private index;
    
    constructor(
        address _lostGhouls,
        address _ampliceGhouls, //0x81996BD9761467202c34141B63B3A7F50D387B6a
        address _cantofornians, //0x22bC8C0B94e7E92914c5bb647D41B443ee3ABA5E
        address _pepperHeads, //0x842c628787E1064b9f27d74A84b10Fc59801E312
        address _thresholdGhouls
    ) {
        lostGhouls = THE_LOST_GHOULS(_lostGhouls);
        ampliceGhouls = IERC721(_ampliceGhouls);
        cantofornians = IERC721(_cantofornians);
        pepperHeads = IERC721(_pepperHeads);
        thresholdGhouls = ThresholdGhouls(_thresholdGhouls);
        if(block.chainid == 7700) ITurnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44).assign(lostGhouls.CSRID());
    }

    modifier isOpen(bool earlyMint) {
        if (earlyMint) {
            require(block.timestamp > 1680625200, "early mint not open");
        } else {
            require(block.timestamp > 1680798000 || publicSaleOpen, "public mint not open");
        }
        _;
    }

    function _payReceiver(uint256 amount) internal {
        bool success;

        address to = FEE_RECEIVER;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    // just in case fees get stuck we should be able to force them to pay the receiver wallet
    function forceWithdraw() public onlyOwner {
        _payReceiver(address(this).balance);
    }

    function _pickPseudoRandomUniqueId(uint256 seed) private returns (uint256 id) {
        uint256 len = ids.length - index++;
        require(len > 0, 'Mint closed');
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(seed, block.timestamp))) % len;
        id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
        ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
        ids[len - 1] = 0;
        id++;
    }

    function ampliceMint(uint256 id) public payable isOpen(true) {
        require(ampliceCounter < 100, "Too many amplices.");
        require(msg.sender == ampliceGhouls.ownerOf(id), "Caller not owner of Id");
        require(!earlyMinted[id].amplices, "Already claimed");
        require(msg.value == MINT_COST, "Insufficient payment");
        _payReceiver(msg.value);
        ampliceCounter++;
        mintedByAddress[msg.sender]++;

        earlyMinted[id].amplices = true;

        lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)*id));

    }

    function cantofornianMint(uint256 id) public payable isOpen(true) {
        require(msg.sender == cantofornians.ownerOf(id), "Caller not owner of Id");
        require(!earlyMinted[id].cantofornians, "Already claimed");
        require(msg.value == MINT_COST, "Insufficient payment");
        _payReceiver(msg.value);
        mintedByAddress[msg.sender]++;

        earlyMinted[id].cantofornians = true;

        lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)*id));

    }

    function pepperHeadsMint(uint256 id) public payable isOpen(true) {
        require(msg.sender == pepperHeads.ownerOf(id), "Caller not owner of Id");
        require(!earlyMinted[id].pepperHeads, "Already claimed");
        require(msg.value == MINT_COST, "Insufficient payment");
        _payReceiver(msg.value);
        mintedByAddress[msg.sender]++;

        earlyMinted[id].pepperHeads = true;

        lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)*id));

    }

    function thresholdMint() public payable isOpen(true) {
        require(thresholdGhouls._isListed(msg.sender), "Caller not eligible");
        require(!earlyMintedByThresholds[msg.sender], "Already claimed");
        require(msg.value == MINT_COST, "Insufficient payment");
        _payReceiver(msg.value);
        mintedByAddress[msg.sender]++;

        earlyMintedByThresholds[msg.sender] = true;

        lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)));

    }

    function publicMint(uint8 amt) public payable isOpen(false) {
        // owner not subjected to maxes
        if(msg.sender != owner()){
            require(amt <= 5 , "Max 5 mints");
            require(mintedByAddress[msg.sender]+amt <= 5, "Max 5 per address");
            require(msg.value == amt * MINT_COST, "Insufficient payment");
            _payReceiver(msg.value);
            mintedByAddress[msg.sender] += amt;
        }

        for(uint256 i = 0; i<amt; ++i) {

            lostGhouls.mintFromDistributor(msg.sender, _pickPseudoRandomUniqueId(uint160(msg.sender)*i));
        }

    }

    function openPublic() public onlyOwner() {
        publicSaleOpen = true;
    }

}