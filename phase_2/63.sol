// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call contract from contract
CONCEPT: Nested execution
=========================================================

OBJECTIVE

- Learn how one contract calls another
- Understand nested execution flow
- Learn msg.sender behavior across contracts
- Understand inter-contract trust assumptions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Contracts can directly interact
with other deployed contracts.

---------------------------------------------------------

Execution may flow like:

User
   ->
Contract A
   ->
Contract B

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

During nested calls:

msg.sender changes.

---------------------------------------------------------

Inside Contract B:

msg.sender =
Contract A

NOT original user.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Modern Solidity systems are:

multi-contract architectures.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Nested calls appear in:

- ERC20 token interactions
- routers
- lending protocols
- staking systems
- NFT marketplaces
- bridges

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- execution flow
- msg.sender transitions
- trust assumptions
- nested state changes
- reentrancy windows

=========================================================
TARGET CONTRACT
=========================================================
*/

contract DataStorage {

    /*
        STORED VALUE
    */
    uint256 public storedNumber;

    /*
        TRACK LAST CALLER
    */
    address public lastCaller;

    /*
    =====================================================
    STORE NUMBER
    =====================================================
    */

    function setNumber(
        uint256 _number
    )
        external
    {

        /*
            Save input.
        */
        storedNumber = _number;

        /*
            Store msg.sender.

            IMPORTANT:
            This will become
            calling contract address
            during nested execution.
        */
        lastCaller = msg.sender;
    }

    /*
    =====================================================
    READ VALUE
    =====================================================
    */

    function getNumber()
        external
        view
        returns (uint256)
    {

        return storedNumber;
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================
*/

contract NestedCaller {

    /*
        TARGET CONTRACT
    */
    DataStorage public target;

    /*
        TRACK LOCAL EXECUTION
    */
    uint256 public localCounter;

    /*
        STORE LAST READ VALUE
    */
    uint256 public lastReadValue;

    /*
        CONSTRUCTOR
    */
    constructor(address _target)
    {

        /*
            Save target contract reference.
        */
        target = DataStorage(_target);
    }

    /*
    =====================================================
    CALL TARGET CONTRACT
    =====================================================
    */

    function callSetNumber(
        uint256 _number
    )
        external
    {

        /*
            Local state update.
        */
        localCounter++;

        /*
            EXTERNAL CONTRACT CALL

            Execution jumps into:
            DataStorage.setNumber()
        */
        target.setNumber(_number);
    }

    /*
    =====================================================
    READ FROM TARGET CONTRACT
    =====================================================
    */

    function readTargetNumber()
        external
    {

        /*
            Nested external read.
        */
        uint256 value =
            target.getNumber();

        /*
            Save locally.
        */
        lastReadValue = value;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy DataStorage

---------------------------------------------------------

STEP 2:
Deploy NestedCaller

Constructor input:
DataStorage address

=========================================================
TRACE:
callSetNumber(100)
=========================================================

STEP 1:
User calls:

NestedCaller.callSetNumber(100)

=========================================================
STEP 2
=========================================================

NestedCaller executes:

localCounter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
STEP 3
=========================================================

External contract call:

target.setNumber(100)

---------------------------------------------------------

Execution CONTEXT switches.

=========================================================
STEP 4
=========================================================

Execution enters:
DataStorage contract

---------------------------------------------------------

storedNumber = 100

=========================================================
STEP 5
=========================================================

IMPORTANT:

Inside DataStorage:

msg.sender =
NestedCaller contract

---------------------------------------------------------

NOT original user.

=========================================================
STEP 6
=========================================================

lastCaller =
NestedCaller address

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
NestedCaller.localCounter
---------------------------------------------------------

1

---------------------------------------------------------
DataStorage.storedNumber
---------------------------------------------------------

100

---------------------------------------------------------
DataStorage.lastCaller
---------------------------------------------------------

NestedCaller address

=========================================================
IMPORTANT msg.sender UNDERSTANDING
=========================================================

FLOW:

User
   ->
NestedCaller
   ->
DataStorage

---------------------------------------------------------

Inside DataStorage:

msg.sender =
NestedCaller

=========================================================
WHY THIS IS IMPORTANT
=========================================================

Authentication logic may fail
if developer assumes:

msg.sender == original user

=========================================================
READ TRACE
=========================================================

CALL:
readTargetNumber()

=========================================================

STEP 1:
NestedCaller calls:

target.getNumber()

=========================================================
STEP 2
=========================================================

Execution enters:
DataStorage

---------------------------------------------------------

storedNumber returned.

=========================================================
STEP 3
=========================================================

Returned value saved:

lastReadValue = storedNumber

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy DataStorage

---------------------------------------------------------

STEP 2:
Deploy NestedCaller

Input:
DataStorage address

---------------------------------------------------------

STEP 3:
Call:
callSetNumber(100)

---------------------------------------------------------

STEP 4:
Open DataStorage

---------------------------------------------------------

STEP 5:
Call:
storedNumber()

EXPECTED:
100

---------------------------------------------------------

STEP 6:
Call:
lastCaller()

EXPECTED:
NestedCaller contract address

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

Nested execution changes:

---------------------------------------------------------
CONTROL FLOW
---------------------------------------------------------

and

---------------------------------------------------------
AUTHENTICATION CONTEXT
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. msg.sender CONFUSION
---------------------------------------------------------

Authentication bypass possible.

---------------------------------------------------------
2. TRUST ASSUMPTIONS
---------------------------------------------------------

External contracts may behave maliciously.

---------------------------------------------------------
3. REENTRANCY
---------------------------------------------------------

Nested calls create callback opportunities.

---------------------------------------------------------
4. FAILURE PROPAGATION
---------------------------------------------------------

Nested revert breaks entire transaction.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers exploit:

- msg.sender assumptions
- nested callback logic
- external state assumptions
- recursive execution

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors trace:

- external jumps
- msg.sender changes
- storage mutations
- nested execution paths
- trust boundaries

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors build:

---------------------------------------------------------
EXECUTION GRAPH
---------------------------------------------------------

to understand:

- control flow
- state dependencies
- attack surface

=========================================================
WHY NESTED EXECUTION IS RISKY
=========================================================

More contracts =
more assumptions.

---------------------------------------------------------

More assumptions =
larger attack surface.

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add ETH transfers
2. Add low-level call()
3. Add failing nested call
4. Add malicious callback contract

BONUS:
Build mini router contract.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Contracts can call other contracts
- Nested execution changes msg.sender
- Execution context switches externally
- Nested calls increase complexity
- External calls create attack surface
- Authentication assumptions are dangerous
- Reverts propagate across nested calls
- Auditors trace execution flow carefully
- Multi-contract systems are harder to secure
- Inter-contract trust assumptions are critical

=========================================================
*/



/*
Audit Report

Title: Missing Validation of External Contract Address

Severity: Informational / Low

Status: Best Practice Improvement

Description:
The NestedCaller contract accepts an external contract address during deployment and stores it without validation.

Current code:
constructor(address _target)
{
    target = DataStorage(_target);
}

The constructor does not verify:
The address is not the zero address.
The address contains deployed contract code.
If an incorrect address is supplied, nested calls may fail unexpectedly, resulting in broken functionality.

Location:
constructor(address _target)
in NestedCaller.

Impact:
Protocol misconfiguration.
Unexpected transaction failures.
Interaction with unintended addresses.
Reduced reliability.
No direct loss of funds exists in the current implementation.

Proof of Concept:
Deploy NestedCaller with:
0x0000000000000000000000000000000000000000

Then call:
callSetNumber(100)
The transaction will fail because no valid target contract exists.

Root Cause:
The constructor blindly trusts user-supplied addresses.

Recommendation:
Validate constructor input before establishing trust.
*/

//Patch Code
contract NestedCallerPatched {

DataStorage public target;

uint256 public localCounter;

uint256 public lastReadValue;

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

    target = DataStorage(_target);
}

function callSetNumber(
    uint256 _number
)
    external
{
    localCounter++;

    target.setNumber(_number);
}

function readTargetNumber()
    external
{
    uint256 value =
        target.getNumber();

    lastReadValue = value;
}

}