// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Pass huge calldata array
CONCEPT: Gas impact
=========================================================

OBJECTIVE

- Understand calldata gas efficiency
- Compare large input handling costs
- Learn why calldata is preferred over memory
- Observe gas impact of large arrays

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

calldata = read-only external input

---------------------------------------------------------

Huge calldata arrays:
do NOT get copied into memory automatically.

---------------------------------------------------------

This makes calldata cheaper than memory.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Gas cost increases with:

- array size
- decoding complexity
- storage writes (if any)
- loops over data

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Large inputs appear in:

- batch transfers
- airdrops
- multicall systems
- oracle feeds
- on-chain aggregation

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- calldata size limits
- loop processing cost
- gas scaling behavior
- DOS via large inputs

=========================================================
CALDATA CONTRACT
=========================================================
*/

contract CalldataGas {

    /*
        STORE PROCESSED SUM
    */
    uint256 public totalSum;

    /*
        TRACK ELEMENT COUNT
    */
    uint256 public totalElements;

    /*
    =====================================================
    PROCESS HUGE CALDATA ARRAY
    =====================================================
    */

    function processCalldataArray(
        uint256[] calldata data
    )
        external
    {

        /*
            Local variable in stack.
        */
        uint256 sum = 0;

        /*
        =================================================
        LOOP OVER CALDATA ARRAY
        =================================================
        */

        for (
            uint256 i = 0;
            i < data.length;
            i++
        ) {

            /*
                READ FROM CALDATA

                Cheap read-only access.
            */
            sum += data[i];

            /*
                Storage update per iteration.
                (expensive part)
            */
            totalElements++;
        }

        /*
            One final storage write.
        */
        totalSum = sum;
    }

    /*
    =====================================================
    COMPARE MEMORY VERSION
    =====================================================
    */

    function processMemoryArray(
        uint256[] memory data
    )
        public
        pure
        returns (uint256)
    {

        uint256 sum = 0;

        for (
            uint256 i = 0;
            i < data.length;
            i++
        ) {

            /*
                Memory access.
            */
            sum += data[i];
        }

        return sum;
    }

    /*
    =====================================================
    GET TOTAL ELEMENTS
    =====================================================
    */

    function getTotalElements()
        external
        view
        returns (uint256)
    {

        return totalElements;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy CalldataGas

=========================================================
TRACE:
processCalldataArray()
=========================================================

INPUT:
Huge uint256[] calldata

Example size:
1000 elements

=========================================================
STEP 2
=========================================================

Function starts.

---------------------------------------------------------

sum = 0

=========================================================
STEP 3
=========================================================

Loop begins:

i = 0

=========================================================
STEP 4
=========================================================

Read:

data[0]

---------------------------------------------------------

Add to sum.

---------------------------------------------------------

sum += data[0]

=========================================================
STEP 5
=========================================================

Storage write:

totalElements++

---------------------------------------------------------

IMPORTANT:
This is expensive.

=========================================================
STEP 6
=========================================================

Loop continues:

i = 1 ... 999

=========================================================
IMPORTANT BEHAVIOR
=========================================================

Each iteration:

---------------------------------------------------------
READ
---------------------------------------------------------

from calldata (cheap)

---------------------------------------------------------
WRITE
---------------------------------------------------------

to storage (expensive)

=========================================================
FINAL STEP
=========================================================

After loop:

totalSum = sum

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
totalElements
---------------------------------------------------------

= number of elements processed

---------------------------------------------------------
totalSum
---------------------------------------------------------

= sum of all values

=========================================================
WHY CALDATA IS IMPORTANT
=========================================================

calldata is:

---------------------------------------------------------
READ-ONLY
---------------------------------------------------------

AND

---------------------------------------------------------
NO COPYING INTO MEMORY
---------------------------------------------------------

=========================================================
GAS ADVANTAGE
=========================================================

Compared to memory:

- NO extra copy cost
- NO allocation overhead
- DIRECT access

=========================================================
BUT IMPORTANT
=========================================================

Gas still increases due to:

---------------------------------------------------------
LOOP PROCESSING
---------------------------------------------------------

AND

---------------------------------------------------------
STORAGE WRITES
---------------------------------------------------------

=========================================================
MEMORY VS CALDATA COMPARISON
=========================================================

---------------------------------------------------------
calldata
---------------------------------------------------------

- cheapest input
- read-only
- no copying
- best for external inputs

=========================================================

---------------------------------------------------------
memory
---------------------------------------------------------

- copied data
- more gas than calldata
- mutable

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
processCalldataArray([1,2,3,...1000])

---------------------------------------------------------

Observe:
moderate gas usage

=========================================================
TEST 2
=========================================================

Call:
processMemoryArray([...1000 values...])

---------------------------------------------------------

Observe:
higher gas than calldata version

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Large calldata inputs can cause:

---------------------------------------------------------
GAS DOS
---------------------------------------------------------

if processing is heavy.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. LARGE INPUT LOOPS
---------------------------------------------------------

Gas scales linearly.

---------------------------------------------------------
2. STORAGE INSIDE LOOP
---------------------------------------------------------

Major gas explosion.

---------------------------------------------------------
3. UNBOUNDED CALDATA SIZE
---------------------------------------------------------

Attacker can send huge arrays.

---------------------------------------------------------
4. DENIAL OF SERVICE
---------------------------------------------------------

Function becomes too expensive.

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- send huge arrays
- force gas exhaustion
- exploit loop scaling
- DOS processing functions

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- calldata size limits
- loop complexity O(n)
- storage writes per iteration
- gas upper bounds
- worst-case execution cost

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors estimate:

---------------------------------------------------------
MAX ARRAY SIZE IMPACT
---------------------------------------------------------

AND

---------------------------------------------------------
BLOCK GAS LIMIT SAFETY
---------------------------------------------------------

=========================================================
BEST PRACTICES
=========================================================

- Use calldata for external inputs
- Avoid storage writes in loops
- Batch processing carefully
- Enforce input size limits
- Prefer O(1) or O(log n) designs

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Limit array size to 500
2. Compare 500 vs 1000 gas usage
3. Remove storage writes in loop
4. Add batch processing function

BONUS:
Create gas-safe streaming processor.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Calldata is cheapest input type
- Large arrays increase gas linearly
- Storage writes dominate gas cost
- calldata avoids memory copy cost
- loops over large inputs are expensive
- gas scaling can cause DOS
- auditors analyze worst-case input size
- calldata is read-only external input
- optimization reduces execution cost
- input validation is critical for security

=========================================================
*/

/*
AUDIT REPORT

Title:
Unbounded Calldata Array Processing Can Cause Gas-Based Denial of Service

Severity:
Medium

Category:
Denial of Service (DoS) / Gas Scalability

Affected Function:

function processCalldataArray(
uint256[] calldata data
)

Description:
The function accepts an arbitrary-sized calldata array and processes every element using a loop.
There is no maximum size validation on the input array.
An attacker or user can submit extremely large arrays causing execution costs to grow linearly with input size.
Additionally, a storage write occurs during every iteration:
totalElements++;
This significantly increases gas consumption.

Vulnerable Code:
for (
uint256 i = 0;
i < data.length;
i++
) {

sum += data[i];

totalElements++;

}

Impact:
An attacker can submit a very large array.

Consequences:
Extremely expensive transactions
Gas exhaustion
Transaction failures
Denial of service conditions
Poor protocol scalability

Worst Case:
A sufficiently large array may exceed the block gas limit causing permanent execution failure.

Proof of Concept:
Example:
processCalldataArray(
uint256[100000]
)

Execution performs:
100000 calldata reads
100000 storage writes

Result:
Transaction likely exceeds practical gas limits and reverts.

Root Cause:
Missing validation on:
data.length
Combined with:
totalElements++;
inside the processing loop.

Recommendation:
Add a maximum array size.
Avoid storage writes inside loops.
Perform aggregation in memory and update storage once after processing.
*/


//Patch Code

contract CalldataGasPatched {

uint256 public totalSum;

uint256 public totalElements;

uint256 public constant MAX_ARRAY_SIZE = 500;

function processCalldataArray(
    uint256[] calldata data
)
    external
{
    require(
        data.length <= MAX_ARRAY_SIZE,
        "Array too large"
    );

    uint256 sum = 0;

    for (
        uint256 i = 0;
        i < data.length;
        i++
    ) {
        sum += data[i];
    }

    totalElements += data.length;

    totalSum = sum;
}

function processMemoryArray(
    uint256[] memory data
)
    public
    pure
    returns (uint256)
{
    uint256 sum = 0;

    for (
        uint256 i = 0;
        i < data.length;
        i++
    ) {
        sum += data[i];
    }

    return sum;
}

function getTotalElements()
    external
    view
    returns (uint256)
{
    return totalElements;
}

}