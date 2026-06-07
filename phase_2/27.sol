// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Create calldata array input
CONCEPT: Efficient external data
=========================================================

OBJECTIVE

- Learn how calldata arrays work
- Understand efficient external data handling
- Learn why calldata is cheaper than memory
- Understand immutable external array behavior

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

calldata arrays:
- hold external input data
- are temporary
- are read-only
- avoid unnecessary memory copying

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Using calldata for external arrays:
saves gas.

Reason:
Data is NOT copied into memory automatically.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Gas optimization is critical in:
- DeFi
- NFT projects
- routers
- batch operations
- governance systems

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Calldata arrays heavily used in:

- batch token transfers
- swap routers
- multicall systems
- governance voting
- staking protocols

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is calldata used instead of memory?
- Are loops bounded safely?
- Can attacker provide huge arrays?
- Is gas exhaustion possible?
- Are inputs validated?

=========================================================
*/

contract CalldataArrayExampleVul {

    /*
        STORAGE ARRAY

        Stored permanently on blockchain.
    */
    uint256[] public storedValues;

    function readArray(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256[] calldata)
    {

        /*
            _numbers exists in calldata.

            No memory copy created.

            Efficient external input handling.
        */
        return _numbers;
    }

    function getArrayLength(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {

        /*
            Reading calldata array length.
        */
        return _numbers.length;
    }

    function calculateSum(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {

        uint256 total = 0;

        /*
            LOOP THROUGH CALLDATA ARRAY

            Efficient because:
            array remains in calldata.
        */
        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }

    function saveValues(
        uint256[] calldata _numbers
    )
        external
    {

        /*
            COPY VALUES FROM CALLDATA
            INTO STORAGE
        */
        for (uint256 i = 0; i < _numbers.length; i++) {

            storedValues.push(_numbers[i]);
        }
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
calculateSum([1,2,3])

EVM ACTIONS:

1. External input encoded into calldata
2. _numbers references calldata directly
3. Loop reads values efficiently
4. No full memory copy created
5. Result returned
6. Calldata discarded after execution

---------------------------------------------------------

RESULT:
6

=========================================================

CALL:
saveValues([10,20,30])

EVM ACTIONS:

1. Array arrives in calldata
2. Values read individually
3. Values copied into storage
4. Blockchain state updated permanently

---------------------------------------------------------

FINAL STORAGE:

[10,20,30]

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
readArray([1,2,3])

EXPECTED:
[1,2,3]

---------------------------------------------------------

STEP 3:
Call:
getArrayLength([10,20,30,40])

EXPECTED:
4

---------------------------------------------------------

STEP 4:
Call:
calculateSum([5,5,5])

EXPECTED:
15

---------------------------------------------------------

STEP 5:
Call:
saveValues([100,200])

---------------------------------------------------------

STEP 6:
Call:
storedValues(0)

EXPECTED:
100

---------------------------------------------------------

STEP 7:
Call:
storedValues(1)

EXPECTED:
200

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Pass empty array

EXPECTED:
Works correctly

---------------------------------------------------------

TEST:
Pass huge array

OBSERVE:
Higher gas consumption

---------------------------------------------------------

TEST:
Pass single-element array

EXPECTED:
Handled correctly

=========================================================
IMPORTANT CALLDATA UNDERSTANDING
=========================================================

THIS PARAMETER:

uint256[] calldata _numbers

---------------------------------------------------------

MEANS:

- external input array
- temporary
- read-only
- efficient

---------------------------------------------------------

NO FULL MEMORY COPY CREATED.

=========================================================
WHY CALLDATA IS CHEAPER
=========================================================

MEMORY ARRAY:
Copies all data into memory.

---------------------------------------------------------

CALLDATA ARRAY:
Reads directly from external input.

---------------------------------------------------------

RESULT:
Lower gas usage.

=========================================================
CALLDATA IMMUTABILITY
=========================================================

CALLDATA ARRAYS ARE READ-ONLY.

---------------------------------------------------------

THIS FAILS:

_numbers[0] = 999;

---------------------------------------------------------

Reason:
calldata cannot be modified.

=========================================================
CALLDATA VS MEMORY ARRAY
=========================================================

---------------------------------------------------------
CALLDATA ARRAY
---------------------------------------------------------

Temporary

Read-only

Cheaper

No automatic copy

---------------------------------------------------------
MEMORY ARRAY
---------------------------------------------------------

Temporary

Mutable

More expensive

Requires copying

=========================================================
GAS OBSERVATION
=========================================================

CALLDATA:
Gas efficient

---------------------------------------------------------

MEMORY:
More expensive due to copying

---------------------------------------------------------

LARGE ARRAYS:
Still expensive because loops consume gas

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. DOS VIA LARGE ARRAYS
---------------------------------------------------------

Huge calldata arrays may:
- consume excessive gas
- exceed block gas limits

---------------------------------------------------------
2. UNBOUNDED LOOPS
---------------------------------------------------------

Loops over attacker-controlled arrays
are dangerous.

---------------------------------------------------------
3. INPUT VALIDATION
---------------------------------------------------------

External calldata is attacker-controlled.

Always validate assumptions.

---------------------------------------------------------
4. GAS OPTIMIZATION
---------------------------------------------------------

Auditors often recommend:
calldata instead of memory
for external read-only arrays.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker submits massive calldata array.

Loop processing becomes expensive.

Possible result:
- DOS condition
- out-of-gas failure

---------------------------------------------------------

REAL-WORLD ISSUE

Improper batch processing has caused:
- uncallable functions
- scalability failures

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Find largest value in calldata array
2. Return maximum number
3. Reject empty arrays

BONUS:
Compare gas:
memory[] vs calldata[] inputs

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Calldata arrays store external input
- Calldata is temporary
- Calldata arrays are read-only
- Calldata avoids memory copying
- Calldata cheaper than memory
- Large arrays still consume gas
- Unbounded loops create DOS risks
- Storage writes are expensive
- External inputs are attacker-controlled
- Auditors inspect calldata efficiency carefully

=========================================================
*/


/*
Audit Report

Title: 
Unbounded Calldata Array Loop Can Cause Gas Exhaustion

Severity: 
Medium

Reason:
The contract uses loops on external calldata arrays without limiting array size. Large arrays may consume too much gas and make functions fail.

Location:
Contract: CalldataArrayExampleVul

Functions:
calculateSum()
saveValues()
Vulnerability Description

The contract accepts external calldata arrays:
uint256[] calldata _numbers
The functions loop through all array elements:
for (uint256 i = 0; i < _numbers.length; i++)
Because users control array size, attackers can send very large arrays.

Large loops increase:
gas usage
execution time
risk of transaction failure
This can create DOS (Denial of Service) conditions.

Impact
Huge arrays may cause:
out-of-gas errors
failed transactions
expensive execution
scalability problems

If similar logic exists in:
DeFi protocols
staking systems
governance voting
batch transfers
important functions may become unusable.

Proof of Concept
Call:
calculateSum([1,2,3])

Result:
6
Now call with a very large array.

OBSERVE:
gas usage increases heavily
execution becomes expensive
transaction may fail
Same issue also exists in:
saveValues()

Root Cause:
The contract uses unbounded loops on attacker-controlled calldata arrays:
for (uint256 i = 0; i < _numbers.length; i++)
No maximum array size validation exists.

Recommendation
Add array size limits before looping.

Example:
require(
    _numbers.length <= 100,
    "Array too large"
);

For very large data, use:
pagination
batch processing
chunked execution

Auditors should inspect:
loop scalability
calldata handling
gas exhaustion risks
attacker-controlled inputs
*/


//Patched Code

contract CalldataArrayExample {

    uint256[] public storedValues;

    function readArray(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256[] calldata)
    {
        return _numbers;
    }

    function getArrayLength(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {
        return _numbers.length;
    }

    /*
        PATCHED FUNCTION
    */
    function calculateSum(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {

        /*
            LIMIT ARRAY SIZE
        */
        require(
            _numbers.length <= 100,
            "Array too large"
        );

        uint256 total = 0;

        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }

    /*
        PATCHED FUNCTION
    */
    function saveValues(
        uint256[] calldata _numbers
    )
        external
    {

        /*
            LIMIT ARRAY SIZE
        */
        require(
            _numbers.length <= 100,
            "Array too large"
        );

        for (uint256 i = 0; i < _numbers.length; i++) {

            storedValues.push(_numbers[i]);
        }
    }
}