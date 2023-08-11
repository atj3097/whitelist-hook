// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {BaseHook} from "../../BaseHook.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";

/// @title Whitelist Hook for Uniswap V3
/// @notice A hook that restricts pool participation to a whitelist of approved addresses.
contract WhitelistHook is BaseHook, Ownable {
    // Whitelisted addresses
    mapping(address => bool) public whitelisted;

    // Events
    event AddedToWhitelist(address indexed addr);
    event RemovedFromWhitelist(address indexed addr);

    /// @param _poolManager The address of the Uniswap V3 Pool Manager
    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    /// @notice Adds an address to the whitelist
    /// @param _address The address to add to the whitelist
    function addToWhitelist(address _address) external onlyOwner {
        whitelisted[_address] = true;
        emit AddedToWhitelist(_address);
    }

    /// @notice Removes an address from the whitelist
    /// @param _address The address to remove from the whitelist
    function removeFromWhitelist(address _address) external onlyOwner {
        whitelisted[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    /// @notice Ensures that the sender is whitelisted before modifying positions
    /// @param sender The address of the sender
    function beforeModifyPosition(address sender, PoolKey calldata, IPoolManager.ModifyPositionParams calldata)
    external
    override
    poolManagerOnly
    returns (bytes4)
    {
        require(whitelisted[sender], "WhitelistHook: Not whitelisted");
        return WhitelistHook.beforeModifyPosition.selector;
    }

    /// @notice Ensures that the sender is whitelisted before swaps
    /// @param sender The address of the sender
    function beforeSwap(address sender, PoolKey calldata, IPoolManager.SwapParams calldata)
    external
    override
    poolManagerOnly
    returns (bytes4)
    {
        require(whitelisted[sender], "WhitelistHook: Not whitelisted");
        return WhitelistHook.beforeSwap.selector;
    }

    /// @notice Specifies which hook functions are called by the Pool Manager
    /// @return Hooks.Calls structure containing booleans for each hook function
    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: true,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }
}
