// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";

contract ThresholdGhouls_Test is Test {
    using stdJson for string;

    // turning this off, just so we don't overwrite it by accident
    function off_testSort() public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/snapshot/basedGhoulsAddrs.json");
        string memory json = vm.readFile(path);

        address[] memory unSortedAddresses = new address[](1848);

        for(uint i = 0; i<unSortedAddresses.length; i++) {
            unSortedAddresses[i] = json.readAddress(
                string.concat(
                    ".data[",
                    vm.toString(i),
                    "].address"
                )
            );
        }


        address[] memory sortedAddresses = sort(unSortedAddresses);

        string memory sortedJson = vm.serializeAddress("data", "address", sortedAddresses);

        address[] memory sortedAddresses_0 = new address[](1848/2);
        address[] memory sortedAddresses_1 = new address[](1848/2);

        for(uint i = 0; i<(1848/2); i++) {
            sortedAddresses_0[i] = sortedAddresses[i];
            sortedAddresses_1[i] = sortedAddresses[i+(1848/2)];
        }

        string memory sortedJson_0 = vm.serializeAddress("data", "address", sortedAddresses_0);
        string memory sortedJson_1 = vm.serializeAddress("data", "address", sortedAddresses_1);

        vm.writeJson(sortedJson_0, string.concat(root, "/test/snapshot/sortedAddresses_0.json"));
        vm.writeJson(sortedJson_1, string.concat(root, "/test/snapshot/sortedAddresses_1.json"));


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
