// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Return large memory array
CONCEPT: Memory allocation
=========================================================

OBJECTIVE

- Learn how large memory arrays are allocated
- Understand memory expansion costs
- Learn how returning large arrays affects gas
- Understand scalability risks in Solidity

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory arrays are allocated dynamically
during execution.

Larger arrays:
- require more memory
- consume more gas
- increase execution cost

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Returning large arrays can become expensive.

Reason:
EVM must:
- allocate memory
- store elements
- encode return data

---------------------------------------------------------
REAL-WORLD IMPORTANCE
---------------------------------------------------------

Large memory operations affect:

- scalability
- gas efficiency
- DOS resistance
- protocol usability

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Large arrays appear in:

- DeFi protocols
- NFT collections
- staking systems
- governance snapshots
- batch operations

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can arrays grow unbounded?
- Can functions become uncallable?
- Is gas exhaustion possible?
- Are loops scalable?
- Is pagination needed?

=========================================================
*/

contract LargeMemoryArrayVul {

    /*
        STORAGE ARRAY

        Persists permanently.
    */
    uint256[] public storedValues;

    function addValues(uint256 _count) public {

        /*
            Add values into storage array.

            WARNING:
            Large loops increase gas usage.
        */
        for (uint256 i = 0; i < _count; i++) {

            storedValues.push(i);
        }
    }

    function returnLargeArray(uint256 _size)
        public
        pure
        returns (uint256[] memory)
    {

        /*
            CREATE LARGE MEMORY ARRAY

            Memory allocated dynamically.
        */
        uint256[] memory tempArray =
            new uint256[](_size);

        /*
            Fill memory array
        */
        for (uint256 i = 0; i < _size; i++) {

            tempArray[i] = i + 1;
        }

        /*
            Entire array returned.

            Larger arrays:
            higher gas cost.
        */
        return tempArray;
    }

    function copyStorageToMemory()
        public
        view
        returns (uint256[] memory)
    {

        /*
            FULL STORAGE -> MEMORY COPY

            Dangerous if storage array becomes huge.
        */
        return storedValues;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
returnLargeArray(5)

EVM ACTIONS:

1. Allocate memory for 5 elements
2. Create temporary array
3. Fill array using loop
4. Encode return data
5. Return memory array
6. Memory cleared after execution

---------------------------------------------------------

RETURNED ARRAY:

[1,2,3,4,5]

=========================================================

CALL:
returnLargeArray(1000)

OBSERVE:

- more memory allocation
- more loop iterations
- higher gas consumption
- larger return data

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
returnLargeArray(5)

EXPECTED:
[1,2,3,4,5]

---------------------------------------------------------

STEP 3:
Call:
returnLargeArray(50)

OBSERVE:
Higher execution cost

---------------------------------------------------------

STEP 4:
Call:
returnLargeArray(500)

OBSERVE:
Even higher gas usage

---------------------------------------------------------

STEP 5:
Call:
addValues(20)

---------------------------------------------------------

STEP 6:
Call:
copyStorageToMemory()

EXPECTED:
Returns all stored values

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
_size = 0

EXPECTED:
Empty array returned

---------------------------------------------------------

TEST:
Very large _size

OBSERVE:
Possible:
- high gas cost
- out-of-gas errors

---------------------------------------------------------

TEST:
Huge storage array copy

OBSERVE:
Function may become expensive/unusable

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS LINE:

new uint256[](_size)

---------------------------------------------------------

ALLOCATES:
dynamic memory space.

---------------------------------------------------------

LARGER ARRAYS:
require more EVM memory expansion.

---------------------------------------------------------

VERY IMPORTANT

Memory is temporary:
cleared after execution.

=========================================================
MEMORY EXPANSION COST
=========================================================

EVM charges gas for:
- allocating memory
- expanding memory
- writing values
- encoding return data

---------------------------------------------------------

LARGE ARRAYS:
grow gas costs rapidly.

=========================================================
RETURN DATA COST
=========================================================

Returning large arrays also costs gas.

Reason:
EVM must ABI-encode:
every array element.

=========================================================
SCALABILITY RISK
=========================================================

UNBOUNDED ARRAYS ARE DANGEROUS.

Functions may become:
- too expensive
- uncallable
- DOS vulnerable

=========================================================
GAS OBSERVATION
=========================================================

SMALL ARRAY:
Cheap

---------------------------------------------------------

LARGE ARRAY:
Expensive

---------------------------------------------------------

VERY LARGE ARRAY:
Possible out-of-gas failure

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. DOS VIA GAS EXHAUSTION
---------------------------------------------------------

Huge arrays may:
- exceed block gas limit
- make function unusable

---------------------------------------------------------
2. UNBOUNDED LOOPS
---------------------------------------------------------

Loops over attacker-controlled size
are dangerous.

---------------------------------------------------------
3. STORAGE-TO-MEMORY COPYING
---------------------------------------------------------

Copying massive storage arrays
can break scalability.

---------------------------------------------------------
4. PAGINATION REQUIREMENT
---------------------------------------------------------

Auditors often recommend:
pagination instead of returning everything.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker grows storage array massively.

Then calls:
copyStorageToMemory()

Result:
- excessive gas usage
- DOS condition
- function unusable

---------------------------------------------------------

REAL-WORLD ISSUE

Many protocols became uncallable
because arrays grew too large.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add pagination support
2. Return only partial array range
3. Avoid returning entire huge array

BONUS:
Implement:
(start, limit) logic

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory arrays allocate temporary memory
- Large arrays increase gas consumption
- Memory expansion costs gas
- Returning arrays requires ABI encoding
- Large return data becomes expensive
- Unbounded loops create scalability risks
- Storage-to-memory copying can be dangerous
- DOS via gas exhaustion is common
- Pagination improves scalability
- Auditors inspect array growth carefully

=========================================================
*/


/*
Audit Report

Title:
Large Memory Array May Cause Gas Exhaustion

Severity:
Medium

Reason:
Returning very large memory arrays can consume excessive gas and may make functions fail or become unusable.

Location:
Contract: LargeMemoryArray

Functions:
returnLargeArray()
copyStorageToMemory()
addValues()

Vulnerability Description:
The contract creates large memory arrays using:
new uint256[](_size)

It also copies the full storage array into memory:
return storedValues;

If very large arrays are used:
more memory is allocated
loops consume more gas
return data becomes expensive
transactions may fail
The contract has no limit on array size.

Impact:
Large arrays may lead to:
out-of-gas errors
failed transactions
denial-of-service (DOS)
unusable functions

If similar logic exists in:
staking systems
NFT collections
governance systems
DeFi protocols
then large array growth may break protocol scalability.

Proof of Concept:
Call:
returnLargeArray(10000)

Observe:
very high gas usage
possible transaction failure

Another example:
Call:
addValues(5000)

Then call:
copyStorageToMemory()

Observe:
Large storage array copy becomes expensive.

Root Cause:
The contract allows unbounded array allocation and copying:
new uint256[](_size)
and
return storedValues;
Large memory operations increase gas cost rapidly.

Recommendation:
Use pagination and limit array size.
Avoid returning entire large arrays at once.

Example:
require(_size <= 100, "Array too large");
Use (start, limit) pagination logic for large storage arrays.

Auditors should inspect:
unbounded loops
large memory allocations
storage-to-memory copying
DOS via gas exhaustion
*/

//Patched Code:

contract LargeMemoryArray {

    /*
        STORAGE ARRAY
    */
    uint256[] public storedValues;

    /*
        LIMIT STORAGE GROWTH
    */
    function addValues(uint256 _count) public {

        require(_count <= 100, "Too many values");

        for (uint256 i = 0; i < _count; i++) {

            storedValues.push(i);
        }
    }

    /*
        LIMITED MEMORY ARRAY
    */
    function returnLargeArray(uint256 _size)
        public
        pure
        returns (uint256[] memory)
    {

        require(_size <= 100, "Array too large");

        uint256[] memory tempArray =
            new uint256[](_size);

        for (uint256 i = 0; i < _size; i++) {

            tempArray[i] = i + 1;
        }

        return tempArray;
    }

    /*
        PAGINATED STORAGE COPY
    */
    function copyStorageToMemory(
        uint256 start,
        uint256 limit
    )
        public
        view
        returns (uint256[] memory)
    {

        require(start < storedValues.length, "Invalid start");

        uint256 end = start + limit;

        if (end > storedValues.length) {

            end = storedValues.length;
        }

        uint256[] memory tempArray =
            new uint256[](end - start);

        uint256 index = 0;

        for (uint256 i = start; i < end; i++) {

            tempArray[index] = storedValues[i];

            index++;
        }

        return tempArray;
    }
}


