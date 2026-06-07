// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Store address in state
CONCEPT: Address persistence
=========================================================

OBJECTIVE

- Learn how Solidity stores Ethereum addresses
- Understand persistent address storage on blockchain
- Learn how addresses are updated and retrieved
- Understand security risks of storing critical addresses

---------------------------------------------------------
WHAT IS AN ADDRESS?
---------------------------------------------------------

An Ethereum address represents:
- user wallet
- smart contract
- admin account
- treasury wallet

Address type in Solidity:
address

Example:
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835Cb2

---------------------------------------------------------
IMPORTANT CONCEPT
---------------------------------------------------------

When an address is stored as a state variable:
- it is saved permanently in storage
- persists across transactions
- remains on blockchain until changed

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- Who can update stored address?
- Can attacker replace admin wallet?
- Is zero address validation missing?
- Can funds be redirected?
- Is address overwrite protected?

=========================================================
*/

contract StoreAddressVul {

    address public userAddress;

    function storeAddress(address _newAddress) public {
        userAddress = _newAddress;
    }

    function getAddress() public view returns (address) {
        return userAddress;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

userAddress = 0x0000000000000000000000000000000000000000

This is called ZERO ADDRESS.

---------------------------------------------------------

CALL:
storeAddress(0x123...)

EVM ACTIONS:

1. Transaction reaches contract
2. Address arrives through calldata
3. EVM updates storage slot
4. Address stored permanently
5. Gas consumed for storage write

---------------------------------------------------------

CALL:
getAddress()

EVM ACTIONS:

1. Reads address from storage
2. Returns stored address
3. No state modification occurs

=========================================================
REMIX TESTING
=========================================================

NORMAL FLOW

STEP 1:
Deploy contract

EXPECTED:
userAddress() returns:

0x0000000000000000000000000000000000000000

---------------------------------------------------------

STEP 2:
Copy one Remix account address

Call:
storeAddress(<paste address>)

---------------------------------------------------------

STEP 3:
Call:
userAddress()

EXPECTED:
Stored address returned correctly

---------------------------------------------------------

STEP 4:
Store another address

EXPECTED:
Old address overwritten with new one

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Store zero address

Call:
storeAddress(0x0000000000000000000000000000000000000000)

EXPECTED:
Works successfully

---------------------------------------------------------

IMPORTANT SECURITY NOTE

In real protocols,
zero address is often INVALID.

Reason:
Funds sent to zero address are usually lost forever.

=========================================================
STORAGE OBSERVATION
=========================================================

Storage slot example:

Initial:
slot0 => 0x0000000000000000000000000000000000000000

After update:
slot0 => user wallet address

After another update:
slot0 overwritten with new address

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

CRITICAL AUDITOR CHECKS

---------------------------------------------------------
1. MISSING ACCESS CONTROL
---------------------------------------------------------

Currently ANYONE can update address.

Danger:
Attacker can replace important wallet.

---------------------------------------------------------
2. ZERO ADDRESS VALIDATION
---------------------------------------------------------

Problem:
Contract allows zero address.

Real-world issue:
Funds or ownership may become unusable.

Auditors often expect:

require(_newAddress != address(0))

---------------------------------------------------------
3. ADDRESS OVERWRITE RISK
---------------------------------------------------------

If address represents:
- owner
- treasury
- signer
- reward wallet

then unauthorized overwrite becomes critical vulnerability.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose stored address is treasury wallet.

Attacker calls:

storeAddress(attackerWallet)

Now:
- future funds go to attacker
- protocol treasury hijacked

---------------------------------------------------------

ANOTHER ATTACK

Attacker sets:

address(0)

Impact:
- protocol functionality breaks
- funds may become inaccessible
- ownership can be destroyed

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Only deployer can update address
2. Zero address should be rejected

HINT:

Use:
require(_newAddress != address(0))

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Solidity supports address type
- Addresses can be stored permanently
- State variables persist on-chain
- Storage updates overwrite old values
- Zero address is special
- Missing validation creates vulnerabilities
- Access control is essential
- Critical addresses must be protected

=========================================================
*/









/*
Audit Report

Title:
Missing Access Control in updateNumber() Allows Unauthorized State Overwrite

Severity:
Medium

Reason:
Unauthorized users can repeatedly overwrite important storage variables.

Location:
Contract: StateOverwriteVul
Function: updateNumber()

Vulnerability Description:
The updateNumber() function allows any external caller to modify the number state variable because no authorization mechanism is implemented.
Although Solidity storage preserves the latest state, previous values are overwritten during updates.
The vulnerable contract does not preserve historical values and allows unrestricted state modification.

Impact:
An attacker can overwrite the stored value with arbitrary numbers.
If the variable controlled sensitive protocol logic such as:
protocol fees
token prices
treasury balances
governance parameters
admin configuration
then attackers could manipulate protocol behavior and potentially disrupt system operations.
Repeated overwrites may also cause accidental loss of important state data.

Proof of Concept:
Deploy the contract.

User A calls:
updateNumber(10)

Attacker calls:
updateNumber(999999)
Contract state updates successfully.

Calling:
number()

returns:
999999
Previous value 10 is permanently overwritten.

Root Cause:
The function is declared public without implementing access control checks.
No validation ensures that only authorized users can modify storage.
Additionally, the original contract overwrites storage directly without preserving previous values.

Recommendation:
Restrict storage updates using owner-based access control.

Additionally:
Preserve previous values before overwrite
Consider emitting events for update history
Validate input values where necessary

Example authorization check:
require(msg.sender == owner, "Not owner");
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

        // Save previous value
        previousNumber = number;

        // Update current value
        number = _newNumber;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}