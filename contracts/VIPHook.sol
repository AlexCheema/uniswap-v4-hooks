// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;
import {BaseHook} from "./BaseHook.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {console} from "forge-std/console.sol";

contract VIPHook is BaseHook {

    mapping(address => uint256) swapVolumes;
    address swapper;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: true,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function beforeSwap(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    ) external override poolManagerOnly returns (bytes4) {
        swapper = sender;
        return VIPHook.beforeSwap.selector;
    }

    function afterSwap(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta balanceDelta
    ) external override poolManagerOnly returns (bytes4) {
        // TODO: also count lp volumes
        swapVolumes[sender] += SignedMath.abs(balanceDelta.amount0());
        return VIPHook.afterSwap.selector;
    }

    function afterInitialize(address, IPoolManager.PoolKey calldata key, uint160, int24 tick)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
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
