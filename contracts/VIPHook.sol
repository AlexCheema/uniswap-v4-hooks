// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;
import {BaseHook} from "./BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

import {console} from "forge-std/console.sol";

contract VIPHook is BaseHook {

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: true,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: false,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function afterInitialize(address, IPoolManager.PoolKey calldata key, uint160, int24 tick)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        console.log("afterInitialize");
        return VIPHook.afterInitialize.selector;
    }


    // Override the hook callbacks you want on your hook
    function beforeModifyPosition(
        address,
        IPoolManager.PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata params
    ) external override poolManagerOnly returns (bytes4) {
        // hook logic
        return BaseHook.beforeModifyPosition.selector;
    }
}
