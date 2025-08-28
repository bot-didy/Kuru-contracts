//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {FixedPointMathLib} from "../contracts/libraries/FixedPointMathLib.sol";
import {OrderBookErrors, KuruAMMVaultErrors, MarginAccountErrors} from "../contracts/libraries/Errors.sol";
import {IOrderBook} from "../contracts/interfaces/IOrderBook.sol";
import {KuruAMMVault} from "../contracts/KuruAMMVault.sol";
import {OrderBook} from "../contracts/OrderBook.sol";
import {KuruForwarder} from "../contracts/KuruForwarder.sol";
import {MarginAccount} from "../contracts/MarginAccount.sol";
import {Router} from "../contracts/Router.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MintableERC20} from "./lib/MintableERC20.sol";

contract POC is Test {
    // These are all configurable parameters
    uint96 constant SIZE_PRECISION = 10 ** 10;
    uint32 constant PRICE_PRECISION = 10 ** 4;
    uint32 constant TICK_SIZE = 10 ** 2;
    uint96 constant MIN_SIZE = 10 ** 8;
    uint96 constant MAX_SIZE = 10 ** 14;
    uint256 constant TAKER_FEE_BPS = 0;
    uint256 constant MAKER_FEE_BPS = 0;
    uint96 constant VAULT_SPREAD = 30;

    address BASE_TOKEN;
    address QUOTE_TOKEN;
    Router router;
    MarginAccount marginAccount;
    KuruForwarder kuruForwarder;
    OrderBook orderBook;
    KuruAMMVault kuruAmmVault;

    address FEE_COLLECTOR = makeAddr("FEE_COLLECTOR");

    function setUp() public {
        // Configure the market type as you need
        OrderBook.OrderBookType _type = IOrderBook.OrderBookType.NO_NATIVE;
        if (uint8(_type) == 0) {
            // NO_NATIVE
            MintableERC20 baseToken = new MintableERC20("BASE Token", "BASE");
            MintableERC20 quoteToken = new MintableERC20(
                "QUOTE Token",
                "QUOTE"
            );
            BASE_TOKEN = address(baseToken);
            QUOTE_TOKEN = address(quoteToken);
        } else if (uint8(_type) == 1) {
            // NATIVE_IN_BASE
            BASE_TOKEN = address(0);
            MintableERC20 quoteToken = new MintableERC20(
                "QUOTE Token",
                "QUOTE"
            );
            QUOTE_TOKEN = address(quoteToken);
        } else if (uint8(_type) == 2) {
            // NATIVE_IN_QUOTE
            MintableERC20 baseToken = new MintableERC20("BASE Token", "BASE");
            BASE_TOKEN = address(baseToken);
            QUOTE_TOKEN = address(0);
        }

        Router routerImplementation = new Router();
        MarginAccount marginAccountImplementation = new MarginAccount();
        OrderBook orderBookImplementation = new OrderBook();
        KuruAMMVault kuruAmmVaultImplementation = new KuruAMMVault();
        KuruForwarder kuruForwarderImplementation = new KuruForwarder();
        router = Router(
            payable(new ERC1967Proxy(address(routerImplementation), ""))
        );
        kuruForwarder = KuruForwarder(
            (
                address(
                    new ERC1967Proxy(address(kuruForwarderImplementation), "")
                )
            )
        );
        marginAccount = MarginAccount(
            payable(new ERC1967Proxy(address(marginAccountImplementation), ""))
        );
        bytes4[] memory allowedInterfaces = new bytes4[](6);
        allowedInterfaces[0] = OrderBook.addBuyOrder.selector;
        allowedInterfaces[1] = OrderBook.addSellOrder.selector;
        allowedInterfaces[2] = OrderBook.placeAndExecuteMarketBuy.selector;
        allowedInterfaces[3] = OrderBook.placeAndExecuteMarketSell.selector;
        allowedInterfaces[4] = MarginAccount.deposit.selector;
        kuruForwarder.initialize(address(this), allowedInterfaces);
        marginAccount.initialize(
            address(this),
            address(router),
            FEE_COLLECTOR,
            address(kuruForwarder)
        );
        router.initialize(
            address(this),
            address(marginAccount),
            address(orderBookImplementation),
            address(kuruAmmVaultImplementation),
            address(kuruForwarder)
        );
        orderBook = OrderBook(
            router.deployProxy(
                _type,
                BASE_TOKEN,
                QUOTE_TOKEN,
                SIZE_PRECISION,
                PRICE_PRECISION,
                TICK_SIZE,
                MIN_SIZE,
                MAX_SIZE,
                TAKER_FEE_BPS,
                MAKER_FEE_BPS,
                VAULT_SPREAD
            )
        );
    }

    function test_POC_accessibility() public {
        console.log("POC_accessibility");
        console.log("Vault address: ", address(kuruAmmVault));
        console.log("Router address: ", address(router));
        console.log("Margin account address: ", address(marginAccount));
        console.log("Order book address: ", address(orderBook));
    }

    function test_POC() public {}

    function test_BatchWithdrawMaxTokens_NoWithdrawalEvents() public {
        // Arrange: mint and deposit two ERC20 tokens into the MarginAccount for this user
        uint256 amtBase = 1_000 ether;
        uint256 amtQuote = 2_000 ether;

        MintableERC20 base = MintableERC20(BASE_TOKEN);
        MintableERC20 quote = MintableERC20(QUOTE_TOKEN);

        // Mint to this test contract and approve MarginAccount
        base.mint(address(this), amtBase);
        quote.mint(address(this), amtQuote);
        base.approve(address(marginAccount), amtBase);
        quote.approve(address(marginAccount), amtQuote);

        // Deposit into margin account
        marginAccount.deposit(address(this), BASE_TOKEN, amtBase);
        marginAccount.deposit(address(this), QUOTE_TOKEN, amtQuote);

        // Pre-conditions: balances recorded in margin account
        assertEq(marginAccount.getBalance(address(this), BASE_TOKEN), amtBase, "base deposit not recorded");
        assertEq(marginAccount.getBalance(address(this), QUOTE_TOKEN), amtQuote, "quote deposit not recorded");

        // Track local wallet token balances before batch withdrawal
        uint256 baseBefore = base.balanceOf(address(this));
        uint256 quoteBefore = quote.balanceOf(address(this));

        // Act: call batchWithdrawMaxTokens and record logs
        address[] memory toks = new address[](2);
        toks[0] = BASE_TOKEN;
        toks[1] = QUOTE_TOKEN;

        vm.recordLogs();
        marginAccount.batchWithdrawMaxTokens(toks);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Assert: user balances in margin account are zeroed and tokens returned
        assertEq(marginAccount.getBalance(address(this), BASE_TOKEN), 0, "base margin balance not zeroed");
        assertEq(marginAccount.getBalance(address(this), QUOTE_TOKEN), 0, "quote margin balance not zeroed");
        assertEq(base.balanceOf(address(this)), baseBefore + amtBase, "base not returned to user");
        assertEq(quote.balanceOf(address(this)), quoteBefore + amtQuote, "quote not returned to user");

        // Assert: No Withdrawal events were emitted during batch withdraw (bug demonstration)
        // topic0 for Withdrawal(address,address,uint256)
        bytes32 withdrawalSig = keccak256("Withdrawal(address,address,uint256)");
        uint256 found;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == withdrawalSig) {
                found++;
            }
        }
        assertEq(found, 0, "expected no Withdrawal events in batchWithdrawMaxTokens");
    }
}
