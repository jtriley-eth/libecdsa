// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Secp256k1} from "./Secp256k1.sol";
import {JacobianPoint} from "./JacobianPoint.sol";

uint256 constant PP = Secp256k1.MOD;

struct ECPoint {
    uint256 x;
    uint256 y;
}

using {toJacobian, inv, add, sub, mul} for ECPoint global;

function toJacobian(ECPoint memory self) pure returns (JacobianPoint memory) {
    return JacobianPoint(self.x, self.y, 1);
}

function inv(ECPoint memory self) pure returns (ECPoint memory) {
    return ECPoint({x: self.x, y: (PP - self.y) % PP});
}

function add(
    ECPoint memory self,
    ECPoint memory rhs
) pure returns (ECPoint memory res) {
    return
        (self.x == rhs.x)
            ? self.toJacobian().double().toECPoint()
            : self.toJacobian().add(rhs.toJacobian()).toECPoint();
}

function sub(
    ECPoint memory self,
    ECPoint memory rhs
) pure returns (ECPoint memory) {
    return self.add(rhs.inv());
}

function mul(
    ECPoint memory self,
    uint256 scalar
) pure returns (ECPoint memory res) {
    return self.toJacobian().mul(scalar).toECPoint();
}
