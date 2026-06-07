// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call another contract
CONCEPT: Inter-contract communication
=========================================================

OBJECTIVE

- Learn how contracts call other contracts
- Understand inter-contract execution flow
- Learn external call behavior
- Understand cross-contract risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Smart contracts can:
call functions in other contracts.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Cross-contract calls create:
NEW execution context.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most real protocols interact with:

- tokens
- vaults
- oracles
- DEXes
- lending protocols
- bridges

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Inter-contract communication used in:

- ERC20 transfers
- AMM swaps
- lending protocols
- NFT marketplaces
- staking systems
- governance execution

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- external call safety
- trust assumptions
- reentrancy risk
- return-value handling
- cross-contract state assumptions

=========================================================
CONTRACT 1:
TARGET CONTRACT
=========================================================
*/

contract Bank {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    */

    function deposit(
        uint256 _amount
    )
        external
    {

        /*
            Update storage.
        */
        balances[msg.sender] += _amount;
    }

    /*
    =====================================================
    READ BALANCE
    =====================================================
    */

    function getBalance(
        address _user
    )
        external
        view
        returns (uint256)
    {

        return balances[_user];
    }
}

/*
=========================================================
CONTRACT 2:
CALLER CONTRACT
=========================================================
*/

contract InterContractCaller {

    /*
        STORE TARGET CONTRACT ADDRESS
    */
    address public bankAddress;

    /*
        LAST READ VALUE
    */
    uint256 public lastBalance;

    /*
        CONSTRUCTOR

        Save target contract address.
    */
    constructor(
        address _bankAddress
    )
    {

        bankAddress = _bankAddress;
    }

    /*
    =====================================================
    CALL DEPOSIT FUNCTION
    =====================================================
    */

    function callDeposit(
        uint256 _amount
    )
        external
    {

        /*
            Create contract reference.

            Tells Solidity:
            "bankAddress is a Bank contract"
        */
        Bank bank =
            Bank(bankAddress);

        /*
            EXTERNAL CONTRACT CALL

            Execution jumps into:
            Bank.deposit()
        */
        bank.deposit(_amount);
    }

    /*
    =====================================================
    READ ANOTHER CONTRACT STATE
    =====================================================
    */

    function readBalance(
        address _user
    )
        external
    {

        /*
            Create contract reference.
        */
        Bank bank =
            Bank(bankAddress);

        /*
            External view call.

            Reads state from another contract.
        */
        uint256 balance =
            bank.getBalance(_user);

        /*
            Save locally.
        */
        lastBalance = balance;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy Bank contract.

---------------------------------------------------------

Bank deployed at:

0xABC...

=========================================================
STEP 2:
Deploy InterContractCaller

constructor input:
0xABC...

---------------------------------------------------------

Caller now knows:
Bank contract address.

=========================================================
TRACE:
callDeposit(100)
=========================================================

STEP 1:
User calls:

InterContractCaller.callDeposit(100)

---------------------------------------------------------

STEP 2:
Contract reference created:

Bank bank =
Bank(bankAddress)

---------------------------------------------------------

STEP 3:
External contract call occurs:

bank.deposit(100)

---------------------------------------------------------

EXECUTION CONTEXT SWITCHES

---------------------------------------------------------

Execution enters:
Bank.deposit()

=========================================================
INSIDE BANK CONTRACT
=========================================================

balances[msg.sender] += 100

---------------------------------------------------------

IMPORTANT:

msg.sender is:
InterContractCaller contract

NOT original user.

=========================================================
VERY IMPORTANT msg.sender UNDERSTANDING
=========================================================

Cross-contract call changes:

msg.sender

---------------------------------------------------------

FLOW:

User
  ->
Caller Contract
  ->
Bank Contract

---------------------------------------------------------

Inside Bank:

msg.sender =
Caller contract address

=========================================================
READ FLOW TRACE
=========================================================

CALL:
readBalance(user)

=========================================================

STEP 1:
Caller contract executes.

---------------------------------------------------------

STEP 2:
External view call:

bank.getBalance(user)

---------------------------------------------------------

STEP 3:
Execution enters Bank contract.

---------------------------------------------------------

STEP 4:
Balance returned.

---------------------------------------------------------

STEP 5:
Caller stores result:

lastBalance = returned balance

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy Bank contract

---------------------------------------------------------

STEP 2:
Copy Bank address

---------------------------------------------------------

STEP 3:
Deploy InterContractCaller

Constructor input:
Bank address

---------------------------------------------------------

STEP 4:
Call:
callDeposit(100)

---------------------------------------------------------

STEP 5:
Open Bank contract

---------------------------------------------------------

STEP 6:
Call:
balances(caller_contract_address)

EXPECTED:
100

---------------------------------------------------------

IMPORTANT:
Balance stored for CALLER contract.

=========================================================
IMPORTANT CROSS-CONTRACT UNDERSTANDING
=========================================================

External calls create:

- new execution context
- new msg.sender
- possible reentrancy window
- trust assumptions

=========================================================
INTERFACE-LIKE BEHAVIOR
=========================================================

This line:

Bank(bankAddress)

means:

"Treat this address as Bank contract"

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

External contract may call back unexpectedly.

---------------------------------------------------------
2. TRUST ASSUMPTIONS
---------------------------------------------------------

Target contract may behave maliciously.

---------------------------------------------------------
3. RETURN VALUE IGNORED
---------------------------------------------------------

Dangerous if call fails silently.

---------------------------------------------------------
4. msg.sender CONFUSION
---------------------------------------------------------

Critical authentication mistakes possible.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

External contract calls are:

UNTRUSTED INTERACTIONS

---------------------------------------------------------

Never assume:
target contract behaves safely.

=========================================================
GAS OBSERVATION
=========================================================

Cross-contract calls:
cost more gas.

---------------------------------------------------------

Reason:
context switching + external execution.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Which contracts are trusted?
- Can target contract reenter?
- Is msg.sender handled correctly?
- Are return values checked?
- Are external calls ordered safely?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Malicious contract called externally.

---------------------------------------------------------

During execution:
it reenters vulnerable function.

---------------------------------------------------------

Result:
fund theft.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Cross-contract execution flow
2. msg.sender changes
3. External interaction timing
4. State-update ordering
5. Reentrancy windows

=========================================================
MINI CHALLENGE
=========================================================

Modify system so that:

1. Add withdraw() function
2. Add external ETH transfer
3. Observe msg.sender changes
4. Add interface contract

BONUS:
Build simple token interaction.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Contracts can call other contracts
- External calls create new execution context
- msg.sender changes during contract calls
- Cross-contract interactions are risky
- External calls may enable reentrancy
- Contract references treat addresses as contracts
- Return values must be checked carefully
- Auditors trace inter-contract execution carefully
- Trust assumptions are security critical
- Inter-contract communication powers DeFi systems

=========================================================
*/

/*
Audit Report

Title: Missing Validation of External Contract Address

Severity: Informational / Low

Category: Configuration Risk

Location:
Contract:
InterContractCaller

Constructor:
constructor(
    address _bankAddress
)
{
    bankAddress = _bankAddress;
}
Description:
The InterContractCaller contract accepts an external contract address during deployment and stores it without validating that the supplied address is a deployed contract.

Current implementation:
bankAddress = _bankAddress;

No validation exists to ensure:
Address is not zero.
Address contains deployed contract code.
Address belongs to the intended Bank contract.
If an incorrect address is provided, external calls may revert or behave unexpectedly.

Impact:
Potential impacts include:
Broken protocol functionality.
Unexpected transaction failures.
Calls directed to unintended contracts.
Incorrect assumptions about external state.
No direct theft of funds exists in the current implementation.

Proof of Concept:
Deploy:
InterContractCaller

Constructor input:
0x0000000000000000000000000000000000000000

Call:
callDeposit(100)

Execution:
InterContractCaller
Invalid Address

Result:
Transaction reverts
Protocol functionality unavailable

Root Cause:
Blind trust in externally supplied contract addresses.

Current implementation:
constructor(
    address _bankAddress
)
{
    bankAddress = _bankAddress;
}
Recommendation:
Validate external dependencies during deployment.

Example:
require(
    _bankAddress != address(0),
    "Zero address"
);

require(
    _bankAddress.code.length > 0,
    "Not a contract"
);
*/

//Patch Code

contract InterContractCallerPatched {

address public bankAddress;

uint256 public lastBalance;

constructor(
    address _bankAddress
)
{
    require(
        _bankAddress != address(0),
        "Zero address"
    );

    require(
        _bankAddress.code.length > 0,
        "Not a contract"
    );

    bankAddress = _bankAddress;
}

function callDeposit(
    uint256 _amount
)
    external
{
    Bank bank =
        Bank(bankAddress);

    bank.deposit(_amount);
}

function readBalance(
    address _user
)
    external
{
    Bank bank =
        Bank(bankAddress);

    uint256 balance =
        bank.getBalance(_user);

    lastBalance = balance;
}

}
