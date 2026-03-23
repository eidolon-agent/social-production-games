// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { SocialFactory } from "../src/SocialFactory.sol";

contract DeploySocialFactory {
    SocialFactory public socialFactory;

    constructor() {}

    function run() external returns (SocialFactory) {
        socialFactory = new SocialFactory();
        return socialFactory;
    }
}
