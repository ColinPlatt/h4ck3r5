// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";
import "src/THE_LOST_GHOULS.sol";
import "src/Distributor.sol";
import "src/ThresholdGhouls.sol";

contract THE_LOST_GHOULS_Fork_Test is Test {
    using stdJson for string;

    THE_LOST_GHOULS public nft;
    Distributor public distributor;
    ThresholdGhouls public threshold;

    string RPC = vm.envString("RPC_URL");
    uint256 fork;

    address dep = address(0xad1);

    address[] aList0;
    address[] aList1;
    bytes addrList0;
    bytes addrList1;
    
    function setUp() public {
        fork = vm.createSelectFork(RPC);
        vm.warp(1680625200+1);

        vm.startPrank(dep);

            nft = new THE_LOST_GHOULS("www.test.com/");
            threshold = new ThresholdGhouls();
            distributor = new Distributor(address(nft), address(0x81996BD9761467202c34141B63B3A7F50D387B6a), address(0x22bC8C0B94e7E92914c5bb647D41B443ee3ABA5E), address(0x842c628787E1064b9f27d74A84b10Fc59801E312), address(threshold));
            nft.setDistributor(address(distributor));

            (addrList0, addrList1) = _loadJsonLists();

            threshold.loadPtr(addrList0);
            threshold.loadPtr(addrList1);

        vm.stopPrank();
    }

    function _loadJsonLists() internal returns (bytes memory list0, bytes memory list1) {
        string memory root = vm.projectRoot();
        string memory path0 = string.concat(root, "/test/snapshot/sortedAddresses_0.json");
        string memory json0 = vm.readFile(path0);

        string memory path1 = string.concat(root, "/test/snapshot/sortedAddresses_1.json");
        string memory json1 = vm.readFile(path1);

        aList0 = json0.readAddressArray(".address");
        aList1 = json1.readAddressArray(".address");

        for(uint256 i = 0; i < aList0.length; i++) {
            list0 = abi.encodePacked(list0, bytes20(aList0[i]));
            list1 = abi.encodePacked(list1, bytes20(aList1[i]));
        }

        //emit log_bytes(list0);


    }


    function testAllEarlyMints() public {

        IERC721 ampliceNft = IERC721(0x81996BD9761467202c34141B63B3A7F50D387B6a);
        IERC721 dlNft = IERC721(0x22bC8C0B94e7E92914c5bb647D41B443ee3ABA5E);
        IERC721 peppersNft = IERC721(0x842c628787E1064b9f27d74A84b10Fc59801E312);


        address ampliceHolder = ampliceNft.ownerOf(69);
        vm.deal(ampliceHolder, 1_000 ether);
        vm.startPrank(ampliceHolder);
            distributor.ampliceMint{value: 169 ether}(69);
        vm.stopPrank();

        address dlHolder = dlNft.ownerOf(69);
        vm.deal(dlHolder, 1_000 ether);
        vm.startPrank(dlHolder);
            distributor.cantofornianMint{value: 169 ether}(69);
        vm.stopPrank();

        address pepperHolder = peppersNft.ownerOf(69);
        vm.deal(pepperHolder, 1_000 ether);
        vm.startPrank(pepperHolder);
            distributor.pepperHeadsMint{value: 169 ether}(69);
        vm.stopPrank();

        address threshHolder_0 = address(0x000000000000000000000000000000000000dEaD);
        vm.deal(threshHolder_0, 1_000 ether);
        vm.startPrank(threshHolder_0);
            distributor.thresholdMint{value: 169 ether}();
        vm.stopPrank();

        address threshHolder_1 = address(0xFFE6F86b7f19fF2Efc0CC0dF310Cc7822AF5a708);
        vm.deal(threshHolder_1, 1_000 ether);
        vm.startPrank(threshHolder_1);
            distributor.thresholdMint{value: 169 ether}();
        vm.stopPrank();
        
    }

    function testThresholdManyMints() public {

        for(uint256 i = 0; i< 210; i++) {
            address a0 = aList0[i+70];
            address a1 = aList1[i+140];

            vm.deal(a0, 1_000 ether);
            vm.startPrank(a0);
                distributor.thresholdMint{value: 169 ether}();
            vm.stopPrank();

            vm.deal(a1, 1_000 ether);
            vm.startPrank(a1);
                distributor.thresholdMint{value: 169 ether}();
            vm.stopPrank();

        }

        assertEq(nft.totalSupply(), 420, "totalSupply");
        
    }


    


}
