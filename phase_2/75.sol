// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call function with max uint
CONCEPT: Boundary testing (audit-focused)
=========================================================

OBJECTIVE

- Test system behavior at extreme input limits
- Detect overflow assumptions and logic breaks
- Observe gas impact of boundary values
- Simulate real audit-style fuzz inputs

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Max uint256 = extreme boundary condition.

It is used to test:
- arithmetic safety
- comparison logic
- storage correctness
- gas behavior

=========================================================
CONTRACT
=========================================================
*/

contract MaxUintBoundaryTest {

    uint256 public lastValue;
    uint256 public sum;
    uint256 public calls;

    event ValueReceived(uint256 value);

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================
    */

    function set(uint256 value) external {
        lastValue = value;
        sum += value;
        calls++;

        emit ValueReceived(value);
    }

    /*
    =====================================================
    BOUNDARY TEST: MAX UINT
    =====================================================
    */

    // function testMaxUint() external {
    //     uint256 max = type(uint256).max;

    //     set(max);
    // }

    /*
    =====================================================
    STRESS BOUNDARY TEST
    =====================================================
    */

    // function stressMax(uint256 n) external {
    //     uint256 max = type(uint256).max;

    //     for (uint256 i = 0; i < n; i++) {
    //         set(max);
    //     }
    // }

    /*
    =====================================================
    SAFE CHECK VERSION
    =====================================================
    */

    function safeSet(uint256 value) external {
        require(value < type(uint256).max, "Max not allowed");

        lastValue = value;
        sum += value;
        calls++;
    }
}

/*
=========================================================
EXECUTION TRACE
=========================================================

CALL:
testMaxUint()

---------------------------------------------------------

STEP 1:
value = 2^256 - 1

---------------------------------------------------------

STEP 2:
lastValue = max uint256
(sum storage write happens)

---------------------------------------------------------

IMPORTANT:

Solidity 0.8+ prevents overflow automatically.

So:
sum += value is SAFE

BUT gas cost is still high due to large number.

=========================================================
STRESS TEST TRACE
=========================================================

CALL:
stressMax(5)

---------------------------------------------------------

Each iteration:

- set(max)
- storage write
- event emission
- counter increment

---------------------------------------------------------

Total effect:

5 full state updates

=========================================================
IMPORTANT OBSERVATIONS
=========================================================

1. MAX VALUE DOES NOT BREAK ARITHMETIC
---------------------------------------------------------
No overflow occurs.

2. GAS IS STILL CONSUMED NORMALLY
---------------------------------------------------------
Size of number does NOT reduce gas.

3. LOGIC MAY STILL BREAK
---------------------------------------------------------
Example issues:
- comparisons like value < threshold
- incorrect assumptions about range
- UI misinterpretation

=========================================================
REAL AUDITOR INSIGHT
=========================================================

Auditors do NOT just test “normal values”.

They test:

- 0
- 1
- max uint256
- max-1
- random fuzz inputs

Because bugs appear at boundaries.

=========================================================
COMMON VULNERABILITIES FOUND HERE
=========================================================

- incorrect upper-bound checks
- overflow assumptions in legacy logic
- mispriced calculations
- incorrect fee systems
- broken reward distributions

=========================================================
GAS INSIGHT
=========================================================

Max uint does NOT significantly increase gas by itself.

BUT:
- repeated storage writes dominate cost
- loops + max values = worst-case scenario testing

=========================================================
KEY TAKEAWAY
=========================================================

Max uint testing is NOT about breaking arithmetic.

It is about breaking assumptions.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Reject max uint automatically
2. Compare gas:
   - normal value (100)
   - max value
3. Add batch processing for max inputs
4. Simulate fuzz testing (random values)

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- max uint256 = boundary edge case
- Solidity 0.8 prevents overflow automatically
- logic bugs still happen at boundaries
- gas cost is independent of value size
- auditors always test extreme inputs
- stress testing exposes hidden assumptions
- real failures come from logic, not arithmetic

=========================================================
*/


/*
AUDIT REPORT

Title:
Unbounded User-Controlled Loop in stressMax() May Cause Gas-Based Denial of Service

Severity:
Medium

Category:
Denial of Service (DoS) / Gas Scalability

Affected Function:

function stressMax(uint256 n)

Description:
The function accepts a user-controlled parameter:
n
and executes a loop that repeatedly performs:
Storage writes
Event emissions
Arithmetic operations
There is no upper bound on n.
A sufficiently large value can cause the transaction to consume excessive gas and eventually fail.

Vulnerable Code:
function stressMax(
uint256 n
)
external
{
uint256 max =
type(uint256).max;

for (
    uint256 i = 0;
    i < n;
    i++
) {
    set(max);
}

}

Impact:
A malicious or careless user can call:
stressMax(100000)

Result:
Extremely high gas consumption
Transaction reverts
Function becomes unusable
Potential denial-of-service conditions

Proof of Concept:
Call:
stressMax(1000)

Effects:
1000 executions of:
set(max)
Each execution performs:
lastValue update
sum update
calls increment
event emission

Call:
stressMax(100000)

Result:
Likely Out-of-Gas failure.

Root Cause:
Missing validation on:
n
combined with repeated state modifications inside a loop.

Recommendation:
Limit the maximum value of n.
Use batch processing.
Avoid large user-controlled loops.
*/


//Patch Code

contract MaxUintBoundaryTestPatched {

uint256 public lastValue;

uint256 public sum;

uint256 public calls;

uint256 public constant MAX_BATCH = 100;

event ValueReceived(uint256 value);

function set(
    uint256 value
)
    public
{
    lastValue = value;

    sum += value;

    calls++;

    emit ValueReceived(value);
}

function testMaxUint()
    external
{
    uint256 max =
        type(uint256).max;

    set(max);
}

function stressMax(
    uint256 n
)
    external
{
    require(
        n <= MAX_BATCH,
        "Batch too large"
    );

    uint256 max =
        type(uint256).max;

    for (
        uint256 i = 0;
        i < n;
        i++
    ) {
        set(max);
    }
}

function safeSet(
    uint256 value
)
    external
{
    require(
        value < type(uint256).max,
        "Max not allowed"
    );

    lastValue = value;

    sum += value;

    calls++;
}

}