// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Secp256k1} from "./Secp256k1.sol";

uint256 constant PP = Secp256k1.MOD;

function modMulInv(uint256 x) pure returns (uint256) {
    require(x != 0 && x != PP, "invmod: bad input");
    uint256 q;
    uint256 newT = 1;
    uint256 r = PP;
    uint256 newR = x;
    uint256 t;
    while (newR != 0) {
        t = r / newR;
        (q, newT) = (newT, addmod(q, (PP - mulmod(t, newT, PP)), PP));
        (r, newR) = (newR, r - t * newR);
    }
    return q;
}

function kGen(uint256 pk, bytes32 hash) pure returns (uint256 k) {
    uint256 h1 = __modred(uint256(hmac(k, abi.encodePacked(hash))));
    uint256 v = 0x0101010101010101010101010101010101010101010101010101010101010101;
    k = uint256(hmac(k, abi.encodePacked(v, uint8(0), pk, h1)));
    v = uint256(hmac(k, abi.encodePacked(v)));
    k = uint256(hmac(k, abi.encodePacked(v, uint8(1), pk, h1)));
    v = uint256(hmac(k, abi.encodePacked(v)));

    while (true) {
        uint256 t;
        uint256 i;
        while (t >> 255 != 0 && i <= 256) {
            v = uint256(hmac(k, abi.encodePacked(v)));
            uint256 lz = clz(v);
            t |= v << lz >> i;
            i += lz;
        }

        if (t >= 1 && t < Secp256k1.ORDER) {
            return t;
        }
        k = uint256(hmac(k, abi.encodePacked(v, uint8(0))));
        v = uint256(hmac(k, abi.encodePacked(v)));
    }
}

function hmac(uint256 k, bytes memory v) pure returns (uint256) {
    uint256 ipad = 0x3636363636363636363636363636363636363636363636363636363636363636;
    uint256 opad = 0x5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
    bytes32 hash = sha256(abi.encodePacked(k ^ opad, sha256(abi.encodePacked(k ^ ipad, v))));
    return uint256(hash);
}

function __modred(uint256 n) pure returns (uint256) {
    return n >= PP ? n - PP : n;
}

// thx vectorized.eth
// long live solady
// https://github.com/Vectorized/solady/blob/main/src/utils/LibBit.sol
function clz(uint256 x) pure returns (uint256 r) {
    /// @solidity memory-safe-assembly
    assembly {
        let t := add(iszero(x), 255)

        r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
        r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
        r := or(r, shl(5, lt(0xffffffff, shr(r, x))))

        // For the remaining 32 bits, use a De Bruijn lookup.
        x := shr(r, x)
        x := or(x, shr(1, x))
        x := or(x, shr(2, x))
        x := or(x, shr(4, x))
        x := or(x, shr(8, x))
        x := or(x, shr(16, x))

        // forgefmt: disable-next-item
        r := sub(t, or(r, byte(shr(251, mul(x, shl(224, 0x07c4acdd))),
            0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f)))
    }
}

