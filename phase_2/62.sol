// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Chain multiple external calls
CONCEPT: Complex execution
=========================================================

OBJECTIVE

- Learn chained external execution flow
- Understand multi-contract interactions
- Learn failure propagation behavior
- Think like protocol auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

One contract may call:
another contract,
which calls another contract.

---------------------------------------------------------

Execution chains become:

Contract A
    ->
Contract B
    ->
Contract C

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Every external call:

- changes execution context
- changes msg.sender
- creates attack surface
- may revert entire chain

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Modern DeFi heavily relies on:

multi-contract execution chains.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Chained calls appear in:

- swaps
- lending
- flash loans
- routers
- bridges
- multicall systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- nested external calls
- failure propagation
- trust assumptions
- reentrancy windows
- state consistency

=========================================================
CONTRACT C
FINAL TARGET
=========================================================
*/

contract ContractC {

    /*
        TRACK EXECUTION
    */
    uint256 public counter;

    /*
    =====================================================
    FINAL EXECUTION
    =====================================================
    */

    function finalStep()
        external
    {

        /*
            Increment execution counter.
        */
        counter++;
    }

    /*
    =====================================================
    FAILING FUNCTION
    =====================================================
    */

    function failStep()
        external
        pure
    {

        revert("Contract C failure");
    }
}

/*
=========================================================
CONTRACT B
MIDDLE CONTRACT
=========================================================
*/

contract ContractB {

    /*
        STORE CONTRACT C
    */
    ContractC public contractC;

    /*
        TRACK EXECUTION
    */
    uint256 public middleCounter;

    /*
        CONSTRUCTOR
    */
    constructor(address _contractC)
    {

        contractC = ContractC(_contractC);
    }

    /*
    =====================================================
    CALL CONTRACT C
    =====================================================
    */

    function callFinalStep()
        external
    {

        /*
            Local state update.
        */
        middleCounter++;

        /*
            EXTERNAL CALL:
            Contract B -> Contract C
        */
        contractC.finalStep();
    }

    /*
    =====================================================
    CALL FAILING FUNCTION
    =====================================================
    */

    function callFailingStep()
        external
    {

        /*
            State update.
        */
        middleCounter++;

        /*
            External call that reverts.
        */
        contractC.failStep();
    }
}

/*
=========================================================
CONTRACT A
ENTRY CONTRACT
=========================================================
*/

