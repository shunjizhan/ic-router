// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Router.sol";

struct RouterTopUp {
    IERC20 token;
    uint256 amount;
}

contract RouterFactory {
    event RouterDeployed(address indexed router, address indexed recipient);

    function deployRouter(
        Router.RouterStep[] memory steps,
        address recipient
    ) public returns (Router) {
        require(steps.length > 0, "RouterFactory: No steps provided");
        require(recipient != address(0), "RouterFactory: Invalid recipient");

        bytes32 salt = keccak256(abi.encode(steps, recipient));

        Router router = new Router{salt: salt}(steps, recipient);

        emit RouterDeployed(address(router), recipient);
        return router;
    }

    function deployRouterAndExecute(
        RouterTopUp[] memory topUps,
        Router.RouterStep[] memory steps,
        address recipient
    ) public {
        Router router = deployRouter(steps, recipient);

        for (uint i = 0; i < topUps.length; i++) {
            require(
                topUps[i].token.transferFrom(msg.sender, address(router), topUps[i].amount),
                "RouterFactory: Token transfer to router failed"
            );
        }

        router.execute();
    }
}

