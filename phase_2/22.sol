// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use memory struct
CONCEPT: Temporary structs
=========================================================

OBJECTIVE

- Learn how memory structs work
- Understand temporary struct allocation
- Learn difference between memory structs and storage structs
- Understand temporary object lifecycle

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory structs:
- exist temporarily
- live only during execution
- disappear after function ends

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Memory structs do NOT persist
on blockchain storage.

They are useful for:
- temporary calculations
- data transformation
- returning grouped data
- processing information safely

---------------------------------------------------------
MEMORY STRUCT VS STORAGE STRUCT
---------------------------------------------------------

MEMORY STRUCT:
- temporary
- isolated copy
- cheaper
- disappears after execution

STORAGE STRUCT:
- permanent
- stored on blockchain
- expensive
- persists forever

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Memory structs used in:

- temporary user objects
- order processing
- calculations
- validation logic
- returned API-style responses

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is struct temporary or persistent?
- Is developer expecting storage mutation?
- Are copies handled safely?
- Are references intentional?
- Can large structs waste gas?

=========================================================
*/

contract MemoryStructExampleVul {

    /*
        STRUCT DEFINITION

        Groups related data together.
    */
    struct User {

        string name;

        uint256 age;

        bool active;
    }

    /*
        STORAGE STRUCT

        Stored permanently on blockchain.
    */
    User public storedUser;

    function createMemoryStruct()
        public
        pure
        returns (
            string memory,
            uint256,
            bool
        )
    {

        /*
            MEMORY STRUCT CREATION

            Temporary struct allocated in memory.
        */
        User memory tempUser = User({

            name: "Alice",

            age: 25,

            active: true
        });

        /*
            tempUser exists only during execution.
        */
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function createAndModifyMemoryStruct()
        public
        pure
        returns (
            string memory,
            uint256,
            bool
        )
    {

        /*
            Temporary memory struct
        */
        User memory tempUser = User({

            name: "Bob",

            age: 30,

            active: true
        });

        /*
            MODIFY MEMORY STRUCT

            Changes affect only temporary copy.
        */
        tempUser.age = 99;

        tempUser.active = false;

        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function storeUser() public {

        /*
            STORAGE MUTATION

            This persists permanently.
        */
        storedUser = User({

            name: "Charlie",

            age: 40,

            active: true
        });
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createMemoryStruct()

EVM ACTIONS:

1. Temporary memory allocated
2. Struct created in memory
3. Values assigned
4. Data returned
5. Memory cleared after execution

---------------------------------------------------------

IMPORTANT

tempUser does NOT persist permanently.

---------------------------------------------------------

CALL:
createAndModifyMemoryStruct()

INITIAL MEMORY STRUCT:

{
    name: "Bob",
    age: 30,
    active: true
}

---------------------------------------------------------

AFTER MODIFICATION:

{
    name: "Bob",
    age: 99,
    active: false
}

---------------------------------------------------------

AFTER FUNCTION ENDS:
Memory struct destroyed.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createMemoryStruct()

EXPECTED:
"Alice", 25, true

---------------------------------------------------------

STEP 3:
Call:
createAndModifyMemoryStruct()

EXPECTED:
"Bob", 99, false

---------------------------------------------------------

STEP 4:
Call:
storedUser()

EXPECTED:
Empty/default values

OBSERVE:
Memory structs did NOT persist.

---------------------------------------------------------

STEP 5:
Call:
storeUser()

---------------------------------------------------------

STEP 6:
Call:
storedUser()

EXPECTED:
"Charlie", 40, true

OBSERVE:
Storage struct persists permanently.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Modify memory struct repeatedly

EXPECTED:
Fresh struct created each execution

---------------------------------------------------------

TEST:
Use empty strings

EXPECTED:
Works correctly

---------------------------------------------------------

TEST:
Large struct data

OBSERVE:
More memory allocation
= higher gas usage

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS CREATES MEMORY STRUCT:

User memory tempUser

---------------------------------------------------------

STRUCT EXISTS ONLY:
during function execution.

---------------------------------------------------------

AFTER EXECUTION:
Memory cleared automatically.

---------------------------------------------------------

VERY IMPORTANT

Memory structs:
do NOT persist on blockchain.

=========================================================
MEMORY STRUCT MUTABILITY
=========================================================

MEMORY STRUCTS ARE MUTABLE

Example:

tempUser.age = 99;

---------------------------------------------------------

HOWEVER:
Changes remain temporary only.

=========================================================
MEMORY VS STORAGE STRUCT
=========================================================

---------------------------------------------------------
MEMORY STRUCT
---------------------------------------------------------

Temporary

Cheap

Destroyed after execution

---------------------------------------------------------
STORAGE STRUCT
---------------------------------------------------------

Permanent

Expensive

Stored on blockchain forever

=========================================================
GAS OBSERVATION
=========================================================

MEMORY STRUCTS:
Cheaper than storage

---------------------------------------------------------

LARGE STRUCTS:
Still increase memory cost

---------------------------------------------------------

STORAGE WRITES:
Most expensive operations

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug source.

Developers may think:
memory modifications persist.

They do NOT.

---------------------------------------------------------
2. COPY ASSUMPTIONS
---------------------------------------------------------

Auditors verify:
whether struct is:
- temporary copy
OR
- storage reference

---------------------------------------------------------
3. LARGE MEMORY STRUCTS
---------------------------------------------------------

Huge structs may:
- waste gas
- increase execution cost

---------------------------------------------------------
4. SILENT LOGIC FAILURES
---------------------------------------------------------

Protocol may expect:
storage mutation

but only memory updated.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer modifies memory struct
expecting permanent update.

Critical state never changes.

Possible impact:
- broken access control
- failed accounting
- incorrect balances

---------------------------------------------------------

ANOTHER RISK

Attacker supplies huge struct data.

Result:
high gas consumption.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Copy storage struct into memory
2. Modify memory copy
3. Show storage remains unchanged

BONUS:
Compare:
memory struct vs storage struct behavior

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory structs are temporary
- Memory structs disappear after execution
- Memory structs are mutable
- Storage structs persist permanently
- Memory changes do not affect storage
- Memory cheaper than storage
- Large structs increase gas usage
- Copy/reference confusion causes bugs
- Structs group related data together
- Auditors inspect struct semantics carefully

=========================================================
*/


/*
Audit Report

Title:
Memory Struct Modification Does Not Persist to Storage

Severity:
Medium

Reason:
Changing a memory struct only changes temporary data during function execution.
The blockchain storage is NOT updated permanently.
This can create silent logic bugs if developers think the changes are saved permanently.

Location:
Contract:
MemoryStructExampleVul

Functions:
createMemoryStruct()
createAndModifyMemoryStruct()

Vulnerability Description:
The contract creates temporary memory structs using:
User memory tempUser = User({
    name: "Bob",
    age: 30,
    active: true
});

The struct is later modified:
tempUser.age = 99;
tempUser.active = false;
But memory structs are temporary.

After function execution:
memory is cleared
changes disappear
storage remains unchanged
So the updated values are NOT saved permanently on blockchain storage.

Developers may incorrectly think:
tempUser.age = 99;
updates blockchain state permanently.
But it only changes temporary execution memory.

Impact:
Important protocol state may fail to update permanently.
If this type of logic is used in:
staking systems
reward systems
governance systems
user profile systems
NFT ownership logic
then state updates may silently fail.

Possible problems:
incorrect balances
failed accounting
broken permissions
inconsistent protocol behavior

Proof of Concept:
Step 1:
Deploy contract.

Step 2:
Call:
createAndModifyMemoryStruct()

Returned values:
"Bob", 99, false

Step 3:
Call:
storedUser()

Result:
"", 0, false

OBSERVE:
Storage struct was NOT updated.
Only temporary memory values changed.
After execution finished:
memory destroyed automatically
changes disappeared

Root Cause:
The contract uses:
User memory tempUser

instead of:
User storage tempUser
memory creates a temporary copy.
Changes affect only temporary execution memory.
They do NOT persist on blockchain storage.

Recommendation:
Use storage references when permanent updates are required.

Example:
User storage tempUser = storedUser;
This creates a direct reference to blockchain storage.
Now all modifications persist permanently.

Auditors should carefully inspect:
memory vs storage usage
temporary vs permanent data
struct copy behavior
silent state update failures
*/

//Patched Code

contract MemoryStructExample {

    /*
        STRUCT DEFINITION
    */
    struct User {

        string name;

        uint256 age;

        bool active;
    }

    /*
        STORAGE STRUCT
    */
    User public storedUser;

    /*
        STORE USER IN STORAGE
    */
    function storeUser() public {

        storedUser = User({

            name: "Charlie",

            age: 40,

            active: true
        });
    }

    /*
    =====================================================
    MEMORY STRUCT COPY
    =====================================================

    Copies storage struct into memory.

    Storage remains unchanged.
    */
    function modifyMemoryCopy()
        public
        view
        returns (
            string memory,
            uint256,
            bool,
            string memory,
            uint256,
            bool
        )
    {

        /*
            STORAGE -> MEMORY COPY
        */
        User memory tempUser = storedUser;

        /*
            MODIFY MEMORY COPY ONLY
        */
        tempUser.age = 99;

        tempUser.active = false;

        /*
            RETURN:
            1. Modified memory struct
            2. Original storage struct
        */
        return (

            tempUser.name,
            tempUser.age,
            tempUser.active,

            storedUser.name,
            storedUser.age,
            storedUser.active
        );
    }

    /*
    =====================================================
    STORAGE REFERENCE
    =====================================================

    Directly modifies storage.
    */
    function modifyStorageReference()
        public
    {

        /*
            STORAGE REFERENCE
        */
        User storage tempUser = storedUser;

        /*
            MODIFY STORAGE DIRECTLY
        */
        tempUser.age = 77;

        tempUser.active = false;
    }

    /*
        VIEW STORAGE USER
    */
    function getStoredUser()
        public
        view
        returns (
            string memory,
            uint256,
            bool
        )
    {

        return (
            storedUser.name,
            storedUser.age,
            storedUser.active
        );
    }
}

