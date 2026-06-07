// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Ignore success boolean from call
CONCEPT: Dangerous coding
=========================================================

OBJECTIVE

- Learn why unchecked call() is dangerous
- Understand silent external-call failures
- Learn inconsistent state vulnerabilities
- Think like professional auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Low-level call() returns:

(bool success, bytes memory data)

---------------------------------------------------------

If success is ignored:

execution may continue
even when external call FAILED.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

This creates:
silent failure vulnerabilities.

---------------------------------------------------------

Protocol may assume:
external interaction succeeded.

---------------------------------------------------------

Reality:
it failed completely.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Unchecked external calls caused:

- stuck funds
- accounting corruption
- broken logic
- DOS vulnerabilities
- protocol inconsistencies

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls exist in:

- token transfers
- swaps
- governance execution
- vault withdrawals
- bridges
- staking systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors ALWAYS inspect:

- ignored success booleans
- unchecked external calls
- silent failures
- accounting assumptions
- inconsistent state

=========================================================
MALICIOUS / FAILING CONTRACT
=========================================================
*/

contract RejectETHVul {

    /*
        Track calls
    */
    uint256 public counter;

    /*
    =====================================================
    ALWAYS REVERT ON ETH
    =====================================================
    */

    receive()
        external
        payable
    {

        revert("ETH rejected");
    }

    /*
    =====================================================
    ALWAYS FAIL FUNCTION
    =====================================================
    */

    function failFunction()
        external
        pure
    {

        revert("Function failed");
    }

    /*
    =====================================================
    SUCCESS FUNCTION
    =====================================================
    */

    function successFunction()
        external
    {

        /*
            Increment counter.
        */
        counter++;
    }
}

/*
=========================================================
VULNERABLE CONTRACT
=========================================================
*/

