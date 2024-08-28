// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/logic/TransferLogic.sol";
import "../src/RouterFactory.sol";

contract TestToken is ERC20 {
    constructor() ERC20("TestToken", "TTK") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}

contract RouterFactoryTest is Test {
    RouterFactory routerFactory;
    TransferLogic transferLogic;
    TestToken token;
    address relayer = address(1);
    address recipient = address(2);
    uint256 amount = 100;

    function setUp() public {
        routerFactory = new RouterFactory();
        transferLogic = new TransferLogic();
        token = new TestToken();

        token.transfer(relayer, amount);

        vm.startPrank(relayer);
        token.approve(address(routerFactory), amount);
        vm.stopPrank();
    }

    function testTokenDrop() public {
        TransferParams memory transferParams = TransferParams({
            to: recipient,
            token: IERC20(address(token)),
            amount: amount
        });

        bytes memory transferLogicParams = abi.encode(transferParams);
        Router.RouterStep[] memory steps = new Router.RouterStep[](1);
        steps[0] = Router.RouterStep({
            logic: address(transferLogic),
            params: transferLogicParams
        });

        RouterTopUp[] memory topups = new RouterTopUp[](1);
        topups[0] = RouterTopUp({
            token: IERC20(address(token)),
            amount: amount
        });

        uint256 relayerBal0 = token.balanceOf(relayer);
        uint256 recipientBal0 = token.balanceOf(recipient);
        console.log("relayer balance before:", relayerBal0);
        console.log("recipient balance before:", recipientBal0);

        vm.startPrank(relayer);
        routerFactory.deployRouterAndExecute(topups, steps, recipient);
        vm.stopPrank();

        uint256 relayerBal1 = token.balanceOf(relayer);
        uint256 recipientBal1 = token.balanceOf(recipient);
        console.log("relayer balance after:", relayerBal1);
        console.log("recipient balance after:", recipientBal1);

        assertEq(relayerBal0 - relayerBal1, amount, "relayer did not send the tokens");
        assertEq(recipientBal1 - recipientBal0, amount, "recipient did not receive the tokens");
    }
}
