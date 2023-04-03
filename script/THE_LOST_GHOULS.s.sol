// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/THE_LOST_GHOULS.sol";
import "src/Distributor.sol";

contract IWLLScript is Script {

    THE_LOST_GHOULS public nft;
    Distributor public distributor;

    address amplice = 0x81996BD9761467202c34141B63B3A7F50D387B6a;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

            nft = new THE_LOST_GHOULS("https://nftstorage.link/ipfs/bafybeignf5eeht2qf334bk7swgn6lq7hlmp36hsywfo2ckdgtm7zyp5nke/");
            distributor = new Distributor(address(nft), amplice, address(0x69), address(0x69), address(0x69));
            nft.setDistributor(address(distributor));

        vm.stopBroadcast();
    }
}


// forge script script/IWLL.s.sol:IWLLScript --rpc-url $RPC_URL --broadcast --slow -vvvv
// forge verify-contract 0x9aB79714AB7A4FB72408d6EA9d2C92Bb86beA2c0 src/IW_LOST_LEVELS.sol:IW_LOST_LEVELS --constructor-args $(cast abi-encode "constructor(string memory)" "ipfs://bafybeidrm4vuu2qjnswxseypkglzcj3pycue62zpujue7jyxc4gzbl7o5y/") --verifier-url https://tuber.build/api --verifier blockscout --compiler-version 0.8.15

//forge verify-contract 0xFb50235D53b381ddd540034af77c5eeDAB5CE7f3 src/Distributor.sol:Distributor --constructor-args $(cast abi-encode "constructor(address, address, address)" 0x9aB79714AB7A4FB72408d6EA9d2C92Bb86beA2c0 0x12f73617D48b7aab8FE9f2B3b76C55F1055fAa01 0x24757E4b5AD64e6b48d78Dc800D45b4061698757) --chain-id 7700 --verifier-url https://tuber.build/api --verifier blockscout

//bafybeigwbkomquihro3m2xea4obkieomtyyxqiwi5djhyvsfnyc6rddqey