// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {LibECDSA as ecdsa, Signature, Secp256k1} from "../src/LibECDSA.sol";

using ecdsa for Signature;

contract LibECDSATest is Test {

    function testAddr() public {
        uint256 pk = 2;
        assertEq(
            vm.addr(pk),
            ecdsa.addr(pk)
        );
    }

    function testFuzzAddr(uint256 pk) public {
        pk = bound(pk, 1, Secp256k1.ORDER - 1);
        assertEq(
            vm.addr(pk),
            ecdsa.addr(pk)
        );
    }

    // function testFuzzSign(uint256 pk, bytes32 hash) public {
    //     pk = bound(pk, 1, Secp256k1.ORDER - 1);

    //     (uint8 v0, bytes32 r0, bytes32 s0) = vm.sign(pk, hash);
    //     (uint8 v1, bytes32 r1, bytes32 s1) = ecdsa.sign(pk, hash).toFields();

    //     assertEq(ecrecover(hash, v0, r0, s0), ecrecover(hash, v1, r1, s1));
    // }
}
