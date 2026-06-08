// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Vulnerable Reentrancy Bank
CONCEPT: Root reentrancy logic
=========================================================

WARNING:
This contract is INTENTIONALLY VULNERABLE.

DO NOT use in production.
=========================================================
*/

contract VulnerableBank {

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
    WITHDRAW ETH (VULNERABLE)
    =====================================================
    */

    function withdraw(uint256 amount) external {

        /*
        STEP 1:
        Check balance
        */
        require(balance[msg.sender] >= amount, "Not enough balance");

        /*
        STEP 2:
        EXTERNAL CALL FIRST ❌ (DANGER)
        */
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        /*
        STEP 3:
        STATE UPDATE AFTER CALL ❌ (ROOT ISSUE)
        */
        balance[msg.sender] -= amount;
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
Reentrancy Vulnerability in withdraw()

Severity:
Critical

Reason:
External ETH transfer is executed before updating internal state, allowing reentrancy attacks that can drain contract funds.

Location:
Contract: VulnerableBank
Function: withdraw()

Vulnerability Description:
The withdraw() function sends ETH to the caller using:
msg.sender.call{value: amount}("")
before updating the internal balance mapping.
This violates the Checks-Effects-Interactions (CEI) pattern, which requires state updates before external interactions.
Since external calls allow execution of attacker-controlled fallback functions, a malicious contract can re-enter withdraw() multiple times before balance is reduced.

Impact:
An attacker can:
Drain the entire contract balance
Perform multiple withdrawals in a single transaction
Bypass balance restrictions
Cause total loss of all deposited funds
This results in critical financial vulnerability in production systems.

Proof of Concept:
Step 1: Deploy VulnerableBank
Step 2: Attacker deposits ETH
deposit() payable
Step 3: Attacker contract calls withdraw()
contract Attacker {
    VulnerableBank public bank;

    constructor(address _bank) {
        bank = VulnerableBank(_bank);
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdraw(1 ether);
    }

    fallback() external payable {
        if (address(bank).balance > 0) {
            bank.withdraw(1 ether);
        }
    }
}
Step 4: Result
Reentrant calls execute before balance update
Contract funds are drained completely

Root Cause:
External call made before state update
Missing reentrancy protection
CEI pattern not followed

Recommendation:
Fix 1: Follow CEI Pattern
Update state BEFORE external calls.

Fix 2: Add Reentrancy Guard
Use OpenZeppelin ReentrancyGuard with nonReentrant.

Fix 3: Avoid unsafe call patterns when possible
 Patched Code (Remix Compatible FIXED VERSION)
This version avoids OpenZeppelin import issues (works in Remix safely)
*/


// patch code 
contract SecureBank {

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
    WITHDRAW ETH (SECURE)
    =====================================================
    */
    function withdraw(uint256 amount) external {

        // STEP 1: Check balance
        require(balance[msg.sender] >= amount, "Not enough balance");

        // STEP 2: Effects (update state first)
        balance[msg.sender] -= amount;

        // STEP 3: Interaction (external call after update)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /*
    =====================================================
    VIEW BALANCE
    =====================================================
    */
    function getBalance(address user) external view returns (uint256) {
        return balance[user];
    }
}
