// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Read state after redeploy
CONCEPT: Deployment resets
=========================================================

OBJECTIVE

- Learn what happens when a contract is redeployed
- Understand that each deployment creates NEW storage
- Learn why previous state does not carry forward
- Understand deployment-level state isolation

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Every contract deployment creates:
- new contract address
- new storage
- new blockchain state

Old deployed contract state remains separate.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Redeploying a contract does NOT:
- update old contract
- preserve old storage
- continue previous state

Instead:
A completely NEW contract instance is created.

---------------------------------------------------------
REAL-WORLD IMPORTANCE
---------------------------------------------------------

Critical for understanding:
- upgradeable contracts
- migrations
- proxy patterns
- state persistence
- deployment architecture

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Does redeployment break state?
- Is migration logic safe?
- Is old state lost?
- Are users aware of deployment resets?
- Are upgrade mechanisms secure?

=========================================================
*/

contract DeploymentResetVul {

    uint256 public number;

    function setNumber(uint256 _number) public {

        number = _number;
    }

    function getNumber() public view returns (uint256) {

        return number;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

FIRST DEPLOYMENT

Contract Address:
0xAAA...

INITIAL STATE:

number = 0

---------------------------------------------------------

CALL:
setNumber(500)

STATE NOW:

number = 500

Stored permanently in FIRST contract.

---------------------------------------------------------

REDEPLOY CONTRACT

New Contract Address:
0xBBB...

IMPORTANT:
This is a COMPLETELY NEW contract.

---------------------------------------------------------

NEW CONTRACT STATE

number = 0

Reason:
Fresh deployment = fresh storage

---------------------------------------------------------

IMPORTANT OBSERVATION

Old contract still exists:

0xAAA...
number = 500

New contract:

0xBBB...
number = 0

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

EXPECTED:
number() => 0

---------------------------------------------------------

STEP 2:
Call:
setNumber(123)

EXPECTED:
number() => 123

---------------------------------------------------------

STEP 3:
Deploy SAME contract AGAIN

IMPORTANT:
New contract instance appears below in Remix.

---------------------------------------------------------

STEP 4:
Check number()

EXPECTED:
0

OBSERVE:
Previous state NOT preserved.

---------------------------------------------------------

STEP 5:
Compare BOTH deployed contracts

OLD CONTRACT:
number => 123

NEW CONTRACT:
number => 0

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Deploy contract multiple times

EXPECTED:
Each deployment starts fresh

---------------------------------------------------------

TEST:
Modify first deployment only

EXPECTED:
Second deployment unaffected

---------------------------------------------------------

TEST:
Modify second deployment

EXPECTED:
First deployment remains unchanged

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

CONTRACT STORAGE IS LINKED TO:

Contract Address

---------------------------------------------------------

Each deployment:
- gets unique address
- gets independent storage
- maintains separate state

---------------------------------------------------------

VERY IMPORTANT

Blockchain stores state PER CONTRACT ADDRESS.

Example:

0xAAA... => number = 500

0xBBB... => number = 0

=========================================================
WHY THIS MATTERS
=========================================================

Many beginners wrongly assume:

"Redeploy updates existing contract"

This is FALSE.

Redeploying creates:
an entirely new contract instance.

---------------------------------------------------------

Real protocols use:
- proxy contracts
- upgradeable patterns
- migrations

to preserve state across upgrades.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. STATE LOSS RISKS
---------------------------------------------------------

Redeployment may:
- lose balances
- lose ownership
- lose user funds
- reset protocol configuration

---------------------------------------------------------
2. MIGRATION SAFETY
---------------------------------------------------------

Auditors inspect:
- safe state migration
- upgrade handling
- storage compatibility

---------------------------------------------------------
3. USER CONFUSION
---------------------------------------------------------

Users may interact with:
- old deployment accidentally
- obsolete contracts
- outdated state

---------------------------------------------------------
4. FAKE CONTRACT RISKS
---------------------------------------------------------

Attackers may deploy:
fake versions of protocols.

Users may confuse:
- old contract
- upgraded contract
- malicious clone

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker redeploys fake protocol
with identical code/UI.

Users interact with wrong contract.

Result:
- stolen funds
- fake balances
- phishing attacks

---------------------------------------------------------

ANOTHER RISK

Improper upgrade process may:
- reset critical storage
- erase balances
- destroy protocol state

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Store deployer address
2. Store deployment timestamp

HINT:

Use:
block.timestamp

and

msg.sender

inside constructor.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Each deployment creates new contract address
- Storage belongs to specific contract instance
- Redeployment does NOT preserve state
- Old contracts remain on blockchain
- State persistence is contract-specific
- Deployments are isolated from each other
- Upgrade systems require special architecture
- Migration safety is critical
- Users may confuse deployments
- Auditors inspect upgrade/deployment risks

=========================================================
*/




/*
Audit Report

Title:
State Reset on Contract Redeployment

Severity:
Informational

Reason:
Redeploying a contract creates a completely new storage state and does not preserve previous contract data.

Location:
Contract: DeploymentResetVul
Deployment Lifecycle

Vulnerability Description:
Each deployment of the contract creates:
a new contract address
a new storage layout
an independent blockchain state
Redeploying the same contract does not preserve storage values from previous deployments.
Users may incorrectly assume redeployment updates an existing contract instance.

Impact:
Redeployment may unintentionally cause:
loss of configuration state
reset of balances
loss of ownership information
migration inconsistencies
user confusion between deployments
Improper upgrade or migration handling may result in protocol malfunction or state loss.

Proof of Concept:
First Deployment

Contract address:
0xAAA...

Call:
setNumber(500)

Stored state:
number = 500
Redeploy Same Contract

New contract address:
0xBBB...

Check state:
number = 0

Observation:
Old deployment state remains unchanged
New deployment starts with fresh storage

Root Cause:
Blockchain storage is linked to contract addresses.
Each deployment creates a unique contract instance with isolated storage.

The contract does not implement:
migration logic
upgradeable storage
proxy architecture

Recommendation:
Store deployment metadata such as:
deployer address
deployment timestamp

This improves:
deployment tracking
auditability
migration verification
operational transparency

Protocols requiring persistent upgrades should use:
proxy contracts
upgradeable architectures
secure migration procedures
*/

//Patched Code:

contract DeploymentReset {

    uint256 public number;

    // Store deployer address
    address public deployer;

    // Store deployment time
    uint256 public deployedAt;

    // Runs only once during deployment
    constructor() {

        deployer = msg.sender;

        deployedAt = block.timestamp;
    }

    function setNumber(uint256 _number) public {

        number = _number;
    }

    function getNumber() public view returns (uint256) {

        return number;
    }
}