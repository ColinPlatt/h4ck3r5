// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SSTORE2} from "solmate/utils/SSTORE2.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "src/ITurnstile.sol";

contract ThresholdGhouls is Ownable {

    address private ghoulsMultiSig = 0x0B983A9A7C0a4Dc37ae2bA2781a9e10141338b34;

    address internal pointer0;
    address internal pointer1;
    address internal firstPointer1;

    constructor(uint256 _CSRID) {
        if(block.chainid == 7700) ITurnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44).assign(_CSRID);
    }

    // We expect to call this twice. Each recipient list is limited to 1228 addresses
    function loadPtr(bytes calldata recipients) public onlyOwner {
        require(pointer0 == address(0) || pointer0 == address(0) , "ALREADY_LOADED");

        if(pointer0 == address(0)) {
            pointer0 = SSTORE2.write(recipients);
        } else {
            // we determine the first address in the second batch to simplify who goes into which batch
            firstPointer1 = address(bytes20(recipients[0:20]));
            pointer1 = SSTORE2.write(recipients);
        }
    }

    /*//////////////////////////////////////////////////////////////
                         OWNER / BALANCE LOGIC
    //////////////////////////////////////////////////////////////*/

    // borrowed from https://github.com/ensdomains/resolvers/blob/master/contracts/ResolverBase.sol
    function bytesToAddress(bytes memory b) internal pure returns (address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function _ownersPrimaryLength0() internal view returns (uint256) {
        if (pointer0 == address(0)) {
            return 0;
        }

        // checked math will underflow if _ownersPrimaryPointer.code.length == 0
        return (pointer0.code.length - 1) / 20;
    }

    function _ownersPrimaryLength1() internal view returns (uint256) {
        if (pointer1 == address(0)) {
            return 0;
        }

        // checked math will underflow if _ownersPrimaryPointer.code.length == 0
        return (pointer1.code.length - 1) / 20;
    }

    function _ownerOfPrimary0(uint256 id) internal view returns (address owner) {
        require(id > 0, "ZERO_ID");
        require(id <= _ownersPrimaryLength0(), "NOT_MINTED");

        unchecked {
            uint256 start = (id - 1) * 20;
            owner = bytesToAddress(SSTORE2.read(pointer0, start, start + 20));
        }
    }

    function _ownerOfPrimary1(uint256 id) internal view returns (address owner) {
        require(id > 0, "ZERO_ID");
        require(id <= _ownersPrimaryLength1(), "NOT_MINTED");

        unchecked {
            uint256 start = (id - 1) * 20;
            owner = bytesToAddress(SSTORE2.read(pointer1, start, start + 20));
        }
    }

    // binary search of the address based on _ownerOfPrimary
    // performs O(log n) sloads
    // relies on the assumption that the list of addresses is sorted and contains no duplicates
    // returns 1 if the address is found in _ownersPrimary, 0 if not
    function _isListed(address owner) public view returns (bool) {
        uint256 low = 1;
        
        if(uint160(owner) < uint160(firstPointer1)) {
        
            uint256 high = _ownersPrimaryLength0();
            uint256 mid = (low + high) / 2;

            // TODO: unchecked
            while (low <= high) {
                address midOwner = _ownerOfPrimary0(mid);
                if (midOwner == owner) {
                    return true;
                } else if (midOwner < owner) {
                    low = mid + 1;
                } else {
                    high = mid - 1;
                }
                mid = (low + high) / 2;
            }
        } else {
            uint256 high = _ownersPrimaryLength1();
            uint256 mid = (low + high) / 2;

            // TODO: unchecked
            while (low <= high) {
                address midOwner = _ownerOfPrimary1(mid);
                if (midOwner == owner) {
                    return true;
                } else if (midOwner < owner) {
                    low = mid + 1;
                } else {
                    high = mid - 1;
                }
                mid = (low + high) / 2;
            }
        }
        return false;
    }
}