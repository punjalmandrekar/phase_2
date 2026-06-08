// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trigger out-of-gas scenario
CONCEPT: Execution failure
=========================================================

OBJECTIVE

- Understand what "out of gas" means
- See how loops can cause execution failure
- Learn why gas limits exist
- Think like an auditor about DOS risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Every Ethereum transaction has a GAS LIMIT.

---------------------------------------------------------

If execution consumes more gas than available:

→ transaction REVERTS automatically

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Out-of-gas (OOG) is NOT a normal revert.

It is a HARD EXECUTION FAILURE.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Out-of-gas scenarios cause:

- failed transactions
- stuck operations
- denial of service (DOS)
- unusable functions

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

OOG risks appear in:

- loops over arrays
- batch processing
- staking reward distribution
- token airdrops
- NFT mint batches

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- loop bounds
- gas estimation
- worst-case inputs
- storage-heavy iterations
- external call loops

=========================================================
OUT-OF-GAS CONTRACT
=========================================================
*/

contract OutOfGasDemo {

    /*
        STORAGE ARRAY
    */
    uint256[] public data;

    /*
    =====================================================
    INFINITE LOOP RISK FUNCTION
    =====================================================
    */

    function dangerousLoop()
        external
    {

        /*
        =================================================
        WARNING PATTERN
        =================================================

        This function loops over ALL stored data.

        If array becomes large:
        GAS LIMIT WILL BE EXCEEDED.
        */

        uint256 sum = 0;

        for (
            uint256 i = 0;
            i < data.length;
            i++
        ) {

            /*
                Storage read (expensive).
            */
            sum += data[i];

            /*
                Additional storage write (very expensive).
            */
            data[i] = sum;
        }
    }

    /*
    =====================================================
    ADD MANY VALUES
    =====================================================
    */

    function addMany(uint256 n)
        external
    {

        for (
            uint256 i = 0;
            i < n;
            i++
        ) {

            data.push(i);
        }
    }

    /*
    =====================================================
    SAFE BATCH VERSION
    =====================================================
    */

    function safeProcess(uint256 limit) view 
        external
    {

        /*
            Limit loop size to avoid OOG.
        */
        require(limit <= 100, "Too large batch");

        uint256 sum = 0;

        for (
            uint256 i = 0;
            i < limit;
            i++
        ) {

            sum += data[i];
        }
    }

    /*
    =====================================================
    GET LENGTH
    =====================================================
    */

    function getLength()
        external
        view
        returns (uint256)
    {

        return data.length;
    }
}

