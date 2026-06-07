// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Compare storage vs memory updates
CONCEPT: Reference behavior
=========================================================

OBJECTIVE

- Learn difference between storage and memory updates
- Understand reference vs copy behavior
- Learn why storage changes persist
- Understand why memory changes disappear

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

STORAGE:
Creates direct reference to blockchain state.

MEMORY:
Creates temporary independent copy.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

STORAGE UPDATE:
Changes original blockchain data.

MEMORY UPDATE:
Changes temporary copy only.

---------------------------------------------------------
VERY IMPORTANT
---------------------------------------------------------

This is one of the MOST IMPORTANT
concepts in Solidity security.

Many real-world bugs happen because:
developers confuse memory and storage.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Understanding reference behavior is critical for:

- DeFi protocols
- token accounting
- staking systems
- governance logic
- NFT marketplaces
- upgradeable contracts

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is storage reference intentional?
- Is memory copy expected?
- Are mutations happening correctly?
- Can accidental state mutation occur?
- Is protocol logic silently failing?

=========================================================
*/

contract StorageVsMemoryVul {

    /*
        STRUCT STORED ON BLOCKCHAIN
    */
    struct User {

        uint256 score;

        bool active;
    }

    /*
        STORAGE MAPPING

        Persistent blockchain storage
    */
    mapping(address => User) public users;

    function createUser() public {

        users[msg.sender] = User({

            score: 100,

            active: true
        });
    }

    function updateUsingStorage() public {

        /*
            STORAGE REFERENCE

            user directly points to:
            users[msg.sender]
        */
        User storage user = users[msg.sender];

        /*
            MODIFY STORAGE DIRECTLY

            Changes persist permanently.
        */
        user.score = 999;
    }

    function updateUsingMemory() public view returns (
        uint256,
        bool
    ) {

        /*
            MEMORY COPY

            Creates independent temporary copy.
        */
        User memory user = users[msg.sender];

        /*
            MODIFY MEMORY COPY ONLY

            Original storage remains unchanged.
        */
        user.score = 555;

        user.active = false;

        /*
            Returning modified MEMORY values
        */
        return (
            user.score,
            user.active
        );
    }

    function getUser()
        public
        view
        returns (
            uint256,
            bool
        )
    {
        User storage user = users[msg.sender];

        return (
            user.score,
            user.active
        );
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createUser()

STORAGE STATE:

{
    score: 100,
    active: true
}

---------------------------------------------------------

CALL:
updateUsingStorage()

EVM ACTIONS:

1. Storage reference created
2. user points directly to storage
3. user.score updated
4. Blockchain state modified permanently

---------------------------------------------------------

FINAL STORAGE STATE:

{
    score: 999,
    active: true
}

=========================================================

CALL:
updateUsingMemory()

EVM ACTIONS:

1. Storage struct copied into memory
2. user becomes temporary copy
3. Memory values modified
4. Storage remains untouched
5. Memory destroyed after execution

---------------------------------------------------------

MEMORY COPY:

{
    score: 555,
    active: false
}

---------------------------------------------------------

ACTUAL STORAGE STILL:

{
    score: 999,
    active: true
}

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createUser()

---------------------------------------------------------

STEP 3:
Call:
getUser()

EXPECTED:
100, true

---------------------------------------------------------

STEP 4:
Call:
updateUsingStorage()

---------------------------------------------------------

STEP 5:
Call:
getUser()

EXPECTED:
999, true

OBSERVE:
Storage permanently updated.

---------------------------------------------------------

STEP 6:
Call:
updateUsingMemory()

EXPECTED RETURN:
555, false

---------------------------------------------------------

STEP 7:
Call:
getUser()

EXPECTED:
999, true

OBSERVE:
Storage remained unchanged.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Call updateUsingMemory() repeatedly

EXPECTED:
Storage never changes

---------------------------------------------------------

TEST:
Call updateUsingStorage() multiple times

EXPECTED:
Storage updates persist

---------------------------------------------------------

TEST:
Use different Remix accounts

EXPECTED:
Each address has isolated storage

=========================================================
IMPORTANT REFERENCE UNDERSTANDING
=========================================================

---------------------------------------------------------
STORAGE REFERENCE
---------------------------------------------------------

User storage user = users[msg.sender];

Creates POINTER.

Changes affect original storage.

---------------------------------------------------------
MEMORY COPY
---------------------------------------------------------

User memory user = users[msg.sender];

Creates INDEPENDENT COPY.

Changes affect only memory.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

MANY BUGS HAPPEN BECAUSE:

Developer expects:
storage update

But accidentally modifies:
memory copy

---------------------------------------------------------

RESULT:
Protocol logic silently fails.

=========================================================
GAS OBSERVATION
=========================================================

STORAGE WRITES:
Expensive

---------------------------------------------------------

MEMORY OPERATIONS:
Cheaper

---------------------------------------------------------

COPYING STORAGE TO MEMORY:
Still consumes gas

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

One of most common Solidity bug classes.

Auditors inspect:
- copy semantics
- reference behavior
- mutation expectations

---------------------------------------------------------
2. ACCIDENTAL STORAGE MUTATION
---------------------------------------------------------

Storage references may:
unexpectedly modify state.

---------------------------------------------------------
3. SILENT FAILURES
---------------------------------------------------------

Memory modifications may:
appear successful
but never persist.

---------------------------------------------------------
4. GAS RISKS
---------------------------------------------------------

Large copies from storage to memory
can become expensive.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Critical validation modifies memory copy
instead of storage.

Security state never updates.

Possible impact:
- bypassed restrictions
- broken accounting
- failed access control

---------------------------------------------------------

ANOTHER RISK

Unexpected storage references may:
modify balances unintentionally.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add memory array example
2. Add storage array example
3. Compare mutation behavior

BONUS:
Observe gas differences in Remix.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage creates direct reference
- Memory creates independent copy
- Storage updates persist permanently
- Memory updates disappear after execution
- Memory/storage confusion causes bugs
- Storage writes consume more gas
- Copying storage to memory costs gas
- Reference behavior critical in Solidity
- Many vulnerabilities come from wrong assumptions
- Auditors inspect mutation semantics carefully

=========================================================
*/





/*
Audit Report

Title:
Memory Updates Do Not Persist to Storage

Severity:
Medium

Reason:
The contract modifies memory copies instead of directly modifying blockchain storage.
Changes made in memory disappear after function execution.
This may create silent protocol logic failures if developers expect permanent state updates.

Location:
Contract:
StorageVsMemoryVul

Functions:
updateUsingMemory()

Vulnerability Description:
The contract creates a memory copy using:
User memory user = users[msg.sender];

Then modifies the memory copy:
user.score = 555;
user.active = false;
However, memory creates a temporary independent copy.

The original storage data:
users[msg.sender]
remains unchanged.

After execution finishes:
memory is cleared
temporary changes disappear
blockchain storage stays unchanged
Developers unfamiliar with Solidity reference behavior may incorrectly assume:
user.score = 555;
updates permanent blockchain state.
But it only updates temporary memory.

Impact:
Critical protocol state may fail to update permanently.

If similar logic exists in:
staking systems
governance systems
token accounting
access control
reward systems
NFT marketplaces

then expected updates may silently fail.

Possible problems:

incorrect balances
broken permissions
failed accounting
inconsistent protocol behavior
Proof of Concept:
Step 1:

Deploy contract.

Step 2:

Call:

createUser()

Storage state:

score = 100
active = true
Step 3:

Call:

updateUsingMemory()

Returned values:

555, false
Step 4:

Call:

getUser()

Result:

100, true
OBSERVE:

Storage values were NOT updated.

Only temporary memory values changed.

After execution:

memory destroyed automatically
storage remained unchanged

Root Cause:
The contract uses:
User memory user = users[msg.sender];

instead of:
User storage user = users[msg.sender];
memory creates an independent temporary copy.
Changes affect only temporary execution memory.
They do NOT persist permanently on blockchain storage.

Recommendation:
Use storage references when permanent updates are intended.

Example:

User storage user = users[msg.sender];

This creates a direct reference to blockchain storage.

All modifications then persist permanently.

Auditors should carefully inspect:

memory vs storage behavior
copy vs reference semantics
silent state update failures
mutation logic

*/

//Patched Code

contract StorageVsMemory {

    /*
        STRUCT STORED ON BLOCKCHAIN
    */
    struct User {

        uint256 score;

        bool active;
    }

    /*
        STORAGE MAPPING
    */
    mapping(address => User) public users;

    /*
        STORAGE ARRAY
    */
    uint256[] public numbers;

    function createUser() public {

        users[msg.sender] = User({

            score: 100,

            active: true
        });
    }

    /*
    =====================================================
    STORAGE STRUCT UPDATE
    =====================================================
    */
    function updateUsingStorage() public {

        /*
            STORAGE REFERENCE
        */
        User storage user = users[msg.sender];

        /*
            MODIFY STORAGE DIRECTLY
        */
        user.score = 999;
    }

    /*
    =====================================================
    MEMORY STRUCT UPDATE
    =====================================================
    */
    function updateUsingMemory()
        public
        view
        returns (
            uint256,
            bool
        )
    {

        /*
            MEMORY COPY
        */
        User memory user = users[msg.sender];

        /*
            MODIFY MEMORY ONLY
        */
        user.score = 555;

        user.active = false;

        return (
            user.score,
            user.active
        );
    }

    /*
    =====================================================
    ADD ARRAY VALUES
    =====================================================
    */
    function addArrayValues() public {

        numbers.push(10);
        numbers.push(20);
        numbers.push(30);
    }

    /*
    =====================================================
    MEMORY ARRAY EXAMPLE
    =====================================================

    Creates independent memory copy.
    Storage remains unchanged.
    */
    function modifyMemoryArray()
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory
        )
    {

        /*
            STORAGE -> MEMORY COPY
        */
        uint256[] memory tempArray = numbers;

        /*
            MODIFY MEMORY COPY ONLY
        */
        tempArray[0] = 999;

        /*
            RETURN:
            1. Modified memory array
            2. Original storage array
        */
        return (
            tempArray,
            numbers
        );
    }

    /*
    =====================================================
    STORAGE ARRAY EXAMPLE
    =====================================================

    Direct storage reference.
    Changes persist permanently.
    */
    function modifyStorageArray()
        public
        returns (
            uint256[] memory
        )
    {

        /*
            STORAGE REFERENCE
        */
        uint256[] storage tempArray = numbers;

        /*
            MODIFY STORAGE DIRECTLY
        */
        tempArray[0] = 777;

        tempArray[1] = 888;

        /*
            STORAGE UPDATED
        */
        return numbers;
    }

    /*
        VIEW USER
    */
    function getUser()
        public
        view
        returns (
            uint256,
            bool
        )
    {

        User storage user = users[msg.sender];

        return (
            user.score,
            user.active
        );
    }

    /*
        VIEW STORAGE ARRAY
    */
    function getArray()
        public
        view
        returns (
            uint256[] memory
        )
    {
        return numbers;
    }
}