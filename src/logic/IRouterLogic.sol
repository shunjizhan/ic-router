// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

abstract contract IRouterLogic {
    string public identifier;

    constructor(string memory _identifier) {
        identifier = _identifier;
    }

    function execute(bytes memory params) external virtual;
}
