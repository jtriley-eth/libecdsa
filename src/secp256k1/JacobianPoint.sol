// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Secp256k1} from "./Secp256k1.sol";
import {ECPoint} from "./ECPoint.sol";
import {modMulInv} from "./Utils.sol";

uint256 constant PP = Secp256k1.MOD;
uint256 constant AA = Secp256k1.AA;

struct JacobianPoint {
    uint256 x;
    uint256 y;
    uint256 z;
}

using { toECPoint, add, double, mul } for JacobianPoint global;

function toECPoint(JacobianPoint memory self) pure returns (ECPoint memory) {
    uint256 zInv = modMulInv(self.z);
    uint256 zInv2 = mulmod(zInv, zInv, PP);
    return ECPoint({
        x: mulmod(self.x, zInv2, PP),
        y: mulmod(self.y, mulmod(zInv, zInv2, PP), PP)
    });
}

function add(JacobianPoint memory self, JacobianPoint memory rhs) pure returns (JacobianPoint memory) {
    if (self.x == 0 && self.y == 0) return rhs;
    if (rhs.x == 0 && rhs.y == 0) return self;

    uint256[4] memory zs;
    zs[0] = mulmod(self.z, self.z, PP);
    zs[1] = mulmod(self.z, zs[0], PP);
    zs[2] = mulmod(rhs.z, rhs.z, PP);
    zs[3] = mulmod(rhs.z, zs[2], PP);
    zs = [
        mulmod(self.x, zs[2], PP),
        mulmod(self.y, zs[3], PP),
        mulmod(rhs.x, zs[0], PP),
        mulmod(rhs.y, zs[1], PP)
    ];
    if (zs[0] == zs[2]) {
        revert(zs[1] != zs[3] ? "wrong data" : "use double instead");
    }
    uint256[4] memory hr;
    hr[0] = addmod(zs[2], PP - zs[0], PP);
    hr[1] = addmod(zs[3], PP - zs[1], PP);
    hr[2] = mulmod(hr[0], hr[0], PP);
    hr[3] = mulmod(hr[2], hr[0], PP);
    uint256 qx = addmod(mulmod(hr[1], hr[1], PP), PP - hr[3], PP);
    qx = addmod(qx, PP - mulmod(2, mulmod(zs[0], hr[2], PP), PP), PP);
    uint256 qy = mulmod(hr[1], addmod(mulmod(zs[0], hr[2], PP), PP - qx, PP), PP);
    qy = addmod(qy, PP - mulmod(zs[1], hr[3], PP), PP);
    uint256 qz = mulmod(hr[0], mulmod(self.z, rhs.z, PP), PP);
    return JacobianPoint(qx, qy, qz);
}

function double(JacobianPoint memory self) pure returns (JacobianPoint memory) {
    if (self.z == 0) return self;
    uint256[3] memory square = [
        mulmod(self.x, self.x, PP),
        mulmod(self.y, self.y, PP),
        mulmod(self.z, self.z, PP)
    ];
    uint256 s = mulmod(4, mulmod(self.x, square[1], PP), PP);
    uint256 m = addmod(mulmod(3, square[0], PP), mulmod(AA, mulmod(square[2], square[2], PP), PP), PP);
    uint256 qx = addmod(mulmod(m, m, PP), PP - addmod(s, s, PP), PP);
    uint256 qy = addmod(mulmod(m, addmod(s, PP - qx, PP), PP), PP - mulmod(8, mulmod(square[1], square[1], PP), PP), PP);
    uint256 qz = mulmod(2, mulmod(self.y, self.z, PP), PP);
    return JacobianPoint(qx, qy, qz);
}

function mul(JacobianPoint memory self, uint256 scalar) pure returns (JacobianPoint memory) {
    uint256 remaining = scalar;
    JacobianPoint memory point = JacobianPoint(self.x, self.y, self.z);
    JacobianPoint memory q = JacobianPoint(0, 0, 1);

    if (scalar == 0) return q;

    while (remaining != 0) {
        if ((remaining & 1) != 0) {
            q = q.add(point);
        }
        remaining /= 2;
        point = point.double();
    }
    return q;
}

