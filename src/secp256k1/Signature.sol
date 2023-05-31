// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct Signature {
    uint8 v;
    uint256 r;
    uint256 s;
}

using { toFields, toBytes, toBytesPacked, toEip2098Signature } for Signature global;

struct Eip2098Signature {
    uint256 r;
    uint256 yParityAndS;
}

using { toSignature } for Eip2098Signature global;

function toFields(Signature memory self) pure returns (uint8 v, bytes32 r, bytes32 s) {
    return (self.v, bytes32(self.r), bytes32(self.s));
}

function toBytes(Signature memory self) pure returns (bytes memory) {
    return abi.encode(self.v, self.r, self.s);
}

function toBytesPacked(Signature memory self) pure returns (bytes memory) {
    return abi.encodePacked(self.v, self.r, self.s);
}

function toEip2098Signature(Signature memory self) pure returns (Eip2098Signature memory) {
    uint256 yParity = uint256(self.v) - 27;
    return Eip2098Signature({
        r: self.r,
        yParityAndS: (yParity << 255) | uint256(self.s)
    });
}

function toSignature(Eip2098Signature memory self) pure returns (Signature memory) {
    return Signature({
        v: uint8((self.yParityAndS >> 255) + 27),
        r: self.r,
        s: uint256(self.yParityAndS) & ((1 << 255) - 1)
    });
}
