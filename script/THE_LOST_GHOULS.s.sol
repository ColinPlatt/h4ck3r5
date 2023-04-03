// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/THE_LOST_GHOULS.sol";
import "src/THE_LOST_GHOULS_DUMMY.sol";
import "src/Distributor.sol";
import "src/Distributor_DUMMY.sol";
import "src/ThresholdGhouls.sol";

contract THE_LOST_GHOULS_Threshold_Script is Script {

    ThresholdGhouls public threshold;

    bytes addrList0;
    bytes addrList1;

    function _loadJsonLists() internal returns (bytes memory list0, bytes memory list1) {
        string memory root = vm.projectRoot();
        string memory path0 = string.concat(root, "/test/snapshot/sortedBytes0.txt");
        string memory json0 = vm.readFile(path0);

        string memory path1 = string.concat(root, "/test/snapshot/sortedBytes1.txt");
        string memory json1 = vm.readFile(path1);

        list0 = vm.parseBytes(json0);
        list1 = vm.parseBytes(json1);

    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        (addrList0, addrList1) = _loadJsonLists();

        vm.startBroadcast(deployerPrivateKey);

            threshold = new ThresholdGhouls();

            threshold.loadPtr(addrList0);
            threshold.loadPtr(addrList1);

        vm.stopBroadcast();
    }
}

// Threshold = 0xee97c7b1bD2fF60740DdfC859609d3D24Ae7E36F
// forge script script/THE_LOST_GHOULS.s.sol:THE_LOST_GHOULS_Threshold_Script --rpc-url $RPC_URL --broadcast --slow -vvvv
//forge verify-contract 0xee97c7b1bD2fF60740DdfC859609d3D24Ae7E36F src/ThresholdGhouls.sol:ThresholdGhouls --chain-id 7700 --verifier sourcify

contract THE_LOST_GHOULS_NFT_Script is Script {

    THE_LOST_GHOULS public nft;
    Distributor public distributor;

    address amplice = 0x81996BD9761467202c34141B63B3A7F50D387B6a;
    address cantofornians = 0x22bC8C0B94e7E92914c5bb647D41B443ee3ABA5E;
    address pepperHeads = 0x842c628787E1064b9f27d74A84b10Fc59801E312;
    address threshold = 0xee97c7b1bD2fF60740DdfC859609d3D24Ae7E36F;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
            
            nft = new THE_LOST_GHOULS("ipfs://bafybeibpqmur3h7bxzdjep5k5ywegh4nsqkqjjaom23vg2wkrabtljidly/RETRIEVED_");
            distributor = new Distributor(
                address(nft), 
                amplice, 
                cantofornians, 
                pepperHeads, 
                threshold
            );
            nft.setDistributor(address(distributor));

        vm.stopBroadcast();
    }
}


contract THE_LOST_GHOULS_NFT_DUMMY_Script is Script {

    THE_LOST_GHOULS_DUMMY public nft;
    Distributor_DUMMY public distributor;


    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address amplice = 0x81996BD9761467202c34141B63B3A7F50D387B6a;
        address cantofornians = 0x22bC8C0B94e7E92914c5bb647D41B443ee3ABA5E;
        address pepperHeads = 0x842c628787E1064b9f27d74A84b10Fc59801E312;
        address threshold = 0xee97c7b1bD2fF60740DdfC859609d3D24Ae7E36F;


        vm.startBroadcast(deployerPrivateKey);

            nft = THE_LOST_GHOULS_DUMMY(0xCa95CDCb55DA99f6fc88CB4e190c71c5402D553B);
            
            //nft.setBaseURI("https://lime-acute-guppy-488.mypinata.cloud/ipfs/bafybeibpqmur3h7bxzdjep5k5ywegh4nsqkqjjaom23vg2wkrabtljidly/RETRIEVED_");
            
            //nft.burn(1);
            distributor = new Distributor_DUMMY(
                address(nft), 
                amplice, 
                cantofornians, 
                pepperHeads, 
                threshold
            );
            nft.setDistributor(address(distributor));


            //nft = new THE_LOST_GHOULS_DUMMY("ipfs://bafybeibpqmur3h7bxzdjep5k5ywegh4nsqkqjjaom23vg2wkrabtljidly/RETRIEVED_");
            distributor.publicMint{value: 0.00169 ether}(1);

        vm.stopBroadcast();
    }
}



// forge script script/THE_LOST_GHOULS.s.sol:THE_LOST_GHOULS_NFT_DUMMY_Script --rpc-url $RPC_URL --broadcast --slow -vvvv



// forge script script/IWLL.s.sol:IWLLScript --rpc-url $RPC_URL --broadcast --slow -vvvv
// forge verify-contract 0x9aB79714AB7A4FB72408d6EA9d2C92Bb86beA2c0 src/IW_LOST_LEVELS.sol:IW_LOST_LEVELS --constructor-args $(cast abi-encode "constructor(string memory)" "ipfs://bafybeidrm4vuu2qjnswxseypkglzcj3pycue62zpujue7jyxc4gzbl7o5y/") --verifier-url https://tuber.build/api --verifier blockscout --compiler-version 0.8.15

//forge verify-contract 0xFb50235D53b381ddd540034af77c5eeDAB5CE7f3 src/Distributor.sol:Distributor --constructor-args $(cast abi-encode "constructor(address, address, address)" 0x9aB79714AB7A4FB72408d6EA9d2C92Bb86beA2c0 0x12f73617D48b7aab8FE9f2B3b76C55F1055fAa01 0x24757E4b5AD64e6b48d78Dc800D45b4061698757) --chain-id 7700 --verifier-url https://tuber.build/api --verifier blockscout

//bafybeigwbkomquihro3m2xea4obkieomtyyxqiwi5djhyvsfnyc6rddqey