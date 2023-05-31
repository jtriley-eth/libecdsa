// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {JacobianPoint} from "./JacobianPoint.sol";
import {ECPoint} from "./ECPoint.sol";
import {Signature, Eip2098Signature} from "./Signature.sol";
import {modMulInv, kGen} from "./Utils.sol";

library Secp256k1 {
    uint256 constant GX = 0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798;
    uint256 constant GY = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8;
    uint256 constant MOD = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
    uint256 constant ORDER = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;
    uint256 constant AA = 0;

    function g() internal pure returns (ECPoint memory) {
        return ECPoint(GX, GY);
    }
}
