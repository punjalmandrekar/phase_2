// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Compare view vs state-changing gas
CONCEPT: Gas optimization
=========================================================

OBJECTIVE

- Learn why view functions are cheaper
- Compare read-only vs storage-modifying execution
- Understand gas optimization basics
- Think like auditor about efficient design

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

READING storage is cheaper than
MODIFYING storage.

---------------------------------------------------------

View functions:
do NOT change blockchain state.

---------------------------------------------------------

State-changing functions:
modify permanent blockchain storage.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Storage writes are among the MOST
expensive EVM operations.

---------------------------------------------------------

View functions avoid:

- storage writes
- state persistence
- blockchain updates

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Gas optimization affects:

- protocol usability
- transaction cost
- scalability
- user experience

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

View functions used for:

- dashboards
- frontend reads
- balances
- analytics
- protocol stats

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- unnecessary storage writes
- expensive logic
- gas-heavy functions
- optimization opportunities

=========================================================
GAS COMPARISON CONTRACT
=========================================================
*/

contract GasComparison {

    /*
        STORAGE VARIABLE
    */
    uint256 public storedNumber;

    /*
        STORAGE ARRAY
    */
    uint256[] public values;

    /*
    =====================================================
    VIEW FUNCTION
    =====================================================

    READS storage only.

    NO state changes.
    */

    function readStoredNumber()
        external
        view
        returns (uint256)
    {

        /*
            Read storage value.
        */
        return storedNumber;
    }

    /*
    =====================================================
    PURE FUNCTION
    =====================================================

    Uses no storage at all.
    */

    function calculateSum(
        uint256 a,
        uint256 b
    )
        external
        pure
        returns (uint256)
    {

        /*
            Pure computation only.
        */
        return a + b;
    }

    /*
    =====================================================
    STATE-CHANGING FUNCTION
    =====================================================

    WRITES to storage.
    */

    function updateStoredNumber(
        uint256 _num
    )
        external
    {

        /*
            EXPENSIVE STORAGE WRITE.
        */
        storedNumber = _num;
    }

    /*
    =====================================================
    STORAGE-HEAVY FUNCTION
    =====================================================

    Multiple storage writes.
    */

    function storeManyValues()
        external
    {

        /*
            Loop with storage writes.
        */
        for (
            uint256 i = 0;
            i < 10;
            i++
        ) {

            /*
                VERY expensive.
            */
            values.push(i);
        }
    }

    /*
    =====================================================
    VIEW ARRAY LENGTH
    =====================================================

    Cheap storage read.
    */

    function getArrayLength()
        external
        view
        returns (uint256)
    {

        return values.length;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy GasComparison

=========================================================
TRACE:
VIEW FUNCTION
=========================================================

CALL:
readStoredNumber()

=========================================================

STEP 1:
Function executes.

---------------------------------------------------------

Storage value READ only.

---------------------------------------------------------

NO storage modifications.

=========================================================
IMPORTANT
=========================================================

Blockchain state remains unchanged.

---------------------------------------------------------

Gas usage:
VERY LOW

=========================================================
WHY?
=========================================================

Reading storage is much cheaper than writing.

=========================================================
TRACE:
PURE FUNCTION
=========================================================

CALL:
calculateSum(5, 7)

=========================================================

STEP 1:
Computation occurs.

---------------------------------------------------------

5 + 7 = 12

=========================================================
IMPORTANT
=========================================================

NO storage access.

---------------------------------------------------------

NO blockchain modification.

=========================================================
GAS USAGE
=========================================================

EXTREMELY LOW.

=========================================================
TRACE:
STATE-CHANGING FUNCTION
=========================================================

CALL:
updateStoredNumber(100)

=========================================================

STEP 1:
Storage write occurs.

---------------------------------------------------------

storedNumber = 100

=========================================================
IMPORTANT
=========================================================

Permanent blockchain state changes.

=========================================================
GAS USAGE
=========================================================

MUCH HIGHER.

=========================================================
WHY?
=========================================================

Storage writes are expensive.

---------------------------------------------------------

Blockchain state must persist forever.

=========================================================
TRACE:
MULTIPLE STORAGE WRITES
=========================================================

CALL:
storeManyValues()

=========================================================

STEP 1:
Loop begins.

=========================================================
STEP 2
=========================================================

10 storage writes occur:

---------------------------------------------------------

values.push(0)

values.push(1)

...

values.push(9)

=========================================================
IMPORTANT
=========================================================

Gas increases heavily.

---------------------------------------------------------

Every push modifies permanent storage.

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
readStoredNumber()
---------------------------------------------------------

CHEAP

=========================================================

---------------------------------------------------------
calculateSum()
---------------------------------------------------------

VERY CHEAP

=========================================================

---------------------------------------------------------
updateStoredNumber()
---------------------------------------------------------

EXPENSIVE

=========================================================

---------------------------------------------------------
storeManyValues()
---------------------------------------------------------

VERY EXPENSIVE

=========================================================
GAS COMPARISON SUMMARY
=========================================================

---------------------------------------------------------
PURE FUNCTION
---------------------------------------------------------

Lowest gas

---------------------------------------------------------

Reason:
No storage access

=========================================================

---------------------------------------------------------
VIEW FUNCTION
---------------------------------------------------------

Low gas

---------------------------------------------------------

Reason:
Storage reads only

=========================================================

---------------------------------------------------------
STATE-CHANGING FUNCTION
---------------------------------------------------------

Higher gas

---------------------------------------------------------

Reason:
Storage writes

=========================================================

---------------------------------------------------------
MULTIPLE STORAGE WRITES
---------------------------------------------------------

Very high gas

---------------------------------------------------------

Reason:
Repeated permanent storage updates

=========================================================
VERY IMPORTANT UNDERSTANDING
=========================================================

Gas mainly increases because of:

---------------------------------------------------------
STORAGE WRITES
---------------------------------------------------------

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
readStoredNumber()

---------------------------------------------------------

Observe:
very low gas

=========================================================
TEST 2
=========================================================

Call:
calculateSum(5,7)

---------------------------------------------------------

Observe:
extremely low gas

=========================================================
TEST 3
=========================================================

Call:
updateStoredNumber(100)

---------------------------------------------------------

Observe:
higher gas

=========================================================
TEST 4
=========================================================

Call:
storeManyValues()

---------------------------------------------------------

Observe:
much higher gas

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Gas optimization improves:

---------------------------------------------------------
SCALABILITY
---------------------------------------------------------

and

---------------------------------------------------------
USABILITY
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNNECESSARY STORAGE WRITES
---------------------------------------------------------

Wastes gas.

---------------------------------------------------------
2. STORAGE INSIDE LOOPS
---------------------------------------------------------

Massive gas growth.

---------------------------------------------------------
3. EXPENSIVE EXECUTION PATHS
---------------------------------------------------------

Protocol becomes costly.

---------------------------------------------------------
4. GAS DOS
---------------------------------------------------------

Functions exceed gas limits.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers may exploit:

- expensive functions
- gas-heavy loops
- storage growth
- DOS conditions

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Are storage writes necessary?
- Can logic use memory instead?
- Are loops optimized?
- Can gas usage scale dangerously?
- Is state modification minimized?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors profile:

---------------------------------------------------------
GAS COMPLEXITY
---------------------------------------------------------

AND

---------------------------------------------------------
STORAGE EFFICIENCY
---------------------------------------------------------

=========================================================
BEST PRACTICES
=========================================================

- Use view/pure when possible
- Minimize storage writes
- Avoid unnecessary loops
- Use memory for temporary data
- Batch expensive operations carefully

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add 1000 storage writes
2. Compare memory vs storage
3. Optimize loop gas
4. Add mapping writes

BONUS:
Measure gas differences in Remix.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- View functions are cheaper
- Pure functions are cheapest
- Storage writes cost high gas
- Reading storage is cheaper than writing
- Loops increase gas usage
- Storage-heavy logic is expensive
- Gas optimization improves scalability
- Auditors inspect storage efficiency
- Memory is cheaper than storage
- Efficient Solidity design matters heavily

=========================================================
*/


/*

AUDIT REPORT

Title:
Unbounded Storage Growth Through Repeated Array Writes

Severity:
Medium

Category:
Gas Scalability / Denial of Service

Affected Function:
function storeManyValues()

Description:
The function continuously appends values to the
storage array:

values.push(i);

Each execution permanently increases blockchain
storage.

Since there is no cleanup mechanism, maximum size
limit, or access restriction, repeated execution
causes the array to grow indefinitely.

Storage growth increases execution costs and may
eventually create scalability and gas-related
availability issues.

Vulnerable Code:

function storeManyValues()
external
{
for (
uint256 i = 0;
i < 10;
i++
) {

    values.push(i);
}

}

Impact:
Current Impact:
Increased gas consumption
Permanent state growth

Future Impact:
State bloat
Expensive transactions
Reduced scalability
Potential gas-based denial of service

Example:
Initial State:
values.length = 0

Call #1:
storeManyValues()

Result:
values.length = 10

Call #2:
storeManyValues()

Result:
values.length = 20

Call #100:
storeManyValues()

Result:
values.length = 1000
Storage continues growing forever.

Root Cause:
Persistent storage writes occur inside a loop:
values.push(i);
No mechanism exists to limit or clear stored data.

Recommendation:
Avoid storing temporary values permanently.
Use memory arrays whenever persistence is not
required.
If storage is required:
Add size limits
Add cleanup functions
Restrict execution frequency
*/


//Patch Code

contract GasComparisonPatched {

uint256 public storedNumber;

uint256 public valuesLength;

function readStoredNumber()
    external
    view
    returns (uint256)
{
    return storedNumber;
}

function calculateSum(
    uint256 a,
    uint256 b
)
    external
    pure
    returns (uint256)
{
    return a + b;
}

function updateStoredNumber(
    uint256 _num
)
    external
{
    storedNumber = _num;
}

function storeManyValues()
    external
{
    uint256 count = 0;

    for (
        uint256 i = 0;
        i < 10;
        i++
    ) {
        count++;
    }

    valuesLength += count;
}

function getArrayLength()
    external
    view
    returns (uint256)
{
    return valuesLength;
}

}