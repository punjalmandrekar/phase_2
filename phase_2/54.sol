// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trigger fallback during call
CONCEPT: External execution
=========================================================

OBJECTIVE

- Learn how fallback() gets triggered
- Understand low-level external execution
- Learn unknown-function behavior
- Understand fallback attack surface

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

fallback() executes when:

1. unknown function called
OR
2. calldata does not match any function

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

fallback() is external execution.

---------------------------------------------------------

Control jumps into:
another contract unexpectedly.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

fallback() is heavily used in:

- proxies
- routers
- upgradeable contracts
- ETH receivers
- attack contracts
- low-level interactions

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Fallback logic appears in:

- proxy delegation
- DeFi routing
- reentrancy attacks
- ETH receiving
- upgrade patterns

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- fallback execution paths
- hidden external calls
- reentrancy behavior
- delegatecall risks
- gas usage

=========================================================
TARGET CONTRACT
=========================================================
*/

contract TargetContract {

    /*
        TRACK FALLBACK EXECUTION
    */
    uint256 public fallbackCounter;

    uint256 public receivedETH;

    /*
    =====================================================
    FALLBACK FUNCTION
    =====================================================

    Triggered when:
    - unknown function called
    - calldata unmatched
    */

    fallback()
        external
        payable
    {

        /*
            Track execution.
        */
        fallbackCounter++;

        /*
            Track ETH received.
        */
        receivedETH += msg.value;
    }

    /*
    =====================================================
    RECEIVE FUNCTION
    =====================================================

    Triggered when:
    ETH sent with EMPTY calldata.
    */

    receive()
        external
        payable
    {

        receivedETH += msg.value;
    }

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================
    */

    function normalFunction()
        external
        pure
        returns (string memory)
    {

        return "Normal execution";
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================
*/

contract FallbackCaller {

    /*
        STORE TARGET ADDRESS
    */
    address public target;

    /*
        LAST CALL STATUS
    */
    bool public lastSuccess;

    /*
        CONSTRUCTOR
    */
    constructor(address _target)
    {

        target = _target;
    }

    /*
    =====================================================
    CALL UNKNOWN FUNCTION
    =====================================================
    */

    function triggerFallback()
        external
    {

        /*
            LOW-LEVEL CALL

            Calling NON-EXISTENT function:
            "doesNotExist()"
        */
        (bool success, ) =
            target.call(
                abi.encodeWithSignature(
                    "doesNotExist()"
                )
            );

        /*
            Save result.
        */
        lastSuccess = success;
    }

    /*
    =====================================================
    SEND ETH + UNKNOWN CALLDATA
    =====================================================
    */

    function triggerFallbackWithETH()
        external
        payable
    {

        /*
            Sends:
            - ETH
            - invalid function calldata
        */
        (bool success, ) =
            target.call{
                value: msg.value
            }(
                abi.encodeWithSignature(
                    "fakeFunction()"
                )
            );

        lastSuccess = success;
    }

    /*
    =====================================================
    SEND PLAIN ETH
    =====================================================
    */

    function triggerReceive()
        external
        payable
    {

        /*
            Empty calldata.

            receive() executes.
        */
        (bool success, ) =
            target.call{
                value: msg.value
            }("");

        lastSuccess = success;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy TargetContract

---------------------------------------------------------

STEP 2:
Deploy FallbackCaller

Constructor input:
TargetContract address

=========================================================
TRACE:
triggerFallback()
=========================================================

STEP 1:
Caller contract executes.

---------------------------------------------------------

STEP 2:
Low-level call created:

target.call(
    abi.encodeWithSignature(
        "doesNotExist()"
    )
)

---------------------------------------------------------

STEP 3:
Execution jumps into:
TargetContract

---------------------------------------------------------

EVM searches for:

doesNotExist()

---------------------------------------------------------

RESULT:
Function NOT FOUND

---------------------------------------------------------

STEP 4:
fallback() automatically executes.

=========================================================
INSIDE fallback()
=========================================================

fallbackCounter++

---------------------------------------------------------

NEW VALUE:
1

---------------------------------------------------------

receivedETH += msg.value

msg.value = 0

=========================================================
IMPORTANT FALLBACK UNDERSTANDING
=========================================================

fallback() executes when:
no matching function exists.

=========================================================
ETH + FALLBACK TRACE
=========================================================

CALL:
triggerFallbackWithETH()

VALUE:
1 ETH

=========================================================

STEP 1:
ETH + invalid calldata sent.

---------------------------------------------------------

STEP 2:
No matching function found.

---------------------------------------------------------

STEP 3:
fallback() executes.

---------------------------------------------------------

fallbackCounter++

---------------------------------------------------------

receivedETH += 1 ETH

=========================================================
RECEIVE TRACE
=========================================================

CALL:
triggerReceive()

VALUE:
1 ETH

=========================================================

STEP 1:
ETH sent with EMPTY calldata.

---------------------------------------------------------

STEP 2:
receive() executes.

---------------------------------------------------------

receivedETH += 1 ETH

=========================================================
IMPORTANT DIFFERENCE
=========================================================

---------------------------------------------------------
receive()
---------------------------------------------------------

Triggered when:
- ETH sent
- calldata EMPTY

---------------------------------------------------------
fallback()
---------------------------------------------------------

Triggered when:
- unknown function called
- calldata unmatched

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy TargetContract

---------------------------------------------------------

STEP 2:
Deploy FallbackCaller

Input:
TargetContract address

---------------------------------------------------------

STEP 3:
Call:
triggerFallback()

---------------------------------------------------------

STEP 4:
Open TargetContract

---------------------------------------------------------

STEP 5:
Call:
fallbackCounter()

EXPECTED:
1

---------------------------------------------------------

STEP 6:
In VALUE field:
enter 1 ether

---------------------------------------------------------

STEP 7:
Call:
triggerFallbackWithETH()

---------------------------------------------------------

STEP 8:
Call:
receivedETH()

EXPECTED:
1 ETH in wei

---------------------------------------------------------

STEP 9:
Call:
triggerReceive()

with 1 ETH

---------------------------------------------------------

STEP 10:
Call:
receivedETH()

EXPECTED:
2 ETH total

=========================================================
IMPORTANT SECURITY UNDERSTANDING
=========================================================

fallback() enables:
unexpected external execution.

---------------------------------------------------------

Huge attack surface.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

fallback() may reenter vulnerable contract.

---------------------------------------------------------
2. PROXY RISKS
---------------------------------------------------------

fallback() commonly delegates execution.

---------------------------------------------------------
3. UNEXPECTED EXECUTION
---------------------------------------------------------

Unknown calls may trigger hidden logic.

---------------------------------------------------------
4. GAS DOS
---------------------------------------------------------

Complex fallback may exhaust gas.

=========================================================
VERY IMPORTANT ATTACK CONCEPT
=========================================================

Malicious contracts often attack using:

fallback()/receive()

---------------------------------------------------------

Because:
they trigger automatically during ETH transfer.

=========================================================
LOW-LEVEL CALL UNDERSTANDING
=========================================================

call() bypasses:
compile-time function checks.

---------------------------------------------------------

Meaning:
ANY calldata possible.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can fallback trigger unexpectedly?
- Can fallback reenter?
- Does fallback delegatecall?
- Is fallback payable?
- Are unknown calls handled safely?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Victim contract sends ETH.

---------------------------------------------------------

Attacker fallback executes automatically.

---------------------------------------------------------

Fallback reenters victim contract.

---------------------------------------------------------

Result:
fund theft.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External call flow
2. Fallback trigger conditions
3. Reentrancy windows
4. ETH transfer behavior
5. Unknown calldata handling

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add event inside fallback()
2. Add reentrant fallback attack
3. Add nonReentrant protection
4. Compare receive vs fallback execution

BONUS:
Build mini proxy fallback contract.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- fallback() handles unknown function calls
- receive() handles plain ETH transfers
- Low-level call() can trigger fallback
- fallback() creates external execution flow
- fallback() is major attack surface
- Reentrancy often uses fallback()
- call() bypasses compile-time safety
- Unknown calldata may trigger hidden logic
- Auditors inspect fallback paths carefully
- External execution is critical in Solidity security

=========================================================
*/


/*
Audit Report
Title
Unchecked Return Value of Low-Level Call

Severity:
Low

Category:
Error Handling / External Call Validation

Location:
Functions:
triggerFallback()
triggerFallbackWithETH()
triggerReceive()

Vulnerable Code:
(bool success, ) =
    target.call(
        abi.encodeWithSignature(
            "doesNotExist()"
        )
    );

lastSuccess = success;

and

(bool success, ) =
    target.call{
        value: msg.value
    }(
        abi.encodeWithSignature(
            "fakeFunction()"
        )
    );

lastSuccess = success;

and

(bool success, ) =
    target.call{
        value: msg.value
    }("");

lastSuccess = success;

Description:
The contract performs low-level calls and records the result in lastSuccess, but it does not enforce successful execution.
If the target contract reverts, the call returns:
success = false
The transaction itself continues successfully.
This can create situations where users assume an operation succeeded even though the target contract rejected the call.

Impact:
Potential impacts include:
Silent execution failures.
Incorrect assumptions by frontend systems.
Unexpected protocol behavior.
Reduced reliability of external integrations.
No direct loss of funds exists in the current implementation.

Proof of Concept:
Replace target contract with one that always reverts:

fallback() external payable {
    revert("Rejected");
}

Call:
triggerFallback()

Result:
success = false
lastSuccess = false
transaction does not revert
The failure is silently accepted.

Root Cause:
Low-level call failures are not enforced.

Example:
lastSuccess = success;

instead of:
require(
    success,
    "Call failed"
);

Recommendation:
Revert when external calls fail.
*/


//Patch Code

contract FallbackCallerPatched {

address public target;

bool public lastSuccess;

constructor(address _target)
{
    require(
        _target != address(0),
        "Zero address"
    );

    require(
        _target.code.length > 0,
        "Not a contract"
    );

    target = _target;
}

function triggerFallback()
    external
{
    (bool success, ) =
        target.call(
            abi.encodeWithSignature(
                "doesNotExist()"
            )
        );

    require(
        success,
        "External call failed"
    );

    lastSuccess = success;
}

function triggerFallbackWithETH()
    external
    payable
{
    (bool success, ) =
        target.call{
            value: msg.value
        }(
            abi.encodeWithSignature(
                "fakeFunction()"
            )
        );

    require(
        success,
        "External call failed"
    );

    lastSuccess = success;
}

function triggerReceive()
    external
    payable
{
    (bool success, ) =
        target.call{
            value: msg.value
        }("");

    require(
        success,
        "ETH transfer failed"
    );

    lastSuccess = success;
}

}
