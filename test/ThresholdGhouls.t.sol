// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Distributor.sol";

contract ThresholdGhouls_Test is Test {

    address[5] public batchAddresses;

    function testSetup() public {

        address[] memory temp = new address[](6);

        temp[0] = address(bytes20(hex'ab339ae6eab3c3cf4f5885e56f7b49391a01dda6'));
        temp[1] = address(bytes20(hex'00003183f59e825911d98fb509a157cd2abbae25'));
        temp[2] = address(bytes20(hex'cf51040f5861907c6c7ae33b49f8605fcb802117'));
        temp[3] = address(bytes20(hex'475dcaa08a69fa462790f42db4d3bba1563cb474'));
        temp[4] = address(bytes20(hex'259524ed1606f5ecd39e5815108843d7c8e8fa78'));

        temp[5] = address(0x259524Ed1606F5Ecd39E5815108843d7C8E8Fa78);

        for (uint256 i = 0; i< 5; i++) {

            //emit log_address(temp[i]);
            emit log_uint(uint160(temp[i]));

        } 

        assertEq(temp[4], temp[5]);

        address[] memory tempSorted = sort(temp);

        for (uint256 i = 0; i< 5; i++) {

            emit log_address(tempSorted[i]);

        } 

    }

    function sort(address[] memory data) public returns(address[] memory) {
       quickSort(data, int(0), int(data.length - 1));
       return data;
    }
    
    function quickSort(address[] memory arr, int left, int right) internal {
        int i = left;
        int j = right;
        if(i==j) return;
        address pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

}
