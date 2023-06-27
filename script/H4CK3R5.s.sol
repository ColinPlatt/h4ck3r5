// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "src/Distributor.sol";
import "src/utils/dummyNFT.sol";
import "src/H4CK3R5.sol";

contract H4CK3R5_DUMMY_Script is Script {
    DummyERC721 public dummySkulls;
    DummyERC721 public dummyChainRunners;
    DummyERC721 public dummyBasedGhouls;
    H4CK3R5 public nft;
    Distributor public distributor;


    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

            dummySkulls = new DummyERC721("skulls", "SKULLS");
            dummyChainRunners = new DummyERC721("chainRunners", "CHAINRUNNERS");
            dummyBasedGhouls = new DummyERC721("basedGhouls", "BASEDGHOULS");

            nft = new H4CK3R5();
            distributor = new Distributor(address(nft), address(dummySkulls), address(dummyChainRunners), address(dummyBasedGhouls));
            nft.setDistributor(address(distributor));

            dummySkulls.mint(deployer, 1);
            distributor.discountedMint{value: 0.05 ether}(address(dummySkulls), 1);
            distributor.publicMint(1);

        vm.stopBroadcast();
    }
}
// forge script script/H4CK3R5.s.sol:H4CK3R5_DUMMY_Script --rpc-url $RPC_URL --broadcast --verifier etherscan --chain goerli --slow --verify -vvvv
