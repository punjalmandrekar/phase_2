// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Compare storage before/after tx
CONCEPT: State persistence
=========================================================

OBJECTIVE

- Learn how blockchain state changes after transactions
- Understand persistence of storage variables
- Compare state BEFORE and AFTER execution
- Learn why transactions permanently modify storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Before transaction:
Storage contains OLD state

After transaction:
Storage contains UPDATED state

Blockchain permanently stores
latest contract state.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Transactions:
- modify blockchain state
- consume gas
- persist changes permanently

view functions:
- only read state
- do NOT modify storage

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

State persistence is critical in:

- token balances
- staking systems
- ownership tracking
- DeFi protocols
- NFT ownership
- governance systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Was state updated correctly?
- Did transaction modify intended storage?
- Can state become corrupted?
- Is old state unexpectedly overwritten?
- Are updates atomic and safe?

=========================================================
*/

contract StatePersistenceVul {

    uint256 public counter;

    function increment() public {

        counter = counter + 1;
    }

    function setCounter(uint256 _value) public {

        counter = _value;
    }

    function getCounter() public view returns (uint256) {

        return counter;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

counter = 0

Stored permanently in blockchain storage.

---------------------------------------------------------

CALL:
increment()

BEFORE TX:
counter = 0

EVM ACTIONS:

1. Transaction reaches contract
2. Current storage value loaded
3. counter + 1 calculated
4. Storage slot updated
5. New value persisted

AFTER TX:
counter = 1

---------------------------------------------------------
 
CALL:
increment()

BEFORE TX:
counter = 1

AFTER TX:
counter = 2

---------------------------------------------------------

CALL:
setCounter(100)

BEFORE TX:
counter = 2

AFTER TX:
counter = 100

---------------------------------------------------------

IMPORTANT OBSERVATION

State persists BETWEEN transactions.

Every new transaction sees
latest stored value.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

EXPECTED:
counter() => 0

---------------------------------------------------------

STEP 2:
Call:
increment()

EXPECTED:
counter() => 1

---------------------------------------------------------

STEP 3:
Call:
increment()

EXPECTED:
counter() => 2

---------------------------------------------------------

STEP 4:
Call:
setCounter(999)

EXPECTED:
counter() => 999

---------------------------------------------------------

STEP 5:
Refresh Remix UI

EXPECTED:
counter still equals 999

OBSERVE:
Storage persists permanently.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Set counter to 0

EXPECTED:
Storage resets to 0

---------------------------------------------------------

TEST:
Repeated transactions

increment()
increment()
increment()

EXPECTED:
Counter increases sequentially

---------------------------------------------------------

TEST:
Large uint256 values

EXPECTED:
Works correctly in Solidity ^0.8.x

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

STATE BEFORE TX

Storage contains previous blockchain state.

---------------------------------------------------------

STATE AFTER TX

Updated values become new permanent state.

---------------------------------------------------------

VERY IMPORTANT

Each transaction:
- reads current storage
- modifies storage
- commits updated state

---------------------------------------------------------

BLOCKCHAIN PERSISTENCE

Storage survives:
- new transactions
- page refreshes
- node restarts

=========================================================
EVM INTERNAL FLOW
=========================================================

increment()

1. Read counter from storage
2. Load into EVM stack
3. Perform addition
4. Write updated value back to storage
5. Persist state to blockchain

---------------------------------------------------------

counter variable lives in STORAGE.

Temporary computation happens in:
- stack
- memory

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. STATE CONSISTENCY
---------------------------------------------------------

Auditors verify:
- storage updated correctly
- no partial updates
- no unexpected overwrites

---------------------------------------------------------
2. RACE CONDITIONS
---------------------------------------------------------

Multiple users may update same state.

Auditors inspect:
- ordering issues
- stale reads
- transaction assumptions

---------------------------------------------------------
3. ACCESS CONTROL
---------------------------------------------------------

Current issue:
ANYONE can modify counter.

Danger if counter controls:
- protocol settings
- rewards
- treasury logic

---------------------------------------------------------
4. PERSISTENT STATE RISKS
---------------------------------------------------------

Bad state changes persist permanently.

Incorrect updates may:
- corrupt protocol
- lock funds
- break logic forever

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose counter tracks:
- reward multiplier
- treasury percentage
- governance threshold

Attacker calls:

setCounter(999999)

Impact:
Protocol behavior manipulated.

---------------------------------------------------------

ANOTHER RISK

Unexpected state persistence may:
- preserve malicious values
- maintain broken configuration
- cause long-term protocol damage

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Store previousCounter
2. Before every update:
   save old value

BONUS:
Emit event showing:
old value -> new value

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage persists across transactions
- Transactions permanently modify state
- view functions only read storage
- State before tx differs from after tx
- EVM reads then writes storage
- Storage updates consume gas
- Blockchain maintains latest state
- Incorrect state updates are dangerous
- Access control protects persistent state
- Auditors inspect state transitions carefully

=========================================================
*/


/*
Audit Report

Title:
Missing Historical State Tracking in Counter Updates

Severity:
Low

Reason:
State updates overwrite previous values without preserving historical state information.

Location:
Contract: StatePersistenceVul

Functions:
increment()
setCounter()
Vulnerability Description:
The contract updates the counter storage variable directly without preserving the previous value.

As a result:
old state information is lost
state transitions cannot be tracked easily
debugging and auditing become more difficult
Additionally, no events are emitted during state updates, reducing transaction observability.

Impact:
Lack of state history tracking may lead to:
poor auditability
difficult debugging
reduced monitoring visibility
inability to verify previous state transitions
If the variable controlled critical protocol logic, missing state tracking could complicate incident investigation and protocol monitoring.

Proof of Concept:
Initial state:
counter = 5

Call:
setCounter(100)

Final state:
counter = 100

Old value:
5
is permanently overwritten and not stored anywhere inside the contract.
No event log records the transition.

Root Cause:
The contract directly overwrites storage:
counter = _value;
without preserving the previous value or emitting state transition events.

Recommendation:
Before every state update:
Save the previous value

Emit an event showing:
old value
new value

This improves:
transparency
monitoring
auditability
off-chain indexing
*/

//Patched Code:

contract StatePersistence {

    uint256 public counter;

    // Store old value
    uint256 public previousCounter;

    // Event for state updates
    event CounterUpdated(
        uint256 oldValue,
        uint256 newValue
    );

    function increment() public {

        // Save old value
        previousCounter = counter;

        // Update counter
        counter++;

        // Emit event
        emit CounterUpdated(previousCounter, counter);
    }

    function setCounter(uint256 _value) public {

        // Save old value
        previousCounter = counter;

        // Update counter
        counter = _value;

        // Emit event
        emit CounterUpdated(previousCounter, counter);
    }

    function getCounter() public view returns (uint256) {

        return counter;
    }
}