contract DangerousUncheckedCallVul {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
        TRACK WITHDRAWALS
    */
    mapping(address => bool) public withdrawn;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    */

    function deposit()
        external
        payable
    {

        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    DANGEROUS WITHDRAW
    =====================================================

    PROBLEM:
    ignores success boolean.
    */

    function dangerousWithdraw(
        address payable _receiver,
        uint256 _amount
    )
        external
    {

        /*
            Validate balance.
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS:
            Update storage FIRST.
        */
        balances[msg.sender] -= _amount;

        withdrawn[msg.sender] = true;

        /*
        =================================================
        DANGEROUS EXTERNAL CALL
        =================================================

        ETH transfer may FAIL.

        BUT:
        success boolean ignored.
        */

        _receiver.call{
            value: _amount
        }("");

        /*
            Execution continues regardless.

            HUGE PROBLEM.
        */
    }

    /*
    =====================================================
    SAFE VERSION
    =====================================================
    */

    function safeWithdraw(
        address payable _receiver,
        uint256 _amount
    )
        external
    {

        /*
            Validate balance.
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            Update storage.
        */
        balances[msg.sender] -= _amount;

        /*
            Properly check success.
        */
        (bool success, ) =
            _receiver.call{
                value: _amount
            }("");

        /*
            Revert if transfer failed.
        */
        require(
            success,
            "ETH transfer failed"
        );
    }

    /*
    =====================================================
    CHECK CONTRACT BALANCE
    =====================================================
    */

    function contractBalance()
        external
        view
        returns (uint256)
    {

        return address(this).balance;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy RejectETH

---------------------------------------------------------

STEP 2:
Deploy DangerousUncheckedCall

=========================================================
TRACE:
dangerousWithdraw()
=========================================================

STEP 1:
User deposits ETH.

---------------------------------------------------------

balances[user] = 1 ETH

=========================================================
STEP 2
=========================================================

Call:
dangerousWithdraw()

---------------------------------------------------------

Receiver:
RejectETH contract

=========================================================
STEP 3
=========================================================

Balance validation passes.

=========================================================
STEP 4
=========================================================

Storage updated FIRST.

---------------------------------------------------------

balances[user] -= 1 ETH

---------------------------------------------------------

withdrawn[user] = true

=========================================================
STEP 5
=========================================================

External ETH call executes.

---------------------------------------------------------

Receiver contract:
REVERTS intentionally.

=========================================================
STEP 6
=========================================================

IMPORTANT:

call() returns:

success = false

---------------------------------------------------------

BUT:

success is IGNORED.

=========================================================
STEP 7
=========================================================

Execution continues normally.

---------------------------------------------------------

Transaction DOES NOT revert.

=========================================================
FINAL RESULT
=========================================================

PROBLEM:

---------------------------------------------------------
USER BALANCE REDUCED
---------------------------------------------------------

YES

---------------------------------------------------------
withdrawn FLAG SET
---------------------------------------------------------

YES

---------------------------------------------------------
ETH ACTUALLY TRANSFERRED?
---------------------------------------------------------

NO

=========================================================
CRITICAL VULNERABILITY
=========================================================

Internal accounting says:
withdraw succeeded.

---------------------------------------------------------

Reality:
ETH never transferred.

=========================================================
WHY THIS IS DANGEROUS
=========================================================

Creates:
INCONSISTENT STATE.

---------------------------------------------------------

Protocol assumptions become false.

=========================================================
SAFE VERSION TRACE
=========================================================

safeWithdraw()

=========================================================

STEP 1:
External call fails.

---------------------------------------------------------

success = false

=========================================================
STEP 2
=========================================================

require(success)

---------------------------------------------------------

Transaction REVERTS.

=========================================================
STEP 3
=========================================================

ALL state changes rollback.

---------------------------------------------------------

balances restored.

---------------------------------------------------------

No inconsistent state.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy RejectETH

---------------------------------------------------------

STEP 2:
Deploy DangerousUncheckedCall

---------------------------------------------------------

STEP 3:
Deposit 1 ETH

---------------------------------------------------------

STEP 4:
Call:
dangerousWithdraw()

Inputs:
- RejectETH address
- 1 ether

---------------------------------------------------------

EXPECTED:
Transaction succeeds unexpectedly.

=========================================================
STEP 5
=========================================================

Check:

balances(user)

EXPECTED:
0

---------------------------------------------------------

withdrawn(user)

EXPECTED:
true

---------------------------------------------------------

BUT:
RejectETH received NO ETH.

=========================================================
STEP 6
=========================================================

Test:
safeWithdraw()

---------------------------------------------------------

EXPECTED:
Transaction reverts safely.

=========================================================
IMPORTANT LOW-LEVEL CALL UNDERSTANDING
=========================================================

call() NEVER auto-reverts.

---------------------------------------------------------

Developer MUST manually check:

success

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNCHECKED RETURN VALUES
---------------------------------------------------------

Classic Solidity vulnerability.

---------------------------------------------------------
2. ACCOUNTING CORRUPTION
---------------------------------------------------------

Internal state diverges from reality.

---------------------------------------------------------
3. SILENT FAILURES
---------------------------------------------------------

Protocol believes operation succeeded.

---------------------------------------------------------
4. DOS CONDITIONS
---------------------------------------------------------

Malicious contracts block execution silently.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External calls are:
UNTRUSTED INTERACTIONS.

---------------------------------------------------------

Assume:
external execution may fail.

=========================================================
ATTACK THINKING
=========================================================

Attacker intentionally:

- rejects ETH
- reverts calls
- breaks assumptions
- causes inconsistent state

---------------------------------------------------------

Protocol logic becomes corrupted.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ALWAYS search for:

---------------------------------------------------------
.call(
---------------------------------------------------------

without:

---------------------------------------------------------
require(success)
---------------------------------------------------------

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External interaction
2. Failure handling
3. Return-value checks
4. Accounting consistency
5. Silent-failure paths

=========================================================
WHY THIS BUG IS SUBTLE
=========================================================

Transaction appears:
successful.

---------------------------------------------------------

But:
protocol state corrupted internally.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add event logging
2. Add try/catch handling
3. Add revert-message decoding
4. Compare checked vs unchecked execution

BONUS:
Create token-transfer version
of unchecked-call bug.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- call() returns success manually
- Ignoring success is dangerous
- External calls may silently fail
- Silent failures corrupt accounting
- Transactions only revert if forced
- require(success) prevents inconsistencies
- Unchecked calls are major audit issue
- External interactions are untrusted
- Auditors inspect return-value handling carefully
- Error handling is critical in Solidity security

=========================================================
*/











/*
Audit Report

Title:
Unchecked Return Value of Low-Level call() Causes Accounting Inconsistency

Severity:
High

Reason:
The contract performs an external ETH transfer using call() but completely ignores the returned success value. If the transfer fails, execution continues and the contract state remains updated as if the transfer succeeded.

Location:
Contract: DangerousUncheckedCall
Function: dangerousWithdraw()

Vulnerability Description:
The function performs an external call:
_receiver.call{value: _amount}("");
However, the returned success value is ignored.
Before the call, the contract updates storage:
balances[msg.sender] -= _amount;
withdrawn[msg.sender] = true;
If _receiver rejects ETH or reverts, the transfer fails:
success = false;
But because the return value is ignored, execution continues normally.

As a result:
User balance is reduced.
Withdrawal flag is set.
ETH is never transferred.
The contract enters an inconsistent state where internal accounting does not match reality.

Impact:
An attacker can:
Force ETH transfers to fail.
Cause accounting corruption.
Mark withdrawals as completed when funds were never received.
Create stuck funds inside the contract.
Cause incorrect protocol behavior.

Potential consequences:
Permanent user fund loss.
Incorrect withdrawal records.
Broken business logic.
Loss of protocol integrity.

Proof of Concept:
Step 1
Deploy:
RejectETH

Step 2
Deploy:
DangerousUncheckedCall

Step 3
Deposit:
1 ETH

User state:
balances[user] = 1 ETH
Step 4

Call:
dangerousWithdraw(
    rejectETHAddress,
    1 ether
)
Step 5

Execution:
Storage updated:
balances[msg.sender] -= 1 ether;
withdrawn[msg.sender] = true;

External call:
_receiver.call{value:_amount}("");

RejectETH executes:
revert("ETH rejected");

Result:
success = false
Ignored by contract.
Final State
balances[user] = 0
withdrawn[user] = true
RejectETH received = 0 ETH
The contract incorrectly believes withdrawal succeeded.

Root Cause:
The return value of a low-level call is ignored.

Vulnerable code:
_receiver.call{
    value:_amount
}("");

No validation exists:
require(success);
Therefore failed external calls do not revert the transaction.

Recommendation:
Always check the return value of low-level calls.

Use:
(bool success,) =
    _receiver.call{
        value:_amount
    }("");

require(
    success,
    "ETH transfer failed"
);

If the transfer fails:
Revert transaction.
Roll back storage changes.
Preserve accounting consistency.
*/




//Patched Code

contract RejectETH {

    uint256 public counter;

    receive()
        external
        payable
    {
        revert("ETH rejected");
    }

    function failFunction()
        external
        pure
    {
        revert("Function failed");
    }

    function successFunction()
        external
    {
        counter++;
    }
}

contract DangerousUncheckedCallPatched {

    mapping(address => uint256) public balances;

    mapping(address => bool) public withdrawn;

    event WithdrawalSuccessful(
        address indexed user,
        address indexed receiver,
        uint256 amount
    );

    function deposit()
        external
        payable
    {
        balances[msg.sender] += msg.value;
    }

    function safeWithdraw(
        address payable _receiver,
        uint256 _amount
    )
        external
    {
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= _amount;

        withdrawn[msg.sender] = true;

        (bool success, ) =
            _receiver.call{
                value: _amount
            }("");

        require(
            success,
            "ETH transfer failed"
        );

        emit WithdrawalSuccessful(
            msg.sender,
            _receiver,
            _amount
        );
    }

    function contractBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}