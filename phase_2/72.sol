// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use repeated storage writes
CONCEPT: Expensive operations
=========================================================

OBJECTIVE

- Understand cost of repeated storage updates
- See how gas scales with state writes
- Learn why storage-heavy loops are dangerous
- Think like auditor about optimization risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Every storage write costs gas.

---------------------------------------------------------

Repeated storage writes inside loops:
become VERY expensive quickly.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Storage writes:

- modify blockchain state
- are permanently stored
- require high gas

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Repeated writes can cause:

- high transaction cost
- out-of-gas failure
- denial of service
- unscalable contracts

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Repeated writes appear in:

- reward updates
- counters
- staking systems
- voting systems
- accounting updates

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- write frequency
- loop-based storage updates
- redundant state changes
- gas inefficiencies
- optimization opportunities

=========================================================
EXPENSIVE STORAGE CONTRACT
=========================================================
*/

contract RepeatedStorageWrites {

    /*
        STORAGE VARIABLES
    */
    uint256 public counter;
    uint256 public lastValue;

    /*
        STORAGE ARRAY
    */
    uint256[] public history;

    /*
    =====================================================
    HEAVY STORAGE WRITE LOOP
    =====================================================
    */

    function heavyWrites(uint256 n)
        external
    {

        /*
            Loop controlled by user input.
        */
        for (
            uint256 i = 0;
            i < n;
            i++
        ) {

            /*
            =============================================
            EXPENSIVE OPERATION 1
            =============================================

            Increment storage variable.
            */
            counter++;

            /*
            =============================================
            EXPENSIVE OPERATION 2
            =============================================
            */
            lastValue = i;

            /*
            =============================================
            EXPENSIVE OPERATION 3
            =============================================
            */
            history.push(i);
        }
    }

    /*
    =====================================================
    OPTIMIZED VERSION
    =====================================================
    */

    function optimizedWrites(uint256 n)
        external
    {

        /*
            Local variable (cheap).
        */
        uint256 tempCounter = counter;

        uint256 tempValue = 0;

        uint256[] memory tempArray =
            new uint256[](n);

        for (
            uint256 i = 0;
            i < n;
            i++
        ) {

            /*
                ONLY memory operations inside loop.
            */
            tempCounter++;

            tempValue = i;

            tempArray[i] = i;
        }

        /*
            SINGLE storage write operations.
        */
        counter = tempCounter;
        lastValue = tempValue;

        /*
            Write array once (optional pattern).
        */
        for (
            uint256 i = 0;
            i < n;
            i++
        ) {

            history.push(tempArray[i]);
        }
    }

    /*
    =====================================================
    GET HISTORY LENGTH
    =====================================================
    */

    function getHistoryLength()
        external
        view
        returns (uint256)
    {

        return history.length;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy RepeatedStorageWrites

=========================================================
TRACE:
heavyWrites(n)
=========================================================

INPUT:
n = 100

=========================================================
STEP 2
=========================================================

Loop starts:

i = 0

=========================================================
STEP 3
=========================================================

STORAGE WRITE #1:

counter++

=========================================================
STEP 4
=========================================================

STORAGE WRITE #2:

lastValue = 0

=========================================================
STEP 5
=========================================================

STORAGE WRITE #3:

history.push(0)

=========================================================
STEP 6
=========================================================

Repeat for i = 1 ... 99

=========================================================
IMPORTANT OBSERVATION
=========================================================

Each iteration performs:

---------------------------------------------------------
3 STORAGE WRITES
---------------------------------------------------------

Total:

100 × 3 = 300 writes

=========================================================
GAS IMPACT
=========================================================

This becomes VERY expensive.

---------------------------------------------------------

May lead to:

- high transaction cost
- gas limit issues
- execution failure

=========================================================
OPTIMIZED FLOW
=========================================================

CALL:
optimizedWrites(100)

=========================================================

STEP 1:
All computation happens in memory.

=========================================================
STEP 2
=========================================================

Only 2 final storage writes:

---------------------------------------------------------
counter = tempCounter
lastValue = tempValue

=========================================================
STEP 3
=========================================================

history updated in batch style.

=========================================================
IMPORTANT RESULT
=========================================================

Same outcome,
MUCH lower gas cost.

=========================================================
WHY THIS MATTERS
=========================================================

Storage writes are the MOST expensive
EVM operation.

---------------------------------------------------------

Reducing them improves scalability.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
heavyWrites(100)

---------------------------------------------------------

Observe:
HIGH gas usage

=========================================================
TEST 2
=========================================================

Call:
optimizedWrites(100)

---------------------------------------------------------

Observe:
lower gas usage

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Repeated storage writes cause:

---------------------------------------------------------
GAS EXPLOSION
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. LOOPED STORAGE WRITES
---------------------------------------------------------

very expensive pattern

---------------------------------------------------------
2. UNNECESSARY STATE UPDATES
---------------------------------------------------------

wasted gas

---------------------------------------------------------
3. USER CONTROLLED n
---------------------------------------------------------

can trigger DOS

---------------------------------------------------------
4. SCALABILITY FAILURE
---------------------------------------------------------

contract becomes unusable

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- increase n
- force heavy writes
- trigger gas exhaustion
- block execution

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- number of storage writes per call
- loop complexity
- worst-case gas cost
- user-controlled input size

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors calculate:

---------------------------------------------------------
writes_per_iteration × max_iterations
---------------------------------------------------------

to estimate risk.

=========================================================
BEST PRACTICES
=========================================================

- Minimize storage writes
- Batch updates
- Use memory for intermediate data
- Avoid per-iteration state changes
- Validate input size

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Limit n to 50
2. Compare gas usage
3. Add event logging instead of storage
4. Remove history array writes

BONUS:
Create event-based accounting system.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage writes are expensive
- Repeated writes increase gas linearly
- Loops with state changes are dangerous
- Memory is cheaper than storage
- Batch updates improve efficiency
- User-controlled loops can cause DOS
- Gas optimization is critical
- Auditors analyze write frequency
- Scalability depends on storage design
- Efficient state management is essential

=========================================================
*/


/*
AUDIT REPORT

Title:
Unbounded User-Controlled Loop May Cause Gas-Based Denial of Service

Severity:
Medium

Category:
Denial of Service (DoS) / Gas Scalability

Affected Function:
function heavyWrites(uint256 n)

Description:
The function accepts a user-controlled parameter:

uint256 n

and performs multiple storage writes during every loop iteration.
The larger the supplied value of n, the larger the gas consumption.
There is no validation limiting the maximum value of n.
A sufficiently large value can cause:
Out-of-Gas reverts
Failed transactions
Denial of service conditions

Vulnerable Code

for (
uint256 i = 0;
i < n;
i++
) {

counter++;

lastValue = i;

history.push(i);

}

Impact:
Each iteration performs:
counter++
lastValue = i
history.push(i)
This creates multiple expensive storage writes.

Example:
heavyWrites(100)
≈ 300 storage writes
heavyWrites(1000)
≈ 3000 storage writes
heavyWrites(10000)
May exceed practical gas limits.

Result:
Transaction reverts.

Root Cause:
User controls:
n
without any upper bound.
Storage writes occur inside the loop.

Proof of Concept:
Call:
heavyWrites(5000)

Result:
Very high gas consumption.

Call:
heavyWrites(50000)

Result:
Likely Out-of-Gas failure.

Recommendation:
Limit maximum value of n.
Move storage updates outside loops where possible.
Use memory variables for intermediate calculations.
*/

//Patch Code

contract RepeatedStorageWritesPatched {

uint256 public counter;

uint256 public lastValue;

uint256[] public history;

uint256 public constant MAX_BATCH = 100;

function heavyWrites(
    uint256 n
)
    external
{
    require(
        n <= MAX_BATCH,
        "Batch too large"
    );

    uint256 tempCounter =
        counter;

    uint256 tempLastValue =
        lastValue;

    for (
        uint256 i = 0;
        i < n;
        i++
    ) {
        tempCounter++;

        tempLastValue = i;

        history.push(i);
    }

    counter = tempCounter;

    lastValue = tempLastValue;
}

function getHistoryLength()
    external
    view
    returns (uint256)
{
    return history.length;
}

}




