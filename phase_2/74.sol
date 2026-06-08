// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call function with zero values
CONCEPT: Edge-case behavior
=========================================================

OBJECTIVE

- Understand how contracts behave with zero inputs
- Learn why edge cases matter in auditing
- Observe storage + logic behavior with 0
- Think like auditor checking boundary conditions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Zero is NOT "nothing" in Solidity.

---------------------------------------------------------

0 is a valid input and can still:

- change state
- trigger logic
- affect storage
- break assumptions

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Many bugs happen because developers assume:

"value > 0 always"

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Zero-value edge cases can cause:

- logic bypass
- division errors
- unnecessary state changes
- incorrect accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- zero input handling
- boundary conditions
- default values
- uninitialized logic
- false assumptions

=========================================================
ZERO VALUE CONTRACT
=========================================================
*/

contract ZeroValueEdgeCase {

    /*
        STORAGE VARIABLES
    */
    uint256 public total;
    uint256 public lastInput;
    uint256 public counter;

    /*
        STORAGE ARRAY
    */
    uint256[] public values;

    /*
    =====================================================
    FUNCTION: ADD VALUE (INCLUDING ZERO)
    =====================================================
    */

    function addValue(uint256 value)
        external
    {

        /*
        =================================================
        EDGE CASE: ZERO INPUT
        =================================================
        */

        lastInput = value;

        /*
            Even if value = 0,
            state is still updated.
        */

        total += value;

        /*
            Storage write ALWAYS happens.
        */
        values.push(value);

        /*
            Counter always increases,
            even for zero.
        */
        counter++;
    }

    /*
    =====================================================
    SAFE VERSION (ZERO CHECK)
    =====================================================
    */

    function addValueSafe(uint256 value)
        external
    {

        /*
            Ignore zero values.
        */
        require(value > 0, "Zero not allowed");

        lastInput = value;
        total += value;
        values.push(value);
        counter++;
    }

    /*
    =====================================================
    ZERO TEST FUNCTION
    =====================================================
    */

    function testZero()
        external
    {

        /*
            Explicit zero input calls.
        */
        // addValue(0);
        // addValue(0);
        // addValue(0);
    }

    /*
    =====================================================
    GET ARRAY LENGTH
    =====================================================
    */

    function getLength()
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
Deploy ZeroValueEdgeCase

=========================================================
TRACE:
addValue(0)
=========================================================

STEP 1:
value = 0

---------------------------------------------------------

lastInput = 0

=========================================================
STEP 2
=========================================================

total += 0

---------------------------------------------------------

NO change in total

=========================================================
STEP 3
=========================================================

values.push(0)

---------------------------------------------------------

IMPORTANT:
ZERO is still stored in blockchain.

=========================================================
STEP 4
=========================================================

counter++

---------------------------------------------------------

counter increases even for zero input.

=========================================================
FINAL STATE AFTER 3 CALLS
=========================================================

CALL:
testZero()

---------------------------------------------------------
counter
---------------------------------------------------------

= 3

---------------------------------------------------------
values
---------------------------------------------------------

[0, 0, 0]

---------------------------------------------------------
total
---------------------------------------------------------

= 0

---------------------------------------------------------
lastInput
---------------------------------------------------------

= 0

=========================================================
IMPORTANT OBSERVATION
=========================================================

Zero STILL causes:

- storage writes
- gas consumption
- state updates

=========================================================
SAFE VERSION BEHAVIOR
=========================================================

CALL:
addValueSafe(0)

=========================================================

STEP 1:
require(value > 0)

---------------------------------------------------------

value = 0 → REVERT

=========================================================
RESULT
=========================================================

Transaction fails BEFORE state change.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Zero values are:

---------------------------------------------------------
VALID INPUTS
---------------------------------------------------------

BUT often:

---------------------------------------------------------
LOGICALLY IGNORED BY SYSTEMS
---------------------------------------------------------

=========================================================
COMMON BUGS FROM ZERO VALUES
=========================================================

---------------------------------------------------------
1. DIVISION BY ZERO
---------------------------------------------------------

if (a / value)

---------------------------------------------------------

---------------------------------------------------------
2. LOGIC BYPASS
---------------------------------------------------------

if (value > 0) { ... }

---------------------------------------------------------

---------------------------------------------------------
3. UNEXPECTED STORAGE WRITE
---------------------------------------------------------

storing useless zero values

---------------------------------------------------------

---------------------------------------------------------
4. INCORRECT ACCOUNTING
---------------------------------------------------------

totals not updated correctly

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- send zero values repeatedly
- bloat storage arrays
- trigger unnecessary gas costs
- exploit missing zero checks

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- is zero handled?
- does zero cause state change?
- can zero break logic?
- is validation missing?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors test:

---------------------------------------------------------
BOUNDARY INPUTS:
0, 1, max uint256
---------------------------------------------------------

=========================================================
BEST PRACTICES
=========================================================

- Validate inputs when needed
- Handle zero explicitly
- Avoid storing useless values
- Document zero behavior
- Test boundary conditions

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Reject zero and negative-like edge cases
2. Compare gas usage with/without zero validation
3. Add event logging instead of storage push
4. Handle max uint256 input safely

BONUS:
Create full edge-case testing suite.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Zero is a valid Solidity value
- Zero still consumes gas if stored
- State updates happen even for zero
- Edge cases cause real vulnerabilities
- Input validation is critical
- Auditors test boundary conditions
- Storage grows even with useless values
- Safe design avoids unnecessary writes
- Zero can break assumptions
- Robust contracts handle all inputs

=========================================================
*/

/*
AUDIT REPORT

Title:
Missing Zero-Value Validation Allows Unnecessary State Changes and Storage Bloat

Severity:
Low

Category:
Input Validation / Storage Inefficiency

Affected Function:
function addValue(uint256 value)

Description:
The function accepts zero as a valid input.
When value equals zero:
lastInput is updated
values array grows
counter increases
gas is consumed
Even though total remains unchanged.
This allows users to create unnecessary storage growth and state changes.

Vulnerable Code:

function addValue(uint256 value)
external
{
lastInput = value;

total += value;

values.push(value);

counter++;

}

Impactz:
A malicious user can repeatedly call:
addValue(0)

Result:
values array filled with useless entries
storage grows unnecessarily
gas costs increase over time
contract state becomes bloated

Proof of Concept:
Call:
addValue(0)

State:
total = 0
counter = 1
values = [0]

Repeat:
addValue(0)
1000 times

Result:
counter = 1000
values.length = 1000
total = 0
Large storage growth without meaningful value.

Root Cause:
Missing validation for:
value == 0
The function performs storage writes regardless of whether the input contributes meaningful data.

Recommendation:
Reject zero-value inputs.
Only allow values greater than zero.
*/



//Patch Code

contract ZeroValueEdgeCasePatched {

uint256 public total;

uint256 public lastInput;

uint256 public counter;

uint256[] public values;

function addValue(
    uint256 value
)
    external
{
    require(
        value > 0,
        "Zero value not allowed"
    );

    lastInput = value;

    total += value;

    values.push(value);

    counter++;
}

function getLength()
    external
    view
    returns (uint256)
{
    return values.length;
}

}