// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call internal function
CONCEPT: Internal flow
=========================================================

OBJECTIVE

- Learn how internal functions work
- Understand internal execution flow
- Learn function visibility behavior
- Understand how contracts organize logic internally

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Internal functions:

- can only be called inside contract
- cannot be called externally
- help modularize logic
- reduce code duplication

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Internal calls do NOT create:
external transactions.

Execution stays inside same contract context.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most production contracts heavily use:

- internal helper functions
- internal validation
- internal accounting logic
- reusable internal modules

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Internal functions used in:

- ERC20 transfer logic
- staking calculations
- DeFi accounting
- reward systems
- governance modules
- validation helpers

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- internal call flow
- hidden state mutations
- access assumptions
- recursive risks
- inherited internal logic

=========================================================
*/

contract InternalFunctionFlowVul {

    /*
        STORAGE VARIABLES
    */
    mapping(address => uint256) public balances;

    uint256 public totalDeposits;

    /*
    =====================================================
    EXTERNAL ENTRY FUNCTION
    =====================================================
    */

    function deposit(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Validate input using internal function.
        */
        _validateAmount(_amount);

        /*
            STEP 2:
            Update balance using internal function.
        */
        _updateBalance(
            msg.sender,
            _amount
        );

        /*
            STEP 3:
            Update global state.
        */
        totalDeposits += _amount;
    }

    /*
    =====================================================
    INTERNAL VALIDATION FUNCTION
    =====================================================
    */

    function _validateAmount(
        uint256 _amount
    )
        internal
        pure
    {

        /*
            Internal require check.
        */
        require(
            _amount > 0,
            "Amount must be > 0"
        );

        require(
            _amount <= 100,
            "Amount too large"
        );
    }

    /*
    =====================================================
    INTERNAL STATE UPDATE FUNCTION
    =====================================================
    */

    function _updateBalance(
        address _user,
        uint256 _amount
    )
        internal
    {

        /*
            Internal storage update.
        */
        balances[_user] += _amount;
    }

    /*
    =====================================================
    INTERNAL CALCULATION FUNCTION
    =====================================================
    */

    function _calculateBonus(
        uint256 _amount
    )
        internal
        pure
        returns (uint256)
    {

        /*
            Bonus = 10%
        */
        return (_amount * 10) / 100;
    }

    /*
    =====================================================
    EXTERNAL FUNCTION USING INTERNAL HELPER
    =====================================================
    */

    function depositWithBonus(
        uint256 _amount
    )
        external
    {

        /*
            Internal validation call.
        */
        _validateAmount(_amount);

        /*
            Internal calculation.
        */
        uint256 bonus =
            _calculateBonus(_amount);

        /*
            Internal balance update.
        */
        _updateBalance(
            msg.sender,
            _amount + bonus
        );

        totalDeposits +=
            (_amount + bonus);
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(50)

=========================================================

STEP 1:
External function executes.

---------------------------------------------------------

deposit(50)

---------------------------------------------------------

STEP 2:
Internal function called:

_validateAmount(50)

---------------------------------------------------------

REQUIRE CHECKS:

50 > 0 -> true

50 <= 100 -> true

---------------------------------------------------------

STEP 3:
Internal function returns.

Execution resumes in deposit().

---------------------------------------------------------

STEP 4:
Internal function called:

_updateBalance(Alice, 50)

---------------------------------------------------------

STORAGE UPDATE:

balances[Alice] += 50

---------------------------------------------------------

STEP 5:
totalDeposits += 50

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 50

totalDeposits = 50

=========================================================
IMPORTANT INTERNAL FLOW
=========================================================

Execution NEVER leaves contract.

---------------------------------------------------------

NO external call occurs.

---------------------------------------------------------

NO new transaction created.

=========================================================
TRACE:
depositWithBonus(100)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

_validateAmount(100)

Validation passes.

---------------------------------------------------------
STEP 2
---------------------------------------------------------

_calculateBonus(100)

RESULT:
10

---------------------------------------------------------
STEP 3
---------------------------------------------------------

_updateBalance(Alice, 110)

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

balances[Alice] += 110

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(50)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
50

---------------------------------------------------------

STEP 4:
Call:
totalDeposits()

EXPECTED:
50

---------------------------------------------------------

STEP 5:
Call:
depositWithBonus(100)

---------------------------------------------------------

STEP 6:
Call:
balances(your_address)

EXPECTED:
160

---------------------------------------------------------

OBSERVE:
100 + 10 bonus added

=========================================================
IMPORTANT INTERNAL FUNCTION UNDERSTANDING
=========================================================

internal functions:

- callable only inside contract
- callable by inherited contracts
- invisible externally

=========================================================
INTERNAL VS EXTERNAL
=========================================================

---------------------------------------------------------
INTERNAL
---------------------------------------------------------

- same contract context
- cheaper
- no ABI encoding
- no external call

---------------------------------------------------------
EXTERNAL
---------------------------------------------------------

- callable outside contract
- ABI encoding required
- external transaction possible

=========================================================
WHY INTERNAL FUNCTIONS ARE IMPORTANT
=========================================================

Benefits:

- reusable logic
- cleaner code
- easier auditing
- modular architecture
- reduced duplication

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. HIDDEN STATE CHANGES
---------------------------------------------------------

Internal functions may:
silently modify storage.

---------------------------------------------------------
2. INHERITANCE RISKS
---------------------------------------------------------

Child contracts can access:
internal functions.

---------------------------------------------------------
3. COMPLEX INTERNAL FLOW
---------------------------------------------------------

Deep internal call chains
make auditing harder.

---------------------------------------------------------
4. RECURSION RISK
---------------------------------------------------------

Internal recursive calls
may exhaust gas.

=========================================================
GAS OBSERVATION
=========================================================

Internal calls are:
cheaper than external calls.

---------------------------------------------------------

Reason:
No message call overhead.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Which internal functions modify storage?
- Can inherited contracts abuse them?
- Is execution flow clear?
- Are validations centralized?
- Are internal assumptions safe?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Internal validation omitted
in one execution path.

Result:
logic bypass.

---------------------------------------------------------

ANOTHER RISK

Inherited contract overrides logic
unexpectedly.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Internal call chains
2. Storage mutations
3. Validation flow
4. Reusable helper logic
5. Inheritance behavior

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add internal withdraw helper
2. Add internal fee calculation
3. Add admin-only internal modifier logic

BONUS:
Create inherited child contract
using internal functions.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Internal functions stay inside contract
- Internal calls are cheaper than external calls
- Internal functions organize reusable logic
- Internal execution keeps same context
- Internal functions can modify storage
- Inherited contracts can access internal functions
- Auditors trace internal call chains carefully
- Modular architecture improves maintainability
- Hidden internal logic may create vulnerabilities
- Internal flow understanding is critical for auditing

=========================================================
*/


/*
Audit Report

Title:
Unlimited Bonus Abuse in depositWithBonus()

Severity:
Medium

Reason:
Users can repeatedly claim bonus rewards without any restriction.

Location:
Contract: InternalFunctionFlow
Function: depositWithBonus()

Vulnerability Description:
The depositWithBonus() function gives users a 10% bonus on deposits using the internal function:
_calculateBonus()
However, the contract does not track whether a user already claimed the reward.

Any user can repeatedly call:
depositWithBonus(100)
and continuously receive bonus rewards.

Impact:
An attacker can:
farm unlimited rewards
inflate balances
manipulate accounting
increase totalDeposits unfairly

In real DeFi systems this may lead to:
treasury draining
reward abuse
broken token economics
protocol insolvency

Proof of Concept:
User calls:
depositWithBonus(100)

Bonus calculation:
10% of 100 = 10

Balance update:
balances[user] += 110
Attacker repeats the call multiple times and keeps receiving bonus rewards.

Root Cause:
The contract lacks:
reward tracking
cooldown logic
claim limits
access restrictions
The internal helper function is reusable without protection.

Recommendation:
Add:
one-time bonus claim logic
internal withdraw helper
internal fee calculation
admin-only controls
Track whether bonus was already claimed.
*/

//Patched Code

contract InternalFunctionFlow {

    mapping(address => uint256) public balances;

    mapping(address => bool) public claimedBonus;

    uint256 public totalDeposits;

    uint256 public feePercent = 5;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /*
    =====================================================
    ADMIN MODIFIER
    =====================================================
    */

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Not owner"
        );
        _;
    }

    /*
    =====================================================
    NORMAL DEPOSIT
    =====================================================
    */

    function deposit(
        uint256 _amount
    )
        external
    {
        _validateAmount(_amount);

        uint256 fee =
            _calculateFee(_amount);

        uint256 finalAmount =
            _amount - fee;

        _updateBalance(
            msg.sender,
            finalAmount
        );

        totalDeposits += finalAmount;
    }

    /*
    =====================================================
    BONUS DEPOSIT
    =====================================================
    */

    function depositWithBonus(
        uint256 _amount
    )
        external
    {
        _validateAmount(_amount);

        require(
            !claimedBonus[msg.sender],
            "Bonus already claimed"
        );

        uint256 bonus =
            _calculateBonus(_amount);

        claimedBonus[msg.sender] = true;

        _updateBalance(
            msg.sender,
            _amount + bonus
        );

        totalDeposits +=
            (_amount + bonus);
    }

    /*
    =====================================================
    WITHDRAW
    =====================================================
    */

    function withdraw(
        uint256 _amount
    )
        external
    {
        _internalWithdraw(
            msg.sender,
            _amount
        );
    }

    /*
    =====================================================
    INTERNAL VALIDATION
    =====================================================
    */

    function _validateAmount(
        uint256 _amount
    )
        internal
        pure
    {
        require(
            _amount > 0,
            "Amount must be > 0"
        );

        require(
            _amount <= 100,
            "Amount too large"
        );
    }

    /*
    =====================================================
    INTERNAL BALANCE UPDATE
    =====================================================
    */

    function _updateBalance(
        address _user,
        uint256 _amount
    )
        internal
    {
        balances[_user] += _amount;
    }

    /*
    =====================================================
    INTERNAL BONUS CALCULATION
    =====================================================
    */

    function _calculateBonus(
        uint256 _amount
    )
        internal
        pure
        returns (uint256)
    {
        return (_amount * 10) / 100;
    }

    /*
    =====================================================
    INTERNAL FEE CALCULATION
    =====================================================
    */

    function _calculateFee(
        uint256 _amount
    )
        internal
        view
        returns (uint256)
    {
        return (_amount * feePercent) / 100;
    }

    /*
    =====================================================
    INTERNAL WITHDRAW HELPER
    =====================================================
    */

    function _internalWithdraw(
        address _user,
        uint256 _amount
    )
        internal
    {
        require(
            balances[_user] >= _amount,
            "Insufficient balance"
        );

        balances[_user] -= _amount;
    }

    /*
    =====================================================
    ADMIN FUNCTION
    =====================================================
    */

    function updateFee(
        uint256 _newFee
    )
        external
        onlyOwner
    {
        require(
            _newFee <= 10,
            "Fee too high"
        );

        feePercent = _newFee;
    }
}

/*
=========================================================
BONUS: CHILD CONTRACT USING INTERNAL FUNCTIONS
=========================================================
*/

contract ChildContract is InternalFunctionFlow {

    function childDeposit(
        uint256 _amount
    )
        external
    {
        _validateAmount(_amount);

        _updateBalance(
            msg.sender,
            _amount
        );

        totalDeposits += _amount;
    }
}