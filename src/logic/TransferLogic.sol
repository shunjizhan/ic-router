// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./IRouterLogic.sol";

struct TransferParams {
    address to;
    IERC20 token;
    uint256 amount;
}

contract TransferLogic is IRouterLogic {
    constructor() IRouterLogic("TransferLogic") {}

    function execute(bytes memory params) external override {
        TransferParams memory transferParams = abi.decode(params, (TransferParams));

        uint256 balance = transferParams.token.balanceOf(address(this));
        require(balance >= transferParams.amount, "TransferLogic: insufficient balance");

        bool success = transferParams.token.transfer(transferParams.to, transferParams.amount);
        require(success, "TransferLogic: transfer failed");
    }
}
