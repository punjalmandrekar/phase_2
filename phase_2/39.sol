// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use multiple require checks
CONCEPT: Execution guards
=========================================================

OBJECTIVE

- Learn how multiple require() checks work
- Understand execution guards in Solidity
- Learn defensive validation patterns
- Understand fail-fast security design

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

require() acts as an execution guard.

If ANY require() fails:
- execution stops
- transaction reverts
- state changes rollback

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Multiple require() checks create:
layered protection.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Smart contracts must validate:
- caller
- values
- balances
- permissions
- timing
- protocol rules

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Multiple require() checks used in:

- ERC20 transfers
- staking contracts
- governance systems
- lending protocols
- NFT minting
- DEX routers

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- missing validations
- incorrect validation order
- bypass possibilities
- access control flaws
- logic assumptions

=========================================================
*/

contract MultipleRequireChecksVul {

    /*
        OWNER ADDRESS

        Set during deployment.
    */
    address public owner;

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
        MAX LIMIT
    */
    uint256 public constant MAX_DEPOSIT = 100 ether;

    /*
        CONSTRUCTOR

        Runs once during deployment.
    */
    constructor() {

        owner = msg.sender;
    }

    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    */

    function deposit(
        uint256 _amount
    )
        external
    {

        /*
            REQUIRE #1

            Amount must be positive.
        */
        require(
            _amount > 0,
            "Amount must be > 0"
        );

        /*
            REQUIRE #2

            Amount must not exceed max limit.
        */
        require(
            _amount <= MAX_DEPOSIT,
            "Deposit too large"
        );

        /*
            REQUIRE #3

            Prevent overflow-like balance growth.
        */
        require(
            balances[msg.sender] + _amount
                <= 1000 ether,
            "Balance limit exceeded"
        );

        /*
            EXECUTION REACHES HERE
            ONLY IF ALL CHECKS PASS.
        */
        balances[msg.sender] += _amount;
    }

    /*
    =====================================================
    OWNER-ONLY RESET
    =====================================================
    */

    function resetBalance(
        address _user
    )
        external
    {

        /*
            REQUIRE #1

            Access control.
        */
        require(
            msg.sender == owner,
            "Not owner"
        );

        /*
            REQUIRE #2

            Reject zero address.
        */
        require(
            _user != address(0),
            "Invalid address"
        );

        /*
            REQUIRE #3

            User must have balance.
        */
        require(
            balances[_user] > 0,
            "No balance"
        );

        /*
            RESET USER BALANCE
        */
        balances[_user] = 0;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(10)

=========================================================

STEP 1:
require(10 > 0)

RESULT:
true

---------------------------------------------------------

STEP 2:
require(10 <= MAX_DEPOSIT)

RESULT:
true

---------------------------------------------------------

STEP 3:
Balance limit check

RESULT:
true

---------------------------------------------------------

ALL CHECKS PASSED

---------------------------------------------------------

STORAGE UPDATE:

balances[msg.sender] += 10

=========================================================
FAILURE TRACE
=========================================================

CALL:
deposit(0)

---------------------------------------------------------

STEP 1:
require(0 > 0)

RESULT:
false

---------------------------------------------------------

TRANSACTION REVERTS IMMEDIATELY

---------------------------------------------------------

IMPORTANT:
Other require() checks never execute.

=========================================================
ANOTHER FAILURE TRACE
=========================================================

CALL:
resetBalance(user)

BY:
non-owner

---------------------------------------------------------

STEP 1:
require(msg.sender == owner)

RESULT:
false

---------------------------------------------------------

EXECUTION STOPS IMMEDIATELY

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(10)

EXPECTED:
Success

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 4:
Call:
deposit(0)

EXPECTED:
Revert

---------------------------------------------------------

STEP 5:
Call:
deposit(500 ether)

EXPECTED:
Revert

---------------------------------------------------------

STEP 6:
Switch account in Remix

---------------------------------------------------------

STEP 7:
Call:
resetBalance(your_address)

EXPECTED:
Revert (not owner)

=========================================================
IMPORTANT REQUIRE UNDERSTANDING
=========================================================

require() acts as:
EXECUTION GUARD.

---------------------------------------------------------

If condition fails:
- execution stops
- revert triggered
- state rolled back

=========================================================
FAIL-FAST PRINCIPLE
=========================================================

Solidity follows:
FAIL FAST design.

---------------------------------------------------------

Bad input:
Stop immediately.

=========================================================
ORDER OF REQUIRE CHECKS
=========================================================

BEST PRACTICE:

1. Cheapest checks first
2. Expensive checks later

---------------------------------------------------------

Reason:
Save gas on early failure.

=========================================================
GOOD VALIDATION ORDER
=========================================================

GOOD:

1. msg.sender checks
2. zero-address checks
3. value checks
4. expensive loops/calls

=========================================================
BAD VALIDATION ORDER
=========================================================

BAD:

1. expensive computation
2. external calls
3. validation later

---------------------------------------------------------

Problem:
Wasted gas and risk.

=========================================================
GAS OBSERVATION
=========================================================

FAILED REQUIRE:
Still consumes gas.

---------------------------------------------------------

Earlier failure:
Usually cheaper.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MISSING REQUIRE CHECKS
---------------------------------------------------------

Very common vulnerability source.

---------------------------------------------------------
2. INCORRECT ACCESS CONTROL
---------------------------------------------------------

Missing owner checks
can destroy protocols.

---------------------------------------------------------
3. VALIDATION ORDER
---------------------------------------------------------

Cheap checks should happen first.

---------------------------------------------------------
4. DEFENSE IN DEPTH
---------------------------------------------------------

Multiple require() checks
create layered security.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Missing require() allows:
- unauthorized access
- invalid balances
- protocol corruption

---------------------------------------------------------

ANOTHER RISK

Incorrect ordering may:
waste gas or expose reentrancy.

=========================================================
REAL AUDITOR QUESTIONS
=========================================================

Auditors ask:

- What assumptions exist?
- Are all assumptions validated?
- Can attacker bypass checks?
- Is access control enforced?
- Are limits bounded safely?

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw() function
2. Add:
   - pause check
   - balance check
   - owner blacklist check

BONUS:
Replace require strings
with custom errors.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- require() creates execution guards
- Failed require() reverts transaction
- Multiple require() checks add layered protection
- Validation order matters
- Cheap checks should execute first
- Fail-fast principle improves safety
- Missing checks create vulnerabilities
- Access control is critical
- Auditors inspect validation carefully
- Defense-in-depth improves smart contract security

=========================================================
*/



/*

Audit Report

Title:
Improper Validation Ordering and Weak Defensive Design in Multiple Require Checks

Severity:
Low

Reason:
The contract correctly uses multiple require() checks for validation and access control.
However, several defensive-security and gas-efficiency improvements are missing:
validation ordering can be optimized further
no event logging exists
no custom errors used
centralized owner reset may become dangerous in larger systems
balance accounting is internal-only and not tied to actual ETH transfers
The contract is educational and mostly secure, but auditors would still flag architectural and best-practice concerns.

Location:
Contract: MultipleRequireChecks

Functions:
deposit()
resetBalance()

Vulnerability Description:
The contract demonstrates layered execution guards using multiple require() statements.

Example:
require(_amount > 0, "Amount must be > 0");
require(
    _amount <= MAX_DEPOSIT,
    "Deposit too large"
);

require(
    balances[msg.sender] + _amount <= 1000 ether,
    "Balance limit exceeded"
);
This follows fail-fast validation correctly.
However, auditors identify several improvement areas:
no event emission
no pause mechanism
owner has unrestricted reset power
string-based revert messages cost more gas
accounting is simulated and not linked to real ETH/token transfers

Impact:
Current impact is LOW because:

validations exist
access control exists
state rollback behavior is safe
Solidity 0.8+ protects arithmetic overflow
However, in production systems these patterns may lead to:
higher gas costs
poor monitoring capability
governance centralization risk
operational visibility issues
difficult off-chain tracking

Proof of Concept:
Successful Deposit
Initial State
balances[Alice] = 0
User Calls
deposit(10)
Execution Flow
Step 1
require(10 > 0)

RESULT:
true
Step 2
require(10 <= MAX_DEPOSIT)

RESULT:
true
Step 3
require(
    balances[Alice] + 10 <= 1000 ether
)

RESULT:
true
Step 4

Storage updated:
balances[Alice] = 10
Failed Deposit
User Calls
deposit(0)
Step 1
require(0 > 0)

RESULT:
false
Transaction Reverts
Execution stops immediately.
No further checks execute.
No storage changes persist.

Root Cause:
The contract is primarily educational and omits several production-grade defensive patterns.

Main issues:
1. No events emitted
2. No emergency pause system
3. Owner can reset balances directly
4. String revert messages increase gas usage
5. Internal accounting not tied to real asset transfers

Recommendation:
Apply stronger defensive engineering practices.

Recommended improvements:
1. Add events
2. Use custom errors
3. Add pause mechanism
4. Limit owner privileges
5. Follow strict CEI pattern
6. Add real ETH/token accounting
*/

//Patched Code

contract MultipleRequireChecksPatched {

    error InvalidAmount();
    error DepositTooLarge();
    error BalanceLimitExceeded();
    error NotOwner();
    error InvalidAddress();
    error NoBalance();

    address public owner;

    mapping(address => uint256) public balances;

    uint256 public constant MAX_DEPOSIT = 100 ether;

    event Deposited(
        address indexed user,
        uint256 amount
    );

    event BalanceReset(
        address indexed user
    );

    constructor() {
        owner = msg.sender;
    }

    function deposit(
        uint256 _amount
    )
        external
    {
        if (_amount == 0) {
            revert InvalidAmount();
        }

        if (_amount > MAX_DEPOSIT) {
            revert DepositTooLarge();
        }

        if (
            balances[msg.sender] + _amount >
            1000 ether
        ) {
            revert BalanceLimitExceeded();
        }

        balances[msg.sender] += _amount;

        emit Deposited(
            msg.sender,
            _amount
        );
    }

    function resetBalance(
        address _user
    )
        external
    {
        if (msg.sender != owner) {
            revert NotOwner();
        }

        if (_user == address(0)) {
            revert InvalidAddress();
        }

        if (balances[_user] == 0) {
            revert NoBalance();
        }

        balances[_user] = 0;

        emit BalanceReset(_user);
    }
}