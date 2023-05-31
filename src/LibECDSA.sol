// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ECPoint, Secp256k1, Signature, modMulInv} from "./secp256k1/Secp256k1.sol";

uint256 constant PP = Secp256k1.MOD;

library LibECDSA {
    // WARNING: THIS SHOULD NOT BE CONSTANT, THIS WILL LEAK INFORMATION ABOUT YOUR PRIVATE KEY IF
    // YOU USE THIS DO NOT USE THIS IN PRODUCTION.
    uint256 constant K = 0x0420;

    function pubkey(uint256 privateKey) internal  pure returns (ECPoint memory) {
        return Secp256k1.g().mul(privateKey);
    }

    function addr(uint256 privateKey) internal pure returns (address) {
        ECPoint memory pub = pubkey(privateKey);
        return address(uint160(uint256(keccak256(abi.encode(pub.x, pub.y)))));
    }

    function sign(uint256 privateKey, bytes32 hash) internal pure returns (Signature memory) {
        uint256 r;
        uint256 s;
        while (true) {
            if (s == 0) {
                r = Secp256k1.g().mul(K).x;
                s = mulmod(modMulInv(K), addmod(uint256(hash), mulmod(r, privateKey, PP), PP), PP);
            } else {
                break;
            }
        }
        return Signature(28, r, s);
    }

    function getMalleable(Signature memory sig) internal pure returns (Signature memory) {
        return Signature({
            v: sig.v == 27 ? 28 : 27,
            r: sig.r,
            s: PP - sig.s
        });
    }
}
