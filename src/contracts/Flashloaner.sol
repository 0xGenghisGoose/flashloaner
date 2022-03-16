// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "solmate/tokens/ERC20.sol";

interface Receiver {
    function onFlashReqReceived(
        ERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract Flashloaner {
    // immutable address for owner/manager aka da bawssssss
    address public immutable boss;

    // errors
    error LoanNotRepaid();
    error UserNoBoss();

    // events
    event Flashloanooor(Receiver receiver, ERC20 token, uint256 amount);
    event Withdraw(ERC20 token, uint256 amount);

    // mapping to hold fees per token
    mapping(ERC20 => uint256) fees;

    constructor() payable {
        boss = msg.sender;
    }

    function requestFlashLoan(
        Receiver receiver,
        ERC20 token,
        uint256 amount,
        bytes calldata data
    ) public payable {
        uint256 contractHoldings = token.balanceOf(address(this));

        emit Flashloanooor(receiver, token, amount);

        token.transfer(address(receiver), amount);
        receiver.onFlashReqReceived(token, amount, data);

        if (contractHoldings + calcFee(token, amount) > contractHoldings)
            revert LoanNotRepaid();
    }

    function calcFee(ERC20 token, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (fees[token] == 0) return 0;

        return (amount * fees[token]) / 10_000;
    }

    // function to withdraw fees (by owner)
    function withdraw(ERC20 token, uint256 amount) public payable {
        if (msg.sender != boss) revert UserNoBoss();
        emit Withdraw(token, amount);
        token.transfer(msg.sender, amount);
    }
}
