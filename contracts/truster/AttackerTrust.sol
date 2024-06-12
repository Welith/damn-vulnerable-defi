// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TrusterLenderPool} from "./TrusterLenderPool.sol";

contract AttackerTrust {
    TrusterLenderPool public pool;
    address private player;

    constructor(address _pool, address _player) {
        pool = TrusterLenderPool(_pool);
        player = _player;
    }

    function test(bytes calldata data) external {
        msg.sender.call(data);
    }
}