contract ContractA {

    /*
        STORE CONTRACT B
    */
    ContractB public contractB;

    /*
        TRACK EXECUTION
    */
    uint256 public entryCounter;

    /*
        CONSTRUCTOR
    */
    constructor(address _contractB)
    {

        contractB = ContractB(_contractB);
    }

    /*
    =====================================================
    START EXECUTION CHAIN
    =====================================================
    */

    function startChain()
        external
    {

        /*
            Local state update.
        */
        entryCounter++;

        /*
            EXTERNAL CALL:
            Contract A -> Contract B
        */
        contractB.callFinalStep();
    }

    /*
    =====================================================
    START FAILING CHAIN
    =====================================================
    */

    function startFailingChain()
        external
    {

        /*
            State update.
        */
        entryCounter++;

        /*
            Nested call chain eventually fails.
        */
        contractB.callFailingStep();
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

DEPLOY ORDER:

1. Deploy ContractC
2. Deploy ContractB
3. Deploy ContractA

---------------------------------------------------------

Constructor wiring:

ContractB -> ContractC
ContractA -> ContractB

=========================================================
TRACE:
startChain()
=========================================================

STEP 1:
User calls:

ContractA.startChain()

=========================================================
STEP 2
=========================================================

ContractA updates storage.

---------------------------------------------------------

entryCounter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
STEP 3
=========================================================

External call:

ContractA
    ->
ContractB.callFinalStep()

=========================================================
STEP 4
=========================================================

Execution enters:
ContractB

---------------------------------------------------------

middleCounter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
STEP 5
=========================================================

Another external call:

ContractB
    ->
ContractC.finalStep()

=========================================================
STEP 6
=========================================================

Execution enters:
ContractC

---------------------------------------------------------

counter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
FINAL RESULT
=========================================================

All contracts updated successfully.

---------------------------------------------------------

ContractA.entryCounter = 1

ContractB.middleCounter = 1

ContractC.counter = 1

=========================================================
IMPORTANT EXECUTION UNDERSTANDING
=========================================================

Execution CONTEXT switches
during every external call.

=========================================================
msg.sender FLOW
=========================================================

---------------------------------------------------------
Inside ContractA
---------------------------------------------------------

msg.sender = User

---------------------------------------------------------
Inside ContractB
---------------------------------------------------------

msg.sender = ContractA

---------------------------------------------------------
Inside ContractC
---------------------------------------------------------

msg.sender = ContractB

=========================================================
VERY IMPORTANT
=========================================================

msg.sender changes at EACH hop.

=========================================================
FAILING CHAIN TRACE
=========================================================

CALL:
startFailingChain()

=========================================================

STEP 1:
ContractA updates:

entryCounter++

=========================================================
STEP 2
=========================================================

ContractA calls:
ContractB

=========================================================
STEP 3
=========================================================

ContractB updates:

middleCounter++

=========================================================
STEP 4
=========================================================

ContractB calls:
ContractC.failStep()

=========================================================
STEP 5
=========================================================

ContractC reverts:

"Contract C failure"

=========================================================
IMPORTANT
=========================================================

Revert propagates upward.

---------------------------------------------------------

ContractC
    ->
ContractB
    ->
ContractA

=========================================================
FINAL RESULT
=========================================================

ENTIRE transaction reverts.

---------------------------------------------------------

ALL previous state updates rollback.

=========================================================
ROLLBACK OBSERVATION
=========================================================

Even though:

entryCounter++

and

middleCounter++

already executed,

---------------------------------------------------------

ALL changes revert atomically.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy ContractC

---------------------------------------------------------

STEP 2:
Deploy ContractB

Input:
ContractC address

---------------------------------------------------------

STEP 3:
Deploy ContractA

Input:
ContractB address

---------------------------------------------------------

STEP 4:
Call:
startChain()

---------------------------------------------------------

STEP 5:
Check all counters

EXPECTED:
all incremented

=========================================================
STEP 6
=========================================================

Call:
startFailingChain()

---------------------------------------------------------

EXPECTED:
full transaction revert

=========================================================
STEP 7
=========================================================

Check counters again.

---------------------------------------------------------

IMPORTANT:
No new increments occurred.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Nested external calls create:

---------------------------------------------------------
COMPLEX EXECUTION FLOW
---------------------------------------------------------

and

---------------------------------------------------------
LARGER ATTACK SURFACE
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

Nested calls may reenter earlier contracts.

---------------------------------------------------------
2. FAILURE PROPAGATION
---------------------------------------------------------

One revert breaks entire chain.

---------------------------------------------------------
3. msg.sender CONFUSION
---------------------------------------------------------

Authentication assumptions fail.

---------------------------------------------------------
4. TRUST ASSUMPTIONS
---------------------------------------------------------

External contracts may behave maliciously.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers abuse:

- nested execution
- callback chains
- external state assumptions
- recursive interactions

---------------------------------------------------------

Complexity increases risk heavily.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors trace:

- every external jump
- every state mutation
- every revert path
- msg.sender transitions
- reentrancy windows

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors build:

---------------------------------------------------------
FULL EXECUTION GRAPH
---------------------------------------------------------

to understand:

- control flow
- state dependencies
- attack surface

=========================================================
WHY COMPLEXITY IS DANGEROUS
=========================================================

More external calls =
more assumptions.

---------------------------------------------------------

More assumptions =
more vulnerabilities.

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add ETH transfers
2. Add low-level call()
3. Add try/catch handling
4. Add malicious reentrant contract

BONUS:
Create mini DeFi router chain.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Contracts can chain external calls
- msg.sender changes across contracts
- Nested execution increases complexity
- Reverts propagate upward
- Transactions rollback atomically
- External calls create attack surface
- Multi-contract systems are harder to audit
- Auditors trace full execution chains
- Complex execution increases security risk
- Inter-contract trust assumptions matter heavily

=========================================================
*/



/*
Audit Report

Title
Missing Validation of Trusted External Contract Addresses

Security:
Low

Reason:
The contracts rely on externally supplied contract addresses during deployment:
constructor(address _contractC)
{
    contractC = ContractC(_contractC);
}

and

constructor(address _contractB)
{
    contractB = ContractB(_contractB);
}
No validation is performed to verify that the supplied address is a valid deployed contract.
A wrong or malicious address can break the execution chain.

Location:
Contract: ContractB
Function: Constructor
constructor(address _contractC)
Contract: ContractA
Function: Constructor
constructor(address _contractB)

Vulnerability Description:
The execution chain depends on:
ContractA
ContractB
ContractC

The addresses are provided externally during deployment.
If a deployer accidentally supplies:
EOA address
Zero address
Wrong contract
Malicious contract
the chain may:
Fail unexpectedly
Revert continuously
Execute unintended logic
Since no validation exists, the contracts trust the provided addresses completely.

Impact:
Potential impacts include:
Broken execution chain
Unexpected transaction reverts
Protocol misconfiguration
Interaction with malicious contracts
Reduced protocol reliability
No direct theft of funds exists in the current implementation.

Proof of Concept:
Deploy:
ContractC

Instead of passing ContractC's address to ContractB, pass:
0x0000000000000000000000000000000000000000

Then call:
startChain()

Execution:
ContractA
ContractB
Invalid Address

Result:
Execution fails
Transaction reverts
Protocol functionality unavailable

Root Cause:
Missing validation of external contract addresses.
Current implementation:
constructor(address _contractC)
{
    contractC = ContractC(_contractC);
}

and

constructor(address _contractB)
{
    contractB = ContractB(_contractB);
}

Blindly trust user-supplied addresses.

Recommendation:
Validate that:
Address is not zero
Address contains deployed code

Example:
require(
    _contractC != address(0),
    "Invalid address"
);

require(
    _contractC.code.length > 0,
    "Not a contract"
);

Apply the same validation for _contractB.
*/

//Patched Code
contract ContractBPatched {
    
ContractC public contractC;

uint256 public middleCounter;

constructor(address _contractC)
{
    require(
        _contractC != address(0),
        "Zero address"
    );

    require(
        _contractC.code.length > 0,
        "Not a contract"
    );

    contractC = ContractC(_contractC);
}

function callFinalStep()
    external
{
    middleCounter++;

    contractC.finalStep();
}

function callFailingStep()
    external
{
    middleCounter++;

    contractC.failStep();
}

}

contract ContractAPatched {

ContractBPatched public contractB;

uint256 public entryCounter;

constructor(address _contractB)
{
    require(
        _contractB != address(0),
        "Zero address"
    );

    require(
        _contractB.code.length > 0,
        "Not a contract"
    );

    contractB = ContractBPatched(_contractB);
}

function startChain()
    external
{
    entryCounter++;

    contractB.callFinalStep();
}

function startFailingChain()
    external
{
    entryCounter++;

    contractB.callFailingStep();
}

}
