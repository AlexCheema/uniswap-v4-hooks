pragma solidity >=0.8.19;

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {TestERC20} from "@uniswap/v4-core/contracts/test/TestERC20.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/libraries/PoolId.sol";
import {PoolSwapTest} from "@uniswap/v4-core/contracts/test/PoolSwapTest.sol";
import {VIPHook} from "../contracts/VIPHook.sol";
import {VIPHookImplementation} from "./shared/implementation/VIPHookImplementation.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/libraries/CurrencyLibrary.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {PoolModifyPositionTest} from "@uniswap/v4-core/contracts/test/PoolModifyPositionTest.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

contract TestVIPHook is Test, Deployers {
    using PoolIdLibrary for IPoolManager.PoolKey;

    uint160 constant SQRT_RATIO_10_1 = 250541448375047931186413801569;

    TestERC20 token0;
    TestERC20 token1;
    PoolManager manager;
    PoolModifyPositionTest modifyPositionRouter;
    VIPHook vipHook = VIPHook(address(uint160(Hooks.AFTER_INITIALIZE_FLAG | Hooks.AFTER_SWAP_FLAG)));
    IPoolManager.PoolKey poolKey;
    PoolId poolId;

    PoolSwapTest swapRouter;

    function setUp() public {
        console.log("setUp");

        token0 = new TestERC20(2**128);
        token1 = new TestERC20(2**128);
        manager = new PoolManager(500000);

        vm.record();
        VIPHookImplementation impl = new VIPHookImplementation(manager, vipHook);
        (, bytes32[] memory writes) = vm.accesses(address(impl));
        vm.etch(address(vipHook), address(impl).code);
        // for each storage key that was written during the hook implementation, copy the value over
        unchecked {
            for (uint256 i = 0; i < writes.length; i++) {
                bytes32 slot = writes[i];
                vm.store(address(vipHook), slot, vm.load(address(impl), slot));
            }
        }

        modifyPositionRouter = new PoolModifyPositionTest(IPoolManager(address(manager)));
        swapRouter = new PoolSwapTest(manager);

        poolKey = IPoolManager.PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, vipHook);
        poolId = poolKey.toId();
        manager.initialize(poolKey, SQRT_RATIO_1_1);

        /*token0.approve(address(vipHook), type(uint256).max);
        token1.approve(address(vipHook), type(uint256).max);*/

        token0.approve(address(modifyPositionRouter), 100 ether);
        token1.approve(address(modifyPositionRouter), 100 ether);
        token0.approve(address(swapRouter), 100 ether);
        token1.approve(address(swapRouter), 100 ether);
        token0.mint(address(this), 100 ether);
        token1.mint(address(this), 100 ether);
        /*modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether));
        modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-120, 120, 10 ether));
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10 ether)
        );*/
    }


    function testPlaceholder() public {
        console.log("testPlaceholder");
        console.log(token0.balanceOf(address(vipHook)));
        console.log(token0.balanceOf(address(swapRouter)));
        console.log(token0.balanceOf(address(this)));

        int24 tickLower = 0;
        bool zeroForOne = true;
        uint128 liquidity = 1000000;
        // vipHook.place(poolKey, tickLower, zeroForOne, liquidity);

        modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether));

        BalanceDelta balanceDelta = swapRouter.swap(
            poolKey,
            IPoolManager.SwapParams(false, 1 ether, TickMath.getSqrtRatioAtTick(60)),
            PoolSwapTest.TestSettings(true, true)
        );

        (, int24 tick,,,,) = manager.getSlot0(poolId);
        assertEq(tick, 60);
    }

}