/*
=========================================================
EXECUTION FLOW (OUT-OF-GAS SCENARIO)
=========================================================

STEP 1:
Deploy OutOfGasDemo

=========================================================
STEP 2:
CALL:
addMany(10000)

=========================================================

Array grows to:
10000 elements

=========================================================
STEP 3:
CALL:
dangerousLoop()

=========================================================

STEP-BY-STEP EXECUTION
=========================================================

STEP 1:
sum = 0

---------------------------------------------------------

STEP 2:
i = 0 → read data[0]

---------------------------------------------------------

STEP 3:
data[0] updated

---------------------------------------------------------

STEP 4:
i = 1 → read data[1]

---------------------------------------------------------

(repeats thousands of times)

=========================================================
GAS CONSUMPTION GROWS
=========================================================

Each iteration costs:

- storage read
- storage write
- loop increment
- memory operations

=========================================================
CRITICAL MOMENT
=========================================================

At some iteration:

gas remaining < required gas

=========================================================
RESULT
=========================================================

TRANSACTION FAILS:

OUT OF GAS (OOG)

=========================================================
IMPORTANT BEHAVIOR
=========================================================

When OOG happens:

- entire transaction REVERTS
- ALL state changes rollback
- no partial execution persists

=========================================================
FINAL RESULT
=========================================================

data remains unchanged after failure

=========================================================
WHY THIS HAPPENS
=========================================================

Ethereum enforces gas limit per block:

→ prevents infinite computation
→ protects network from abuse

=========================================================
SAFE VERSION TRACE
=========================================================

CALL:
safeProcess(100)

=========================================================

STEP 1:
limit checked

---------------------------------------------------------

limit <= 100

=========================================================
STEP 2:
loop executes safely

---------------------------------------------------------

only 100 iterations

=========================================================
STEP 3:
execution completes successfully

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Out-of-gas is a:

---------------------------------------------------------
HARD EXECUTION FAILURE
---------------------------------------------------------

not a normal revert.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNBOUNDED LOOPS
---------------------------------------------------------

can exceed gas limit

---------------------------------------------------------
2. STORAGE INSIDE LOOP
---------------------------------------------------------

accelerates gas exhaustion

---------------------------------------------------------
3. USER-CONTROLLED INPUT SIZE
---------------------------------------------------------

attackers can force OOG

---------------------------------------------------------
4. DOS VIA GAS LIMIT
---------------------------------------------------------

contract becomes unusable

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- increase array size
- trigger expensive loops
- force OOG condition
- block contract execution

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can loop exceed gas limit?
- Is input size bounded?
- Are storage writes inside loops?
- What is worst-case gas cost?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors calculate:

---------------------------------------------------------
GAS PER ITERATION × MAX SIZE
---------------------------------------------------------

to ensure safety.

=========================================================
BEST PRACTICES
=========================================================

- Always bound loops
- Avoid storage writes in loops
- Use batching techniques
- Validate input size
- Design O(1) or O(log n) logic

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Allow dynamic batch processing
2. Prevent OOG using chunking
3. Compare safe vs unsafe loops
4. Add gas estimator function

BONUS:
Create pagination-based processing system.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Out-of-gas causes transaction failure
- Gas limits protect Ethereum network
- Large loops are dangerous
- Storage operations are expensive
- OOG reverts entire transaction
- Input size must be controlled
- Gas estimation is critical
- Auditors analyze worst-case execution
- Batching avoids gas exhaustion
- Safe design prevents DOS attacks

=========================================================
*/



/*
AUDIT REPORT

Title:
Unbounded Loop May Cause Out-of-Gas Denial of Service

Security:
Medium

Category:
Denial of Service (DoS)
Affected Function:
function dangerousLoop()

Description:
The function iterates through the entire storage array:

for (
uint256 i = 0;
i < data.length;
i++
)

The size of the array is controlled through:
addMany(uint256 n)
There is no upper bound on the array size.
As the array grows, gas consumption grows linearly.
Eventually the transaction may exceed block gas limits and become impossible to execute.

Vulnerable Code:

function dangerousLoop()
external
{
uint256 sum = 0;

for (
    uint256 i = 0;
    i < data.length;
    i++
) {
    sum += data[i];

    data[i] = sum;
}

}

Impact:
An attacker can continuously increase:
data.length
using:
addMany()
Once the array becomes sufficiently large:
dangerousLoop() reverts
functionality becomes unusable
protocol experiences denial of service

Proof of Concept:
Step 1

Call:
addMany(10000)

Result:
data.length = 10000
Step 2

Call:
dangerousLoop()

Result:
Very high gas consumption.

Step 3
Increase array further.
Step 4

Call:
dangerousLoop()

Result:
Out-of-Gas Revert

Root Cause:
Loop execution depends on:
data.length
which has no maximum bound.
Storage writes are also performed inside the loop:
data[i] = sum;
making gas consumption significantly worse.

Recommendation:
Implement batch processing.
Process only a limited number of elements per transaction.
Avoid iterating over the entire storage array in a single call.
*/


//Patch Code

contract OutOfGasDemoPatched {

uint256[] public data;

function addMany(uint256 n)
    external
{
    require(
        n <= 100,
        "Batch too large"
    );

    for (
        uint256 i = 0;
        i < n;
        i++
    ) {
        data.push(i);
    }
}

function safeBatchProcess(
    uint256 start,
    uint256 limit
)
    external
{
    require(
        limit <= 100,
        "Batch too large"
    );

    uint256 end =
        start + limit;

    if (end > data.length) {
        end = data.length;
    }

    uint256 sum = 0;

    for (
        uint256 i = start;
        i < end;
        i++
    ) {
        sum += data[i];

        data[i] = sum;
    }
}

function getLength()
    external
    view
    returns (uint256)
{
    return data.length;
}

}
