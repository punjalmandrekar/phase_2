// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Return memory variable
CONCEPT: Memory lifecycle
=========================================================

OBJECTIVE

- Learn how memory variables work in Solidity
- Understand memory lifecycle during execution
- Learn how memory variables are returned
- Understand difference between memory and storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory variables:
- are temporary
- exist only during function execution
- disappear after execution finishes

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Memory is used for:
- temporary data
- function arguments
- return values
- dynamic data handling

---------------------------------------------------------
MEMORY VS STORAGE
---------------------------------------------------------

MEMORY:
- temporary
- cheaper than storage
- cleared after execution

STORAGE:
- permanent
- expensive
- persists on blockchain

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Memory commonly used for:

- strings
- arrays
- structs
- temporary calculations
- returned data

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is memory used correctly?
- Is storage accidentally modified?
- Are memory copies intentional?
- Are references handled safely?
- Is unnecessary storage avoided?

=========================================================
*/

contract MemoryLifecycleVul {

    string public storedName = "Blockchain";

    function createMemoryVariable()
        public
        pure
        returns (uint256)
    {

        /*
            MEMORY-LIKE TEMPORARY VARIABLE

            localValue exists only during execution.
        */
        uint256 localValue = 100;

        /*
            Returning temporary variable.

            After function finishes:
            localValue disappears.
        */
        return localValue;
    }

    function returnMemoryString()
        public
        pure
        returns (string memory)
    {

        /*
            MEMORY STRING

            Strings are dynamic types.

            Solidity requires explicit memory keyword.
        */
        string memory tempName = "Solidity";

        /*
            tempName returned from memory.
        */
        return tempName;
    }

    function copyStorageToMemory()
        public
        view
        returns (string memory)
    {

        /*
            STORAGE -> MEMORY COPY

            storedName lives in storage.

            localCopy becomes temporary memory copy.
        */
        string memory localCopy = storedName;

        /*
            Changes to localCopy would NOT
            affect storedName.
        */
        return localCopy;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createMemoryVariable()

EVM ACTIONS:

1. Function execution starts
2. localValue created temporarily
3. localValue stored in stack/memory
4. Value returned
5. localValue destroyed after execution

---------------------------------------------------------

IMPORTANT:
Nothing stored permanently.

---------------------------------------------------------

CALL:
returnMemoryString()

EVM ACTIONS:

1. tempName allocated in memory
2. String stored temporarily
3. Memory data returned
4. Memory cleared after execution

---------------------------------------------------------

CALL:
copyStorageToMemory()

EVM ACTIONS:

1. Read storedName from storage
2. Create temporary memory copy
3. Return memory copy
4. Memory destroyed after execution

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createMemoryVariable()

EXPECTED:
100

---------------------------------------------------------

STEP 3:
Call:
returnMemoryString()

EXPECTED:
"Solidity"

---------------------------------------------------------

STEP 4:
Call:
copyStorageToMemory()

EXPECTED:
"Blockchain"

---------------------------------------------------------

STEP 5:
Check:
storedName()

EXPECTED:
"Blockchain"

OBSERVE:
Storage unchanged.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Repeated function calls

EXPECTED:
Memory recreated every execution

---------------------------------------------------------

TEST:
Return empty string

Modify code:
string memory tempName = "";

EXPECTED:
Returns empty string successfully

---------------------------------------------------------

TEST:
Large strings

OBSERVE:
More memory allocation
= higher gas usage

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

MEMORY LIFECYCLE

1. Memory allocated during execution
2. Temporary data stored
3. Function returns data
4. Memory cleared after execution

---------------------------------------------------------

VERY IMPORTANT

Memory does NOT persist on blockchain.

---------------------------------------------------------

THIS IS TEMPORARY:

string memory tempName;

---------------------------------------------------------

THIS IS PERSISTENT:

string public storedName;

=========================================================
MEMORY COPY BEHAVIOR
=========================================================

EXAMPLE:

string memory localCopy = storedName;

---------------------------------------------------------

WHAT HAPPENS?

1. storedName read from storage
2. Data copied into memory
3. localCopy becomes independent copy

---------------------------------------------------------

IMPORTANT

Changing localCopy does NOT modify storage.

=========================================================
GAS OBSERVATION
=========================================================

MEMORY:
Cheaper than storage

---------------------------------------------------------

STORAGE:
Expensive because blockchain state changes

---------------------------------------------------------

Returning memory data still consumes:
- execution gas
- memory expansion cost

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug source.

Developers may think:
memory changes affect storage.

They do NOT.

---------------------------------------------------------
2. ACCIDENTAL STORAGE COPIES
---------------------------------------------------------

Auditors inspect:
- reference behavior
- unintended mutations
- data copying logic

---------------------------------------------------------
3. LARGE MEMORY ALLOCATION
---------------------------------------------------------

Huge arrays/strings may:
- consume excessive gas
- create DOS vectors

---------------------------------------------------------
4. RETURN DATA RISKS
---------------------------------------------------------

Returning excessive data may:
- exceed gas limits
- increase execution costs

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker provides huge input arrays/strings.

Result:
- excessive memory allocation
- increased gas consumption
- possible DOS behavior

---------------------------------------------------------

ANOTHER RISK

Developer expects memory update
to persist permanently.

Logic silently fails.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Create memory array
2. Store values inside it
3. Return array from function

BONUS:
Compare memory array vs storage array.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory variables are temporary
- Memory cleared after execution
- Storage persists permanently
- Dynamic types commonly use memory
- Returning memory data is common
- Storage-to-memory creates copy
- Memory updates do not affect storage
- Memory cheaper than storage
- Large memory usage increases gas
- Auditors inspect memory behavior carefully

=========================================================
*/




/*
Audit Report

Title: 
Memory and Storage Confusion Leading to Incorrect State Assumptions

Severity: 
Medium

Reason: 
Developers may incorrectly assume memory updates persist permanently on blockchain storage.

Location:
Contract: MemoryLifecycleVul

Functions:
returnMemoryString()
copyStorageToMemory()

Vulnerability Description:
The contract demonstrates use of temporary memory variables:
string memory tempName = "Solidity";
and
string memory localCopy = storedName;
Memory variables exist only during function execution.

After execution completes:
memory is cleared
temporary data disappears
changes do not persist on blockchain storage
Developers unfamiliar with Solidity memory behavior may incorrectly assume memory updates permanently modify blockchain state.
This misunderstanding can create protocol logic failures and incorrect state assumptions.

Impact:
Incorrect memory/storage assumptions may cause:
failed state persistence
broken protocol logic
incorrect accounting
inconsistent application behavior

If developers expect memory updates to persist for:
balances
rewards
governance settings
ownership records
then critical protocol logic may silently fail.
Large memory allocations may also increase gas consumption and create denial-of-service risks.

Proof of Concept:
Deploy contract.

Call:
copyStorageToMemory()

Result:
"Blockchain"

Observe:
storedName() still returns:
"Blockchain"
Storage remains unchanged because only a temporary memory copy was used.

Another example:
Call:
returnMemoryString()

Result:
"Solidity"
Function execution ends.

Observe:
No blockchain storage was modified.
Memory data existed only temporarily during execution.

Root Cause:
The contract uses temporary memory variables:
string memory tempName = "Solidity";
and
string memory localCopy = storedName;
Memory variables create temporary copies instead of persistent storage references.
Any modifications to memory variables disappear after function execution completes.

Recommendation:
Use storage variables when persistent blockchain state updates are required.

Example:
storedName = "UpdatedName";

Use memory only for:
temporary calculations
return values
temporary copies
execution-time data handling

Developers should clearly distinguish between:

memory → temporary data
storage → persistent blockchain state

Auditors should carefully inspect memory/storage behavior to prevent silent logic failures.
*/

//Patched Code:

contract MemoryLifecycle {

    string public storedName = "Blockchain";

    // permanent storage array
    uint256[] public storedNumbers;

    constructor() {

        storedNumbers.push(1);
        storedNumbers.push(2);
        storedNumbers.push(3);
    }

    /*
    =====================================================
    SIMPLE MEMORY VARIABLE
    =====================================================
    */

    function createMemoryVariable()
        public
        pure
        returns (uint256)
    {

        uint256 localValue = 100;

        return localValue;
    }

    /*
    =====================================================
    MEMORY STRING
    =====================================================
    */

    function returnMemoryString()
        public
        pure
        returns (string memory)
    {

        string memory tempName = "Solidity";

        return tempName;
    }

    /*
    =====================================================
    STORAGE TO MEMORY COPY
    =====================================================
    */

    function copyStorageToMemory()
        public
        view
        returns (string memory)
    {

        string memory localCopy = storedName;

        return localCopy;
    }

    /*
    =====================================================
    MEMORY ARRAY
    =====================================================
    */

    function createMemoryArray()
        public
        pure
        returns (uint256[] memory)
    {

        uint256[] memory tempArray = new uint256[](3);

        tempArray[0] = 10;
        tempArray[1] = 20;
        tempArray[2] = 30;

        return tempArray;
    }

    /*
    =====================================================
    STORAGE ARRAY
    =====================================================
    */

    function getStoredNumbers()
        public
        view
        returns (uint256[] memory)
    {

        return storedNumbers;
    }
}