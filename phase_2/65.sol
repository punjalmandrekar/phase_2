// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trace external call execution
CONCEPT: Control transfer awareness
=========================================================

OBJECTIVE

- Learn how execution control moves externally
- Understand execution-context switching
- Trace msg.sender across contracts
- Think like auditor during external interactions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

When Contract A calls Contract B:

execution control LEAVES A
and ENTERS B.

---------------------------------------------------------

This is one of the MOST IMPORTANT
security concepts in Solidity.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

External calls are NOT normal jumps.

---------------------------------------------------------

Execution temporarily transfers to:

UNTRUSTED CODE.

---------------------------------------------------------

The called contract controls execution flow
until it returns or reverts.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most Solidity vulnerabilities involve:

- external execution
- reentrancy
- callback attacks
- malicious contracts
- trust assumptions

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls exist in:

- token transfers
- swaps
- lending protocols
- NFT marketplaces
- staking systems
- bridges

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors trace:

- execution switching
- msg.sender transitions
- state before/after calls
- reentrancy windows
- callback opportunities

=========================================================
TARGET CONTRACT
=========================================================
*/

contract ExternalTarget {

    /*
        STORE LAST CALLER
    */
    address public lastCaller;

    /*
        TRACK EXECUTIONS
    */
    uint256 public executionCounter;

    /*
    =====================================================
    TARGET FUNCTION
    =====================================================
    */

    function targetFunction()
        external
    {

        /*
        =================================================
        EXECUTION CONTEXT NOW INSIDE TARGET CONTRACT
        =================================================

        msg.sender becomes:
        calling contract address.
        */

        lastCaller = msg.sender;

        /*
            Increment execution count.
        */
        executionCounter++;
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================
*/

contract ExecutionTracer {

    /*
        TARGET CONTRACT REFERENCE
    */
    ExternalTarget public target;

    /*
        LOCAL EXECUTION TRACKING
    */
    uint256 public localCounter;

    /*
        TRACK EXECUTION STEPS
    */
    string public executionStage;

    /*
        TRACK LAST msg.sender
    */
    address public lastObservedSender;

    /*
        CONSTRUCTOR
    */
    constructor(address _target)
    {

        /*
            Save target contract.
        */
        target = ExternalTarget(_target);
    }

    /*
    =====================================================
    TRACE EXTERNAL EXECUTION
    =====================================================
    */

    function traceExecution()
        external
    {

        /*
        =================================================
        STEP 1
        =================================================

        Execution currently inside:
        ExecutionTracer contract.
        */

        executionStage =
            "Before external call";

        /*
            msg.sender here:
            ORIGINAL USER.
        */
        lastObservedSender =
            msg.sender;

        /*
            Local state update.
        */
        localCounter++;

        /*
        =================================================
        STEP 2
        =================================================

        EXTERNAL CALL HAPPENS HERE.

        CONTROL LEAVES:
        ExecutionTracer

        CONTROL ENTERS:
        ExternalTarget
        */

        target.targetFunction();

        /*
        =================================================
        STEP 3
        =================================================

        External execution finished.

        CONTROL RETURNS:
        back to ExecutionTracer.
        */

        executionStage =
            "After external call";
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy ExternalTarget

---------------------------------------------------------

STEP 2:
Deploy ExecutionTracer

Constructor input:
ExternalTarget address

=========================================================
TRACE:
traceExecution()
=========================================================

STEP 1:
User calls:

traceExecution()

=========================================================
STEP 2
=========================================================

Execution enters:
ExecutionTracer

---------------------------------------------------------

Current contract:
ExecutionTracer

---------------------------------------------------------

msg.sender:
ORIGINAL USER

=========================================================
STEP 3
=========================================================

executionStage =
"Before external call"

---------------------------------------------------------

localCounter++

=========================================================
STEP 4
=========================================================

CRITICAL MOMENT:

target.targetFunction()

=========================================================
IMPORTANT
=========================================================

CONTROL LEAVES:
ExecutionTracer

---------------------------------------------------------

Execution CONTEXT switches externally.

=========================================================
STEP 5
=========================================================

Execution enters:
ExternalTarget

---------------------------------------------------------

Current contract:
ExternalTarget

=========================================================
IMPORTANT msg.sender CHANGE
=========================================================

Inside ExternalTarget:

msg.sender =
ExecutionTracer contract

---------------------------------------------------------

NOT original user.

=========================================================
STEP 6
=========================================================

ExternalTarget executes:

---------------------------------------------------------

lastCaller = ExecutionTracer

---------------------------------------------------------

executionCounter++

=========================================================
STEP 7
=========================================================

ExternalTarget finishes execution.

---------------------------------------------------------

CONTROL RETURNS:
ExecutionTracer

=========================================================
STEP 8
=========================================================

Execution continues AFTER external call.

---------------------------------------------------------

executionStage =
"After external call"

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
ExecutionTracer.localCounter
---------------------------------------------------------

1

---------------------------------------------------------
ExternalTarget.executionCounter
---------------------------------------------------------

1

---------------------------------------------------------
ExternalTarget.lastCaller
---------------------------------------------------------

ExecutionTracer address

=========================================================
CRITICAL SECURITY UNDERSTANDING
=========================================================

During external call:

---------------------------------------------------------
YOUR CONTRACT STOPS EXECUTING
---------------------------------------------------------

and

---------------------------------------------------------
ANOTHER CONTRACT TAKES CONTROL
---------------------------------------------------------

=========================================================
THIS IS DANGEROUS BECAUSE
=========================================================

External contract may:

- revert
- reenter
- consume gas
- manipulate execution
- attack assumptions

=========================================================
VERY IMPORTANT AUDITOR MINDSET
=========================================================

Every external call means:

---------------------------------------------------------
TRUSTING UNKNOWN EXECUTION
---------------------------------------------------------

=========================================================
CONTROL TRANSFER VISUALIZATION
=========================================================

User
  |
  v
ExecutionTracer
  |
  | external call
  v
ExternalTarget
  |
  | return
  v
ExecutionTracer resumes

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy ExternalTarget

---------------------------------------------------------

STEP 2:
Deploy ExecutionTracer

Input:
ExternalTarget address

---------------------------------------------------------

STEP 3:
Call:
traceExecution()

=========================================================
STEP 4
=========================================================

Check:
executionStage()

EXPECTED:
"After external call"

=========================================================
STEP 5
=========================================================

Check:
localCounter()

EXPECTED:
1

=========================================================
STEP 6
=========================================================

Open ExternalTarget

---------------------------------------------------------

Check:
executionCounter()

EXPECTED:
1

---------------------------------------------------------

Check:
lastCaller()

EXPECTED:
ExecutionTracer address

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External calls create:

---------------------------------------------------------
EXECUTION BOUNDARIES
---------------------------------------------------------

and

---------------------------------------------------------
TRUST BOUNDARIES
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

External contract calls back unexpectedly.

---------------------------------------------------------
2. msg.sender CONFUSION
---------------------------------------------------------

Authentication assumptions fail.

---------------------------------------------------------
3. FAILURE PROPAGATION
---------------------------------------------------------

External revert breaks execution.

---------------------------------------------------------
4. MALICIOUS CALLBACKS
---------------------------------------------------------

Execution flow manipulated externally.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers abuse:

- external execution windows
- callback opportunities
- temporary state exposure
- trust assumptions

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Every external jump
2. Control-transfer timing
3. State before call
4. State after call
5. Reentrancy possibilities

=========================================================
WHY CONTROL TRANSFER IS CRITICAL
=========================================================

Most major Solidity exploits happen
during external execution.

---------------------------------------------------------

Understanding control transfer
is foundational for auditing.

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add ETH transfer
2. Add malicious callback
3. Add reentrancy attack
4. Add nested external chain

BONUS:
Trace execution using Remix debugger.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- External calls transfer execution control
- msg.sender changes during nested calls
- Contracts temporarily stop execution
- External contracts are untrusted
- Control eventually returns after execution
- Reentrancy occurs during external execution
- Auditors trace every external jump
- Execution context changes externally
- External calls create attack surface
- Control-transfer awareness is critical for auditing

=========================================================
*/



/*
Audit Report

Title: Missing Validation of External Target Contract Address

Severity: Informational

Category: Trust Assumption / Configuration Risk

Location
constructor(address _target)
{
    target = ExternalTarget(_target);
}

Contract:
ExecutionTracer

Description:
The ExecutionTracer contract accepts an external contract address during deployment and immediately trusts it without validation.
Current implementation:

target = ExternalTarget(_target);
No verification is performed to ensure:
_target is not the zero address.
_target contains deployed contract code.
_target is actually the intended contract.
A deployment mistake may result in broken execution flow or interaction with an unintended contract.

Impact:
Potential impacts include:
Protocol misconfiguration.
Unexpected transaction failures.
Calls to unintended contracts.
Reduced system reliability.
No direct loss of funds exists in the current implementation.

Proof of Concept
Deploy:

ExecutionTracer
with:
0x0000000000000000000000000000000000000000
as _target.

Call:
traceExecution()

Execution:
ExecutionTracer
Invalid Target Address

Result:
Transaction reverts
Execution flow broken

Root Cause:
The constructor blindly trusts a user-supplied external contract address.

Vulnerable code:
constructor(address _target)
{
    target = ExternalTarget(_target);
}
Recommendation

Validate external dependency addresses before storing them.

Example:

require(
    _target != address(0),
    "Zero address"
);

require(
    _target.code.length > 0,
    "Not a contract"
);
*/

//Patch Code

contract ExecutionTracerPatched {

ExternalTarget public target;

uint256 public localCounter;

string public executionStage;

address public lastObservedSender;

constructor(address _target)
{
    require(
        _target != address(0),
        "Zero address"
    );

    require(
        _target.code.length > 0,
        "Not a contract"
    );

    target = ExternalTarget(_target);
}

function traceExecution()
    external
{
    executionStage =
        "Before external call";

    lastObservedSender =
        msg.sender;

    localCounter++;

    target.targetFunction();

    executionStage =
        "After external call";
}

}
