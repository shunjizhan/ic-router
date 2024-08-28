// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IRouterLogic } from "./logic/IRouterLogic.sol";

contract Router {
    struct RouterStep {
        address logic;
        bytes params;
    }

    RouterStep[] public steps;
    address public immutable collector;

    constructor(
      RouterStep[] memory _steps,
      address _collector
    ) {
        require(_steps.length > 0, "Router: No steps provided");
        require(_collector != address(0), "Router: Invalid collector address");
        
        for (uint i = 0; i < _steps.length; i++) {
            steps.push(_steps[i]);
        }
        collector = _collector;
    }

    function execute() external {
        for (uint i = 0; i < steps.length; i++) {
            (bool success, bytes memory result) = steps[i].logic.delegatecall(
                abi.encodeWithSelector(IRouterLogic.execute.selector, steps[i].params)
            );

            if (!success) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }

        selfdestruct(payable(collector));
    }

    function rescue(address[] calldata tokens) external {
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            if (balance > 0) {
                require(token.transfer(collector, balance), "Router: Token transfer failed");
            }
        }
    }
}
