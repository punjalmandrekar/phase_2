// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Update state variable multiple times
CONCEPT: State overwrite behavior
=========================================================

OBJECTIVE

- Learn how state variables behave when updated repeatedly
- Understand overwrite behavior in Solidity storage
- Learn that old values are replaced permanently
- Understand why overwriting important data can be dangerous

---------------------------------------------------------
CORE CONCEPT
---------------------------------------------------------

STATE VARIABLES:
- Stored permanently in blockchain storage
- Can be updated many times
- New value overwrites old value
- Old value is NOT automatically preserved

IMPORTANT:
Blockchain stores current state,
NOT full variable history inside storage.

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- Is overwriting intended?
- Should previous values be preserved?
- Can attackers overwrite critical data?
- Is important state lost accidentally?
- Should events/history tracking exist?

=========================================================
*/

contract StateOverwriteVul {

    uint256 public number;

    function updateNumber(uint256 _newNumber) public {
        number = _newNumber;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

number = 0

---------------------------------------------------------

CALL:
updateNumber(10)

EVM ACTIONS:
1. Transaction received
2. _newNumber comes through calldata
3. Storage slot for "number" updated
4. number becomes 10

---------------------------------------------------------

CALL:
updateNumber(50)

EVM ACTIONS:
1. Previous value = 10
2. Storage slot updated again
3. Old value replaced
4. number becomes 50

IMPORTANT:
Old value 10 is overwritten.

---------------------------------------------------------

CALL:
updateNumber(999)

RESULT:
number = 999

Only latest value exists in storage.

=========================================================
REMIX TESTING
=========================================================

NORMAL FLOW

STEP 1:
Deploy contract

EXPECTED:
number() => 0

---------------------------------------------------------

STEP 2:
Call:
updateNumber(10)

EXPECTED:
number() => 10

---------------------------------------------------------

STEP 3:
Call:
updateNumber(500)

EXPECTED:
number() => 500

OBSERVE:
Old value 10 no longer exists in storage.

---------------------------------------------------------

STEP 4:
Call:
updateNumber(777)

EXPECTED:
number() => 777

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
updateNumber(0)

EXPECTED:
Value resets to zero

---------------------------------------------------------

TEST:
Repeated updates

Call:
updateNumber(1)
updateNumber(2)
updateNumber(3)
updateNumber(4)

EXPECTED:
Final stored value = 4

=========================================================
IMPORTANT STORAGE OBSERVATION
=========================================================

STORAGE SLOT BEHAVIOR

The same storage slot gets updated repeatedly.

Example:

Initial:
slot0 => 0

After updateNumber(10):
slot0 => 10

After updateNumber(50):
slot0 => 50

After updateNumber(999):
slot0 => 999

Old values are replaced.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

POTENTIAL PROBLEM

If this variable stored:

- admin address
- token price
- protocol fee
- treasury balance
- voting result

then accidental or malicious overwrites
could break protocol logic.

---------------------------------------------------------

AUDITOR QUESTIONS

- Should overwrite be allowed?
- Is history needed?
- Should updates be restricted?
- Should old values be logged in events?
- Can attackers spam updates?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose number represents protocol fee.

Attacker repeatedly calls:

updateNumber(0)

or

updateNumber(999999)

Possible impact:
- protocol malfunction
- incorrect calculations
- financial manipulation

---------------------------------------------------------

REAL-WORLD ISSUE

Many smart contract hacks happen because:
- important state gets overwritten
- validation missing
- access control missing

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Previous value is stored in another variable
2. Every update saves:
   - old value
   - new value

HINT:
Create:
uint256 public previousNumber;

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- State variables live in storage
- Storage updates overwrite old values
- Latest value replaces previous value
- Storage writes cost gas
- Overwriting important state can be dangerous
- Auditors inspect overwrite behavior carefully
- History is NOT automatically preserved
- Access control is critical for state updates

=========================================================
*/





/*
Audit Report

Title:
Missing Access Control and Unsafe State Overwrite in updateNumber()

Severity:
Medium

Reason:
Unauthorized users can overwrite important protocol state variables.

Location:
Contract: StateOverwriteVul
Function: updateNumber()

Vulnerability Description:
The updateNumber() function allows any external user to overwrite the number state variable because no authorization checks are implemented.
Additionally, old values are permanently replaced during storage updates, causing loss of historical state information.
The contract does not preserve previous values or maintain update history.

Impact:
An attacker can repeatedly overwrite the stored value with arbitrary numbers.
If this variable controlled critical protocol logic such as:
protocol fees
treasury configuration
token pricing
governance results
admin-controlled parameters
then attackers could manipulate protocol behavior and potentially disrupt system operations.
Because storage overwrite replaces old values permanently, important state information may also be lost.

Proof of Concept:
Deploy the contract.

User A calls:
updateNumber(10)

Attacker calls:
updateNumber(999999)
Contract state changes successfully.

Calling:
number()

returns:
999999
Previous value 10 is permanently overwritten.

Root Cause:
The function is declared public without access restriction.
No authorization mechanism validates the caller identity before modifying storage.
The contract also overwrites storage directly without preserving previous values or implementing history tracking.

Recommendation:
Restrict update access using owner-based authorization.
Additionally, preserve previous values before overwriting storage.

Example improvements:
Add owner variable
Use constructor initialization
Add require() authorization check
Store previous value before update
Optionally emit events for history tracking
*/

//Patched Code:
contract StateOverwrite {

    uint256 public number;
    uint256 public previousNumber;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function updateNumber(uint256 _newNumber) public {

        require(msg.sender == owner, "Not owner");

        // Store previous value
        previousNumber = number;

        // Update current value
        number = _newNumber;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}