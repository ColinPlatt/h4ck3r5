// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/H4CK3R5.sol";
import "src/Distributor.sol";

contract DummyERC721 is ERC721("dummy", "DUMMY") {
    constructor() {}
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract H4CK3R5_TEST is Test {

    H4CK3R5 public nft;
    DummyERC721 public skullsNft;
    DummyERC721 public chainRunnersNft;
    DummyERC721 public basedGhoulsNft;

    Distributor public distributor;

    address public constant alice = address(0xA11ce);
    address public constant dep = address(0xad1);

    string RPC = vm.envString("RPC_URL");
    uint256 fork;
    
    function setUp() public {
        //fork = vm.createSelectFork(RPC);

        vm.startPrank(dep);

            skullsNft = new DummyERC721();
            chainRunnersNft = new DummyERC721();
            basedGhoulsNft = new DummyERC721();

            nft = new H4CK3R5();
            distributor = new Distributor(address(nft), address(skullsNft), address(chainRunnersNft), address(basedGhoulsNft));
            nft.setDistributor(address(distributor));

        vm.stopPrank();
    }

    
    function testDiscountedMints() public {

        address[] memory dummyHolder = new address[](10); 

        for(uint256 i = 0; i < 10; i++) {
            dummyHolder[i] = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
        }

        vm.startPrank(dummyHolder[0]);
            skullsNft.mint(dummyHolder[0], 1);
            chainRunnersNft.mint(dummyHolder[0], 1);
            basedGhoulsNft.mint(dummyHolder[0], 1);
        vm.stopPrank();

        vm.deal(dummyHolder[0], 1 ether);

        vm.startPrank(dummyHolder[0]);

            distributor.discountedMint{value: 0.05 ether}(address(skullsNft), 1);
            distributor.discountedMint{value: 0.05 ether}(address(chainRunnersNft), 1);
            distributor.discountedMint{value: 0.05 ether}(address(basedGhoulsNft), 1);

        vm.stopPrank();

        assertEq(nft.balanceOf(dummyHolder[0]), 3);

        vm.deal(alice, 1 ether);

        vm.startPrank(alice);

            distributor.publicMint{value: 0.69 ether}(10);

        vm.stopPrank();

        assertEq(nft.balanceOf(alice), 10);

    }


    
    function testMintUnderpriced() public {

        vm.startPrank(alice);
        
            vm.deal(alice, 1 ether);
            vm.expectRevert(bytes("Insufficient payment"));
            distributor.publicMint{value: 0.05 ether}(1);

    
            assertEq(nft.balanceOf(alice), 0);
        vm.stopPrank();

    }

    function testMintTooMany() public {

        vm.deal(alice, 10 ether);

        vm.startPrank(alice);
        
            vm.expectRevert(bytes("Max 10 mints"));
            distributor.publicMint{value: 0.069 ether*11}(11);

        vm.stopPrank();

        assertEq(nft.balanceOf(alice), 0);

        vm.startPrank(alice);
            
            distributor.publicMint{value: 0.069 ether*10}(10);
            assertEq(nft.balanceOf(alice), 10);

            vm.expectRevert(bytes("Max 10 per address"));
            distributor.publicMint{value: 0.069 ether*1}(1);
            assertEq(nft.balanceOf(alice), 10);

        vm.stopPrank();

    }

    function testMintOwner() public {

        vm.startPrank(dep);
        
            distributor.publicMint(11);

        vm.stopPrank();

        assertEq(nft.balanceOf(dep), 11);

    }

    function testCanMintAll() public {

        for(uint256 i = 0; i<150; ++i) {

            vm.deal(address(uint160(i+1)), 10 ether);

            vm.startPrank(address(uint160(i+1)));

                distributor.publicMint{value: 0.069 ether*10}(10);
                
            vm.stopPrank();

            assertEq(nft.balanceOf(address(uint160(i+1))), 10);

            for(uint256 j = 0; j<10; ++j) {
                assert(nft.tokenOfOwnerByIndex(address(uint160(i+1)),j)<1508);
                assert(nft.tokenOfOwnerByIndex(address(uint160(i+1)),j)>0);
            }
        }

        vm.deal(address(uint160(151)), 10 ether);

        vm.startPrank(address(uint160(151)));

            distributor.publicMint{value: 0.069 ether*7}(7);
            
        vm.stopPrank();

        assertEq(nft.balanceOf(address(uint160(151))), 7);

        for(uint256 j = 0; j<7; ++j) {
            assert(nft.tokenOfOwnerByIndex(address(uint160(151)),j)<1508);
            assert(nft.tokenOfOwnerByIndex(address(uint160(151)),j)>0);
        }

        assertEq(nft.totalSupply(), 1507);

        vm.deal(alice, 10_000 ether);

        vm.startPrank(alice);
        
            vm.expectRevert(bytes("Mint closed"));
            distributor.publicMint{value: 0.069 ether*1}(1);

        vm.stopPrank();

        assertEq(nft.balanceOf(alice), 0);

        vm.startPrank(dep);
            assertEq(address(distributor).balance, 0.069 ether * 1507);

            //perform withdrawal
            distributor.withdraw();
            assertEq(address(distributor.FEE_RECEIVER()).balance, 0.069 ether * 1507);
        vm.stopPrank();

    }

    function testSupportsInterface() public {

        assert(nft.supportsInterface(type(IERC721).interfaceId));
        assert(nft.supportsInterface(type(IERC721Metadata).interfaceId));
        assert(nft.supportsInterface(type(IERC721Enumerable).interfaceId));
        assert(nft.supportsInterface(0x01ffc9a7)); //165
        assert(nft.supportsInterface(type(IERC2981).interfaceId));

    }

    function testMintFromContract() public {

        vm.startPrank(dep);
        
            vm.expectRevert("H4CK3R5: caller is not the distributor");
            nft.mintFromDistributor(dep, 1);

        vm.stopPrank();

        assertEq(nft.balanceOf(dep), 0);

        vm.startPrank(alice);
        
            vm.expectRevert("H4CK3R5: caller is not the distributor");
            nft.mintFromDistributor(alice, 1);

        vm.stopPrank();

        assertEq(nft.balanceOf(alice), 0);


    }

    function testUri() public {

        vm.deal(alice, 10_000 ether);

        vm.startPrank(alice);

            distributor.publicMint{value: 0.069 ether*1}(1);

        vm.stopPrank();

        uint256 id = nft.tokenOfOwnerByIndex(alice,0);

        assertEq(nft.tokenURI(id),string.concat("https://bafybeicnoxjorayfx2e3udo7gbbi2ab6j6bdc3yi4vhbrbpkz7fzqiimdu.ipfs.nftstorage.link/",vm.toString(id)));

    }
}
