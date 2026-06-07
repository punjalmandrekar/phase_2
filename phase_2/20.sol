// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Copy storage array to memory
CONCEPT: Data copying behavior
=========================================================

OBJECTIVE

- Learn how storage arrays are copied into memory
- Understand copy behavior in Solidity
- Learn difference between storage reference and memory copy
- Understand why memory modifications do NOT affect storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

When storage array is assigned to memory:

uint256[] memory temp = numbers;

A FULL COPY is created.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

After copying:

- temp becomes independent memory array
- original storage remains unchanged
- modifying temp does NOT affect storage

---------------------------------------------------------
STORAGE -> MEMORY COPY
---------------------------------------------------------

STORAGE:
Permanent blockchain data

MEMORY:
Temporary execution copy

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Storage-to-memory copying used in:

- batch processing
- temporary calculations
- sorting
- filtering
- returning data safely

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is copy intentional?
- Is developer expecting reference?
- Are mutations safe?
- Is excessive copying expensive?
- Can large arrays create DOS?

=========================================================
*/

contract StorageToMemoryCopyVul {

    uint256[] public numbers;

    function addValues() public {

        /*
            STORE VALUES IN STORAGE ARRAY
        */
        numbers.push(10);

        numbers.push(20);

        numbers.push(30);
    }

    function copyArrayToMemory()
        public
        view
        returns (uint256[] memory)
    {

        /*
            STORAGE -> MEMORY COPY

            Entire storage array copied
            into temporary memory array.
        */
        uint256[] memory tempArray = numbers;

        /*
            Returning temporary copy
        */
        return tempArray;
    }

    function modifyMemoryCopy()
        public
        view
        returns (uint256[] memory)
    {

        /*
            Create memory copy
        */
        uint256[] memory tempArray = numbers;

        /*
            Modify MEMORY copy only
        */
        tempArray[0] = 999;

        /*
            Original storage remains unchanged
        */
        return tempArray;
    }

    function getStorageArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
addValues()

STORAGE ARRAY:

[10,20,30]

---------------------------------------------------------

CALL:
copyArrayToMemory()

EVM ACTIONS:

1. Storage array loaded
2. Full copy created in memory
3. tempArray becomes independent copy
4. Memory array returned
5. Memory cleared after execution

---------------------------------------------------------

CALL:
modifyMemoryCopy()

MEMORY COPY BEFORE:
[10,20,30]

AFTER MODIFICATION:
[999,20,30]

---------------------------------------------------------

IMPORTANT

ORIGINAL STORAGE STILL:

[10,20,30]

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
addValues()

---------------------------------------------------------

STEP 3:
Call:
getStorageArray()

EXPECTED:
[10,20,30]

---------------------------------------------------------

STEP 4:
Call:
copyArrayToMemory()

EXPECTED:
[10,20,30]

---------------------------------------------------------

STEP 5:
Call:
modifyMemoryCopy()

EXPECTED:
[999,20,30]

---------------------------------------------------------

STEP 6:
Call:
getStorageArray()

EXPECTED:
[10,20,30]

OBSERVE:
Storage unchanged.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Copy empty storage array

EXPECTED:
Returns empty memory array

---------------------------------------------------------

TEST:
Large arrays

OBSERVE:
Higher gas usage due to copying

---------------------------------------------------------

TEST:
Repeated calls

OBSERVE:
Fresh memory copy created each execution

=========================================================
IMPORTANT COPY UNDERSTANDING
=========================================================

THIS LINE:

uint256[] memory tempArray = numbers;

---------------------------------------------------------

DOES:
Create FULL COPY.

---------------------------------------------------------

DOES NOT:
Create storage reference.

=========================================================
MEMORY COPY BEHAVIOR
=========================================================

AFTER COPYING:

Storage Array:
[10,20,30]

Memory Array:
[10,20,30]

---------------------------------------------------------

AFTER MODIFYING MEMORY:

Storage:
[10,20,30]

Memory:
[999,20,30]

---------------------------------------------------------

IMPORTANT

Arrays become independent after copy.

=========================================================
STORAGE VS MEMORY REFERENCE
=========================================================

---------------------------------------------------------
MEMORY COPY
---------------------------------------------------------

uint256[] memory temp = numbers;

Creates independent copy.

---------------------------------------------------------
STORAGE REFERENCE
---------------------------------------------------------

uint256[] storage temp = numbers;

Creates direct pointer/reference.

Changes affect original storage.

=========================================================
GAS OBSERVATION
=========================================================

COPYING LARGE ARRAYS:
Expensive

---------------------------------------------------------

Reason:
Every element copied individually
from storage into memory.

---------------------------------------------------------

VERY LARGE ARRAYS:
May become DOS risk.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug source.

Developers may incorrectly assume:
memory copy affects storage.

---------------------------------------------------------
2. DOS RISK
---------------------------------------------------------

Huge arrays may:
- consume excessive gas
- exceed block gas limits

---------------------------------------------------------
3. COPYING COST
---------------------------------------------------------

Large storage-to-memory copies
can become very expensive.

---------------------------------------------------------
4. REFERENCE ASSUMPTIONS
---------------------------------------------------------

Auditors verify:
whether developer intended:
- copy
OR
- direct storage reference

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker inflates storage array size.

Function copying array:
becomes too expensive.

Result:
Function becomes unusable.

---------------------------------------------------------

REAL-WORLD ISSUE

Large storage copying has caused:
- DOS vulnerabilities
- gas exhaustion
- scalability failures

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Create storage reference variable
2. Modify referenced array
3. Observe storage changes directly

BONUS:
Compare:
memory copy vs storage reference

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage-to-memory creates full copy
- Memory copies are independent
- Memory changes do not affect storage
- Storage references behave differently
- Large array copying increases gas
- Memory cleared after execution
- Storage persists permanently
- Copying dynamic arrays is expensive
- Memory/storage confusion causes bugs
- Auditors inspect copy behavior carefully

=========================================================
*/



/*
Audit Report

Title: 
Unbounded Storage-to-Memory Array Copy Can Cause Gas Exhaustion

Severity: 
Medium

Reason: 
Large storage arrays copied into memory may consume excessive gas and create denial-of-service conditions.

Location:
Contract: `StorageToMemoryCopyVul`

Functions:
  copyArrayToMemory()
  modifyMemoryCopy()

Vulnerability Description:
The contract copies the entire storage array into memory using:
uint256[] memory tempArray = numbers;
This operation creates a full independent memory copy of the storage array.
As the storage array grows larger, copying every element from storage into memory becomes increasingly expensive.

The functions:
copyArrayToMemory()
and
modifyMemoryCopy()
perform unrestricted storage-to-memory copying without validating array size.

An attacker may continuously increase array size through:
addValues()
Eventually, memory allocation and copying costs may become too expensive, causing transaction failures or denial-of-service behavior.

Impact:
Large storage-to-memory copying may:
consume excessive gas
exceed block gas limits
make functions uncallable
reduce protocol scalability

If similar logic existed in:
staking systems
reward distribution
governance voting
NFT enumeration
treasury accounting
then large arrays could permanently break critical functionality.

Proof of Concept:
1. Deploy contract.
2. Repeatedly call:

addValues()
until storage array becomes very large.

3. Call:
copyArrayToMemory()


OBSERVE:
* Gas usage increases significantly
* Execution becomes expensive
* Transaction may eventually fail

Another example:
1. Call:
modifyMemoryCopy()

2. Observe high gas usage caused by:
uint256[] memory tempArray = numbers;

Root Cause:
The contract performs unrestricted full-array copying:
uint256[] memory tempArray = numbers;

Storage arrays persist permanently and may grow indefinitely.
Copying large storage arrays into memory requires allocating memory and copying every element individually.
No array size limitation or pagination mechanism exists.

Recommendation:
Avoid copying unbounded storage arrays into memory.

Use:
* pagination
* bounded loops
* limited-size copying
* direct storage references when appropriate

Validate array size before copying.

Example:
require(numbers.length <= 100, "Array too large");

Auditors should carefully inspect:

* storage-to-memory copies
* unbounded dynamic arrays
* scalability risks
* gas exhaustion vectors
*/

//Patched Code:

contract StorageToMemoryCopy {

    uint256[] public numbers;

    uint256 public constant MAX_COPY_SIZE = 100;

    function addValues() public {

        numbers.push(10);
        numbers.push(20);
        numbers.push(30);
    }

    /*
    =====================================================
    SAFE MEMORY COPY
    =====================================================
    */

    function modifyMemoryCopy()
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory
        )
    {

        require(
            numbers.length <= MAX_COPY_SIZE,
            "Array too large"
        );

        uint256[] memory tempArray = numbers;

        if (tempArray.length > 0) {

            tempArray[0] = 999;
        }

        return (
            tempArray,
            numbers
        );
    }

    /*
    =====================================================
    STORAGE REFERENCE
    =====================================================
    */

    function modifyStorageReference()
        public
        returns (uint256[] memory)
    {

        require(
            numbers.length >= 2,
            "Not enough elements"
        );

        uint256[] storage tempArray = numbers;

        tempArray[0] = 777;
        tempArray[1] = 888;

        return numbers;
    }

    /*
    =====================================================
    PAGINATED STORAGE READ
    =====================================================
    */

    function getStorageArray(
        uint256 start,
        uint256 count
    )
        public
        view
        returns (uint256[] memory)
    {

        require(start < numbers.length, "Invalid start");

        uint256 end = start + count;

        if (end > numbers.length) {

            end = numbers.length;
        }

        uint256 size = end - start;

        require(
            size <= MAX_COPY_SIZE,
            "Page too large"
        );

        uint256[] memory result = new uint256[](size);

        for (uint256 i = 0; i < size; i++) {

            result[i] = numbers[start + i];
        }

        return result;
    }
}