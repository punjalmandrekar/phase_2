// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Fix Reentrancy using CEI Pattern
CONCEPT: Secure execution order
=========================================================

OBJECTIVE

- Fix reentrancy vulnerability
- Apply Checks → Effects → Interactions pattern
- Ensure secure ETH withdrawal flow
- Prevent recursive external calls exploitation

---------------------------------------------------------
CORE IDEA (CEI PATTERN)
---------------------------------------------------------

✔ CHECKS        → validate conditions
✔ EFFECTS       → update state FIRST
✔ INTERACTIONS  → external calls LAST

---------------------------------------------------------

This prevents reentrancy because:

state is already updated
before external contract can re-enter

=========================================================
SECURE BANK CONTRACT
=========================================================
*/

contract SecureBank {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balance;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    */

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /*
    =====================================================
    SECURE WITHDRAW (FIXED)
    =====================================================
    */

    function withdraw(uint256 amount) external {

        /*
        =================================================
        1. CHECKS
        =================================================
        */
        require(balance[msg.sender] >= amount, "Insufficient balance");

        /*
        =================================================
        2. EFFECTS (STATE UPDATE FIRST) ✅ FIX
        =================================================
        */

        balance[msg.sender] -= amount;

        /*
        =================================================
        3. INTERACTIONS (EXTERNAL CALL LAST)
        =================================================
        */

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /*
    =====================================================
    VIEW BALANCE
    =====================================================
    */

    function getBalance(address user)
        external
        view
        returns (uint256)
    {
        return balance[user];
    }
}



/*
Audit Report
Title:
Reentrancy Fix Using CEI Pattern in Withdraw Function

Severity:
High (Fixed in updated version)

Issue:
The original design risked reentrancy if external calls were made before updating internal state.
Impact (if vulnerable):
Recursive withdrawals
ETH drain from contract
Balance bypass

Root Cause:
Unsafe execution order in withdrawal logic (external call before state update).

Fix Applied:
Implemented Checks → Effects → Interactions (CEI) pattern.
Checks: Validate user balance
Effects: Reduce balance before transfer
Interactions: External call happens last
This ensures that even if reentrancy is attempted, the contract state is already updated.
*/


//Patched Code

contract SecureBankFix {

    mapping(address => uint256) public balance;

    /*
    =========================
    DEPOSIT
    =========================
    */
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /*
    =========================
    WITHDRAW (SECURE - CEI FIX)
    =========================
    */
    function withdraw(uint256 amount) external {

        // CHECKS
        require(balance[msg.sender] >= amount, "Insufficient balance");

        // EFFECTS (state updated first)
        balance[msg.sender] -= amount;

        // INTERACTIONS (external call last)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /*
    =========================
    VIEW BALANCE
    =========================
    */
    function getBalance(address user) external view returns (uint256) {
        return balance[user];
    }
}