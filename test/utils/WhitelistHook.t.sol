// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./WhitelistHook.sol";
import "./HookTest.sol";

contract WhitelistHookTest is HookTest {
    WhitelistHook whitelistHook;

    function setUp() public {
        initHookTestEnv();
        whitelistHook = new WhitelistHook(IPoolManager(address(manager)));
    }

    function testAddToWhitelist() public {
        address user1 = address(0x1234);
        whitelistHook.addToWhitelist(user1);
        assertEq(whitelistHook.whitelisted(user1), true);
    }

    function testRemoveFromWhitelist() public {
        address user1 = address(0x1234);
        whitelistHook.addToWhitelist(user1);
        whitelistHook.removeFromWhitelist(user1);
        assertEq(whitelistHook.whitelisted(user1), false);
    }

    function testBeforeModifyPositionWithWhitelistedUser() public {
        address user1 = address(0x1234);
        whitelistHook.addToWhitelist(user1);

        IPoolManager.PoolKey memory key = IPoolManager.PoolKey({
            token0: token0,
            token1: token1,
            fee: 1000
        });

        IPoolManager.ModifyPositionParams memory params = IPoolManager.ModifyPositionParams({
            amount0: 1000,  // Amount of token0
            amount1: 2000,  // Amount of token1
            liquidity: 100, // Desired liquidity
            deadline: block.timestamp + 1 hours // Deadline for the transaction
        });

    etchHook(address(whitelistHook), address(manager));
        bytes4 result = whitelistHook.beforeModifyPosition(user1, key, params);
        assertEq(result, WhitelistHook.beforeModifyPosition.selector);
    }

}
