// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Add nested if conditions
CONCEPT: Branching logic
=========================================================

OBJECTIVE

- Learn nested if-condition execution
- Understand branching logic in Solidity
- Learn multi-level decision flow
- Understand auditor-style path tracing

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Nested if statements create:
multiple execution branches.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Different inputs cause:
different execution paths.

Auditors must trace:
EVERY possible branch.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Many vulnerabilities hide inside:
rare execution branches.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Nested branching appears in:

- access control
- DeFi fee systems
- staking rewards
- liquidation logic
- governance rules
- NFT minting limits

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- unreachable branches
- incorrect conditions
- missing else logic
- privilege escalation
- inconsistent state updates

=========================================================
*/

contract NestedIfConditionsVul {

    /*
        OWNER ADDRESS
    */
    address public owner;

    /*
        USER SCORES
    */
    mapping(address => uint256) public scores;

    /*
        USER LEVELS
    */
    mapping(address => string) public levels;

    /*
        CONSTRUCTOR
    */
    constructor() {

        owner = msg.sender;
    }

    /*
    =====================================================
    NESTED IF LOGIC
    =====================================================
    */

    function evaluateUser(
        uint256 _score,
        bool _premium
    )
        external
    {

        /*
            FIRST BRANCH

            Check minimum score.
        */
        if (_score >= 50) {

            /*
                SECOND BRANCH

                Check premium status.
            */
            if (_premium == true) {

                /*
                    THIRD BRANCH

                    Check elite score.
                */
                if (_score >= 90) {

                    levels[msg.sender] =
                        "Elite Premium";

                } else {

                    levels[msg.sender] =
                        "Premium";
                }

            } else {

                /*
                    NON-PREMIUM USER
                */
                levels[msg.sender] =
                    "Standard";
            }

            /*
                SAVE SCORE
            */
            scores[msg.sender] = _score;

        } else {

            /*
                LOW SCORE BRANCH
            */
            levels[msg.sender] =
                "Rejected";
        }
    }

    /*
    =====================================================
    OWNER BONUS FUNCTION
    =====================================================
    */

    function ownerBonus(
        address _user
    )
        external
    {

        /*
            FIRST CONDITION:
            owner check
        */
        if (msg.sender == owner) {

            /*
                SECOND CONDITION:
                user must exist
            */
            if (scores[_user] > 0) {

                /*
                    THIRD CONDITION:
                    high score required
                */
                if (scores[_user] >= 80) {

                    scores[_user] += 20;
                }
            }
        }
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
evaluateUser(95, true)

=========================================================

STEP 1:
if (_score >= 50)

CHECK:
95 >= 50

RESULT:
true

---------------------------------------------------------

STEP 2:
if (_premium == true)

CHECK:
true == true

RESULT:
true

---------------------------------------------------------

STEP 3:
if (_score >= 90)

CHECK:
95 >= 90

RESULT:
true

---------------------------------------------------------

EXECUTION PATH:

Elite Premium branch

---------------------------------------------------------

FINAL STORAGE:

levels[user] = "Elite Premium"

scores[user] = 95

=========================================================
ANOTHER TRACE
=========================================================

CALL:
evaluateUser(60, false)

---------------------------------------------------------

STEP 1:
60 >= 50

RESULT:
true

---------------------------------------------------------

STEP 2:
premium == true

RESULT:
false

---------------------------------------------------------

EXECUTION PATH:

Standard branch

---------------------------------------------------------

FINAL STATE:

levels[user] = "Standard"

=========================================================
LOW SCORE TRACE
=========================================================

CALL:
evaluateUser(20, true)

---------------------------------------------------------

STEP 1:
20 >= 50

RESULT:
false

---------------------------------------------------------

EXECUTION JUMPS TO:

else branch

---------------------------------------------------------

FINAL STATE:

levels[user] = "Rejected"

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
evaluateUser(95, true)

---------------------------------------------------------

STEP 3:
Call:
levels(your_address)

EXPECTED:
"Elite Premium"

---------------------------------------------------------

STEP 4:
Call:
evaluateUser(60, false)

EXPECTED:
"Standard"

---------------------------------------------------------

STEP 5:
Call:
evaluateUser(20, true)

EXPECTED:
"Rejected"

---------------------------------------------------------

STEP 6:
Call:
ownerBonus(your_address)

FROM:
owner account

---------------------------------------------------------

STEP 7:
Call:
scores(your_address)

OBSERVE:
Bonus added if conditions met

=========================================================
IMPORTANT BRANCHING UNDERSTANDING
=========================================================

Nested if statements create:
multiple execution paths.

---------------------------------------------------------

Every branch may:
- modify state differently
- skip logic
- create vulnerabilities

=========================================================
EXECUTION TREE
=========================================================

Example:

IF score >= 50
    |
    +-- premium?
          |
          +-- elite?
          |
          +-- standard

---------------------------------------------------------

Auditors mentally trace:
ALL branches.

=========================================================
WHY NESTED LOGIC IS DANGEROUS
=========================================================

Complex branching may cause:

- forgotten edge cases
- inconsistent updates
- bypass conditions
- privilege escalation

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. MISSING ELSE BRANCH
---------------------------------------------------------

State may remain unchanged unexpectedly.

---------------------------------------------------------
2. UNREACHABLE CODE
---------------------------------------------------------

Incorrect condition order
may block execution paths.

---------------------------------------------------------
3. INCONSISTENT STATE
---------------------------------------------------------

Different branches may:
update state differently.

---------------------------------------------------------
4. PRIVILEGE ESCALATION
---------------------------------------------------------

Incorrect nested checks
may bypass authorization.

=========================================================
GAS OBSERVATION
=========================================================

More branching:
More execution complexity.

---------------------------------------------------------

Deeper nesting:
Harder auditing.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can attacker reach hidden branch?
- Are all paths validated?
- Does every path maintain invariants?
- Are branches mutually exclusive?
- Is state updated consistently?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer forgets else branch.

Attacker triggers unexpected path.

Result:
stale or corrupted state.

---------------------------------------------------------

ANOTHER RISK

Incorrect nested access-control logic
may allow unauthorized execution.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Every condition
2. Every branch
3. Every state update
4. Every revert path
5. Every skipped operation

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add blacklist logic
2. Add VIP user branch
3. Add paused-contract branch

Then manually trace:
ALL execution paths.

BONUS:
Convert nested ifs into:
require() + early returns.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Nested if creates multiple execution paths
- Branching changes execution flow
- Auditors must trace every branch
- Missing branches create vulnerabilities
- Complex logic increases audit difficulty
- State updates differ across branches
- Incorrect nesting may bypass checks
- Edge cases matter heavily
- Branch analysis is critical in auditing
- Execution tracing is essential for security reviews

=========================================================
*/



/*
Audit Report

Title:
Complex Nested Branching Logic in evaluateUser()

Severity:
Low

Reason:
Deep nested if conditions increase execution complexity and make auditing more difficult.

Location:
Contract: NestedIfConditions
Function: evaluateUser()

Vulnerability Description:
The evaluateUser() function uses multiple nested if conditions for handling user levels.
Although the logic works correctly, deep nesting creates multiple execution branches that are harder to audit and maintain.

Complex branching may cause:
hidden edge cases
inconsistent state updates
forgotten else branches
logic mistakes in future upgrades

Impact:
In larger production contracts, deeply nested logic may:
increase audit difficulty
introduce hidden vulnerabilities
create inconsistent protocol behavior
increase maintenance complexity

Proof of Concept:
Call:
evaluateUser(95, true)

Execution path:
score >= 50
premium == true
score >= 90

Final result:
levels[user] = "Elite Premium"

Call:
evaluateUser(20, true)
Execution path:
score >= 50 → false

Final result:
levels[user] = "Rejected"
Different inputs create completely different execution paths.

Root Cause:
The contract relies heavily on nested branching instead of simpler validation and early-return logic.

Recommendation:
e nested branching complexity using:
require()
early returns
smaller helper functions

Add:
blacklist logic
paused contract logic
score validation
for stronger security.
*/



//Patched Code:

contract NestedIfConditions {

    address public owner;

    bool public paused;

    mapping(address => bool) public blacklisted;

    mapping(address => uint256) public scores;

    mapping(address => string) public levels;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract paused");
        _;
    }

    modifier notBlacklisted() {
        require(
            !blacklisted[msg.sender],
            "Blacklisted user"
        );
        _;
    }

    function pauseContract() external onlyOwner {
        paused = true;
    }

    function unpauseContract() external onlyOwner {
        paused = false;
    }

    function blacklistUser(
        address _user
    )
        external
        onlyOwner
    {
        blacklisted[_user] = true;
    }

    function evaluateUser(
        uint256 _score,
        bool _premium,
        bool _vip
    )
        external
        notPaused
        notBlacklisted
    {
        require(
            _score <= 100,
            "Invalid score"
        );

        if (_score < 50) {
            levels[msg.sender] = "Rejected";
            return;
        }

        if (_vip) {
            levels[msg.sender] = "VIP";
        }
        else if (_premium && _score >= 90) {
            levels[msg.sender] =
                "Elite Premium";
        }
        else if (_premium) {
            levels[msg.sender] =
                "Premium";
        }
        else {
            levels[msg.sender] =
                "Standard";
        }

        scores[msg.sender] = _score;
    }

    function ownerBonus(
        address _user
    )
        external
        onlyOwner
    {
        require(
            _user != address(0),
            "Invalid user"
        );

        require(
            scores[_user] > 0,
            "No score"
        );

        require(
            scores[_user] >= 80,
            "Low score"
        );

        scores[_user] += 20;
    }
}