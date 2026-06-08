// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Stress test repeated calls
CONCEPT: Stability testing
=========================================================

OBJECTIVE

- Understand system behavior under repeated calls
- Learn how state grows over time
- Observe gas accumulation risks
- Think like auditor performing stress tests

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Repeated function calls simulate real-world load.

---------------------------------------------------------

Each call:
modifies state
consumes gas
adds cumulative load

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Stress testing is used to detect:

- gas exhaustion
- storage bloating
- performance degradation
- DOS risks

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

In real systems:

- users call contracts repeatedly
- bots interact heavily
- protocols accumulate state over time

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors test:

- repeated execution stability
- state growth over time
- gas scaling behavior
- worst-case repeated usage
- storage accumulation

=========================================================
STRESS TEST CONTRACT
=========================================================
*/

contract StressTestCalls {

    /*
        STORAGE STATE
    */
    uint256 public counter;

    uint256 public totalCalls;

    uint256[] public history;

    /*
    =====================================================
    SINGLE STATE UPDATE FUNCTION
    =====================================================
    */

    function singleCall(uint256 value)
        public
    {

        /*
            Increment counters.
        */
        counter++;
        totalCalls++;

        /*
            Store value.
        */
        history.push(value);
    }

    /*
    =====================================================
    STRESS TEST FUNCTION (LOOPED CALLS)
    =====================================================
    */

    function stressTest(uint256 times)
        external
    {

        /*
        =================================================
        WARNING:
        =================================================

        This simulates repeated usage.

        Gas grows linearly with `times`.
        */

        for (
            uint256 i = 0;
            i < times;
            i++
        ) {

            /*
                Repeated internal execution.
            */
            singleCall(i);
        }
    }

    /*
    =====================================================
    DIRECT CALL STRESS (EXTERNAL STYLE SIMULATION)
    =====================================================
    */

    function externalStyleStress(uint256 times)
        external
    {

        for (
            uint256 i = 0;
            i < times;
            i++
        ) {

            /*
                Simulates repeated user interactions.
            */
            this.singleCall(i);
        }
    }

    /*
    =====================================================
    RESET STATE (FOR TESTING ONLY)
    =====================================================
    */

    function reset()
        external
    {

        counter = 0;
        totalCalls = 0;

        delete history;
    }

    /*
    =====================================================
    GET HISTORY SIZE
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
Deploy StressTestCalls

=========================================================
TRACE:
stressTest(5)
=========================================================

STEP 1:
i = 0

---------------------------------------------------------

singleCall(0)

=========================================================
STEP 2
=========================================================

STATE CHANGES:

counter++
totalCalls++
history.push(0)

=========================================================
STEP 3
=========================================================

i = 1 → repeat

=========================================================
STEP 4
=========================================================

i = 2 → repeat

=========================================================
STEP 5
=========================================================

i = 3 → repeat

=========================================================
STEP 6
=========================================================

i = 4 → repeat

=========================================================
FINAL STATE
=========================================================

---------------------------------------------------------
counter
---------------------------------------------------------

= 5

---------------------------------------------------------
totalCalls
---------------------------------------------------------

= 5

---------------------------------------------------------
history
---------------------------------------------------------

[0,1,2,3,4]

=========================================================
IMPORTANT OBSERVATION
=========================================================

Each loop iteration:

---------------------------------------------------------
1 storage increment
1 storage increment
1 array push
---------------------------------------------------------

Gas grows quickly.

=========================================================
TRACE:
externalStyleStress()
=========================================================

STEP 1:
this.singleCall(i)

---------------------------------------------------------

IMPORTANT:

This creates EXTERNAL CALLS to same contract.

=========================================================
STEP 2
=========================================================

Execution context switches:

Contract → Contract (external call)

=========================================================
STEP 3
=========================================================

Each iteration:

- external call overhead
- higher gas usage
- more execution cost

=========================================================
IMPORTANT DIFFERENCE
=========================================================

---------------------------------------------------------
singleCall()
---------------------------------------------------------

cheap internal call

---------------------------------------------------------

---------------------------------------------------------
this.singleCall()
---------------------------------------------------------

expensive external call

=========================================================
STRESS TEST INSIGHT
=========================================================

Repeated calls reveal:

- gas scaling issues
- storage growth
- execution bottlenecks
- stability limits

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
stressTest(10)

EXPECTED:
fast execution

=========================================================
STEP 2
=========================================================

Call:
stressTest(1000)

EXPECTED:
high gas usage / possible failure

=========================================================
TEST 3
=========================================================

Call:
externalStyleStress(10)

EXPECTED:
higher gas than internal version

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Repeated calls can cause:

---------------------------------------------------------
GAS DOS
---------------------------------------------------------

AND

---------------------------------------------------------
STORAGE BLOAT
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNBOUNDED REPEATED CALLS
---------------------------------------------------------

can exhaust gas

---------------------------------------------------------
2. STORAGE GROWTH
---------------------------------------------------------

array keeps increasing

---------------------------------------------------------
3. EXTERNAL CALL OVERHEAD
---------------------------------------------------------

increases gas significantly

---------------------------------------------------------
4. SYSTEM INSTABILITY
---------------------------------------------------------

becomes unscalable under load

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- spam function calls
- increase gas usage
- force storage growth
- degrade protocol performance

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors test:

- repeated call behavior
- worst-case gas usage
- storage scaling
- external call risks
- system stability under load

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors simulate:

---------------------------------------------------------
HIGH-FREQUENCY USAGE
---------------------------------------------------------

to find failure points.

=========================================================
BEST PRACTICES
=========================================================

- Avoid unbounded loops
- Minimize storage writes per call
- Prefer batch processing
- Avoid unnecessary external calls
- Design for scalability

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Limit stressTest to 100 calls
2. Replace storage writes with events
3. Compare internal vs external call gas
4. Add gas measurement logging

BONUS:
Create batch-stress-safe architecture.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Repeated calls simulate real load
- Gas grows with execution frequency
- Storage accumulates over time
- External calls are more expensive
- Stress testing reveals vulnerabilities
- System scalability must be designed
- Auditors simulate heavy usage scenarios
- Unbounded execution is dangerous
- Storage + loops = high risk pattern
- Stability testing is critical for security

=========================================================
*/


/*
AUDIT REPORT

Title:
Unbounded User-Controlled Loop Leading to Gas-Based Denial of Service

Severity:
Medium

Category:
Denial of Service (DoS) / Gas Scalability

Affected Functions:
stressTest(uint256 times)
externalStyleStress(uint256 times)

Description:
Both functions allow users to supply an arbitrary value for:
times
The value directly controls loop execution.
As times increases, gas consumption grows linearly.
A sufficiently large value can cause transaction failure due to out-of-gas conditions.

Vulnerable Code:

function stressTest(uint256 times)
external
{
for (
uint256 i = 0;
i < times;
i++
) {
singleCall(i);
}
}

function externalStyleStress(
uint256 times
)
external
{
for (
uint256 i = 0;
i < times;
i++
) {
this.singleCall(i);
}
}

Impact

An attacker can supply very large values:

stressTest(100000)

or

externalStyleStress(100000)

Result:

Extremely high gas usage
Transaction failure
Denial of service
Poor scalability

Additional Risk

Each iteration performs:

counter++
totalCalls++
history.push(value)

This creates continuous storage growth.

Storage expands forever.

Proof of Concept

Call:

stressTest(1000)

Result:

counter = 1000
totalCalls = 1000
history.length = 1000

Call:
stressTest(100000)

Result:
Likely Out-of-Gas revert.

Root Cause:
User-controlled loop size:
times
combined with:
history.push(value)
inside every iteration.

Recommendation:
Enforce a maximum batch size.
Prevent excessively large loop execution.
Consider event-based tracking instead of permanent storage growth.
*/


//Patch Code

contract StressTestCallsPatched {

uint256 public counter;

uint256 public totalCalls;

uint256[] public history;

uint256 public constant MAX_BATCH = 100;

function singleCall(
    uint256 value
)
    internal
{
    counter++;
    totalCalls++;

    history.push(value);
}

function stressTest(
    uint256 times
)
    external
{
    require(
        times <= MAX_BATCH,
        "Batch too large"
    );

    for (
        uint256 i = 0;
        i < times;
        i++
    ) {
        singleCall(i);
    }
}

function reset()
    external
{
    counter = 0;
    totalCalls = 0;

    delete history;
}

function getHistoryLength()
    external
    view
    returns (uint256)
{
    return history.length;
}

}