// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Modify copied memory array
CONCEPT: Storage unaffected
=========================================================

OBJECTIVE

- Learn how copied memory arrays behave
- Understand storage remains unchanged
- Learn independent copy behavior
- Understand memory isolation from storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

When storage array is copied into memory:

uint256[] memory temp = numbers;

A COMPLETELY SEPARATE copy is created.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

After copying:
- modifying memory affects ONLY memory
- original storage remains unchanged
- memory and storage become independent

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Many Solidity bugs happen because developers:
- expect storage mutation
- but only modify memory copy

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Memory copies useful for:

- temporary calculations
- filtering
- sorting
- safe transformations
- read-only processing

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Did developer intend memory copy?
- Is storage expected to change?
- Are mutations happening safely?
- Can copying large arrays create DOS?
- Is memory/storage confusion present?

=========================================================
*/

contract ModifyCopiedMemoryArrayVul {

    uint256[] public numbers;

    function addValues() public {

        /*
            STORE VALUES PERMANENTLY
            inside storage array
        */
        numbers.push(100);

        numbers.push(200);

        numbers.push(300);
    }

    function modifyMemoryCopy()
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory
        )
    {

        /*
            STORAGE -> MEMORY COPY

            tempArray becomes independent copy.
        */
        uint256[] memory tempArray = numbers;

        /*
            MODIFY MEMORY COPY ONLY
        */
        tempArray[0] = 999;

        /*
            RETURN:
            1. Modified memory copy
            2. Original storage array
        */
        return (tempArray, numbers);
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

[100,200,300]

---------------------------------------------------------

CALL:
modifyMemoryCopy()

EVM ACTIONS:

1. Storage array loaded
2. Full memory copy created
3. tempArray becomes independent
4. tempArray[0] modified
5. Memory copy changes only
6. Original storage untouched

---------------------------------------------------------

MEMORY ARRAY:

[999,200,300]

---------------------------------------------------------

ORIGINAL STORAGE ARRAY:

[100,200,300]

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
[100,200,300]

---------------------------------------------------------

STEP 4:
Call:
modifyMemoryCopy()

EXPECTED RETURN:

Modified Memory:
[999,200,300]

Original Storage:
[100,200,300]

---------------------------------------------------------

STEP 5:
Call:
getStorageArray()

EXPECTED:
[100,200,300]

OBSERVE:
Storage unchanged.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Copy empty storage array

EXPECTED:
Empty arrays returned

---------------------------------------------------------

TEST:
Modify multiple memory indexes

EXPECTED:
Only memory copy changes

---------------------------------------------------------

TEST:
Repeated function calls

OBSERVE:
Fresh memory copy created every execution

=========================================================
IMPORTANT COPY UNDERSTANDING
=========================================================

THIS LINE:

uint256[] memory tempArray = numbers;

---------------------------------------------------------

CREATES:
Independent memory copy.

---------------------------------------------------------

DOES NOT CREATE:
Storage reference.

=========================================================
MEMORY ISOLATION
=========================================================

BEFORE MODIFICATION

Storage:
[100,200,300]

Memory:
[100,200,300]

---------------------------------------------------------

AFTER MEMORY MODIFICATION

Storage:
[100,200,300]

Memory:
[999,200,300]

---------------------------------------------------------

IMPORTANT:
Storage remains unaffected.

=========================================================
MEMORY VS STORAGE REFERENCE
=========================================================

---------------------------------------------------------
MEMORY COPY
---------------------------------------------------------

uint256[] memory temp = numbers;

Independent copy.

---------------------------------------------------------
STORAGE REFERENCE
---------------------------------------------------------

uint256[] storage temp = numbers;

Direct pointer to storage.

Changes affect original array.

=========================================================
GAS OBSERVATION
=========================================================

COPYING ARRAYS:
Consumes gas

---------------------------------------------------------

Reason:
Every storage element copied into memory.

---------------------------------------------------------

VERY LARGE ARRAYS:
May become expensive.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Extremely common Solidity issue.

Developers may expect:
storage updates

but only modify memory copy.

---------------------------------------------------------
2. SILENT LOGIC FAILURES
---------------------------------------------------------

Protocol logic may silently fail
because state never updates.

---------------------------------------------------------
3. DOS RISK
---------------------------------------------------------

Huge arrays copied into memory
may consume excessive gas.

---------------------------------------------------------
4. REFERENCE VALIDATION
---------------------------------------------------------

Auditors carefully inspect:
- copy semantics
- reference behavior
- mutation expectations

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker inflates storage array size.

Function copying arrays:
becomes too expensive.

Result:
DOS via gas exhaustion.

---------------------------------------------------------

ANOTHER RISK

Critical protocol update expected
to modify storage.

Developer accidentally modifies memory copy only.

Security logic silently breaks.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Create STORAGE reference instead
2. Modify referenced array
3. Observe storage changes permanently

BONUS:
Compare:
memory copy vs storage reference behavior

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage-to-memory creates independent copy
- Memory modifications do not affect storage
- Memory arrays are temporary
- Storage persists permanently
- Memory and storage become isolated
- Copying arrays consumes gas
- Large copies may create DOS risks
- Storage references behave differently
- Memory/storage confusion causes bugs
- Auditors inspect reference semantics carefully

=========================================================
*/

/*
Audit Report

Title: 
Memory Copy Modification Does Not Persist to Storage

Severity: 
Medium

Reason: 
Modifying a memory copy does not update persistent blockchain storage, which may cause silent logic failures.

Location:
Contract: ModifyCopiedMemoryArrayVul

Function:
modifyMemoryCopy()

Vulnerability Description:
The contract creates a storage-to-memory copy using:
uint256[] memory tempArray = numbers;
This creates an independent temporary memory array.
The function then modifies the memory copy:
tempArray[0] = 999;
However, this modification affects ONLY memory.
The original storage array:
numbers
remains unchanged permanently.
Developers unfamiliar with Solidity reference semantics may incorrectly assume memory modifications persist to blockchain storage.
This misunderstanding may create silent protocol logic failures.

Impact:
Critical state updates may fail silently if developers mistakenly modify memory instead of storage.
If similar logic existed in:
staking systems
governance voting
reward accounting
NFT ownership tracking
treasury management
then expected protocol state updates may never occur.
This can corrupt business logic and create inconsistent system behavior.

Proof of Concept:
Deploy contract.

Call:
addValues()

Storage array becomes:
[100,200,300]

Call:
modifyMemoryCopy()

Returned values:
Memory copy:
[999,200,300]

Original storage:
[100,200,300]

Call:
getStorageArray()

Result:
[100,200,300]

OBSERVE:
Storage remained unchanged despite memory modification.

Root Cause:
The contract uses a memory copy instead of a storage reference:
uint256[] memory tempArray = numbers;
Memory arrays are temporary and independent from storage.
Modifications to memory variables do not persist after execution completes.

Recommendation:
Use a storage reference when persistent modification is intended.

Example:
uint256[] storage tempArray = numbers;
This creates a direct reference to blockchain storage.
Changes made through the reference persist permanently.

Auditors should carefully inspect:
memory vs storage semantics
unintended temporary modifications
silent state update failures
reference behavior
*/

//Patched Code:

contract ModifyCopiedMemoryArray {

    uint256[] public numbers;

    function addValues() public {

        numbers.push(100);
        numbers.push(200);
        numbers.push(300);
    }

    /*
    =====================================================
    MEMORY COPY
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

        uint256[] memory tempArray = numbers;

        tempArray[0] = 999;

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
        returns (
            uint256[] memory
        )
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

    function getStorageArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }
}