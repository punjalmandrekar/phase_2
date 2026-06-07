// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use calldata in external function
CONCEPT: External optimization
=========================================================

OBJECTIVE

- Learn why calldata is used in external functions
- Understand gas optimization using calldata
- Learn efficient external input handling
- Understand calldata vs memory behavior

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

External functions receive input data
through calldata.

Using calldata:
- avoids unnecessary copying
- reduces gas cost
- improves efficiency

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

For external functions:

calldata is usually better than memory
for read-only inputs.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Gas optimization is critical in:

- DeFi protocols
- NFT marketplaces
- routers
- multicall systems
- governance contracts

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Calldata heavily used in:

- Uniswap routers
- token batch transfers
- governance voting
- multicall contracts
- staking systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is calldata used where appropriate?
- Are unnecessary memory copies created?
- Are loops scalable?
- Can attacker-controlled inputs create DOS?
- Is gas usage optimized?

=========================================================
*/

contract ExternalCalldataOptimizationVul {

    /*
        STORAGE ARRAY

        Permanent blockchain state.
    */
    uint256[] public savedNumbers;

    /*
    =====================================================
    EXTERNAL + CALLDATA
    =====================================================

    MOST GAS-EFFICIENT
    for read-only external arrays.
    */

    function calculateSum(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {

        uint256 total = 0;

        /*
            READ DIRECTLY FROM CALLDATA

            No memory copy created.
        */
        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }

    /*
    =====================================================
    SAVE VALUES TO STORAGE
    =====================================================
    */

    function saveValues(
        uint256[] calldata _numbers
    )
        external
    {

        /*
            Read calldata efficiently,
            then store permanently.
        */
        for (uint256 i = 0; i < _numbers.length; i++) {

            savedNumbers.push(_numbers[i]);
        }
    }

    /*
    =====================================================
    STRING CALLDATA EXAMPLE
    =====================================================
    */

    function echoMessage(
        string calldata _message
    )
        external
        pure
        returns (string memory)
    {

        /*
            Dynamic external input
            stored in calldata.
        */
        return _message;
    }

    /*
    =====================================================
    MEMORY VERSION (LESS OPTIMIZED)
    =====================================================
    */

    function calculateSumMemory(
        uint256[] memory _numbers
    )
        public
        pure
        returns (uint256)
    {

        uint256 total = 0;

        /*
            Memory array requires copying.
        */
        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
calculateSum([1,2,3])

EVM ACTIONS:

1. Array arrives in calldata
2. Function reads directly from calldata
3. No memory copy created
4. Loop processes values
5. Result returned
6. Calldata discarded after execution

---------------------------------------------------------

RESULT:
6

---------------------------------------------------------

GAS:
Efficient

=========================================================

CALL:
calculateSumMemory([1,2,3])

EVM ACTIONS:

1. Array copied into memory
2. Memory allocation occurs
3. Loop processes memory array
4. Result returned

---------------------------------------------------------

GAS:
More expensive than calldata version

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
calculateSum([1,2,3])

EXPECTED:
6

---------------------------------------------------------

STEP 3:
Call:
calculateSumMemory([1,2,3])

EXPECTED:
6

---------------------------------------------------------

STEP 4:
Compare gas usage

OBSERVE:
calldata version cheaper

---------------------------------------------------------

STEP 5:
Call:
echoMessage("Blockchain")

EXPECTED:
"Blockchain"

---------------------------------------------------------

STEP 6:
Call:
saveValues([10,20])

---------------------------------------------------------

STEP 7:
Call:
savedNumbers(0)

EXPECTED:
10

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Pass empty array

EXPECTED:
0

---------------------------------------------------------

TEST:
Pass huge array

OBSERVE:
Higher gas consumption

---------------------------------------------------------

TEST:
Pass large string

OBSERVE:
Dynamic calldata still costs gas

=========================================================
IMPORTANT CALLDATA UNDERSTANDING
=========================================================

CALLDATA:
- temporary
- read-only
- external-input optimized

---------------------------------------------------------

BEST USED FOR:
Read-only external parameters.

=========================================================
WHY EXTERNAL + CALLDATA IS OPTIMAL
=========================================================

EXTERNAL FUNCTION:
Reads directly from calldata.

---------------------------------------------------------

NO MEMORY COPY NEEDED.

---------------------------------------------------------

RESULT:
Lower gas usage.

=========================================================
CALLDATA RESTRICTION
=========================================================

CALLDATA CANNOT BE MODIFIED.

---------------------------------------------------------

THIS FAILS:

_numbers[0] = 999;

---------------------------------------------------------

Reason:
calldata is immutable.

=========================================================
CALLDATA VS MEMORY
=========================================================

---------------------------------------------------------
CALLDATA
---------------------------------------------------------

Read-only

Cheaper

No copying

Best for external input

---------------------------------------------------------
MEMORY
---------------------------------------------------------

Mutable

Requires allocation

More expensive

Useful for modifications

=========================================================
GAS OBSERVATION
=========================================================

CALLDATA:
Lower gas usage

---------------------------------------------------------

MEMORY:
Higher gas usage due to:
- copying
- allocation
- expansion

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. GAS OPTIMIZATION
---------------------------------------------------------

Auditors check:
whether calldata can replace memory.

---------------------------------------------------------
2. DOS VIA LARGE ARRAYS
---------------------------------------------------------

Huge attacker-controlled arrays
may exhaust gas.

---------------------------------------------------------
3. UNBOUNDED LOOPS
---------------------------------------------------------

Loops over calldata arrays
must be bounded safely.

---------------------------------------------------------
4. MUTABILITY CONFUSION
---------------------------------------------------------

Developers must understand:
calldata is immutable.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker submits massive calldata array.

Loop processing becomes too expensive.

Result:
- DOS condition
- transaction failure

---------------------------------------------------------

ANOTHER RISK

Developer unnecessarily copies:
calldata -> memory

Result:
wasted gas and poor scalability.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Accept calldata string array
2. Count total characters
3. Add max input limit

BONUS:
Measure gas:
calldata vs memory for large arrays

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- External functions naturally use calldata
- Calldata is gas efficient
- Calldata avoids memory copying
- Calldata is read-only
- Memory is mutable but expensive
- Large arrays increase gas usage
- Unbounded loops create DOS risks
- Gas optimization matters heavily
- External input is attacker-controlled
- Auditors inspect calldata efficiency carefully

=========================================================
*/


/*
Audit Report

Title:
Unbounded External Calldata Array Loop Can Cause Gas Exhaustion

Severity:
Medium

Reason:
The contract processes attacker-controlled calldata arrays inside loops without strict input limits. Large arrays may consume excessive gas and create DOS conditions.

Location:
Contract: ExternalCalldataOptimization

Functions:
calculateSum()
saveValues()
calculateSumMemory()

Vulnerability Description:
The contract accepts external calldata and memory arrays:
uint256[] calldata _numbers
and
uint256[] memory _numbers
The functions iterate through all array elements:
for (uint256 i = 0; i < _numbers.length; i++)
Because array size is fully controlled by users, attackers may supply extremely large arrays.
Although calldata is more gas efficient than memory, loop execution still scales linearly with input size.
The memory version is even more expensive because the array must first be copied into memory.

Impact:
Large attacker-controlled arrays may cause:
excessive gas consumption
out-of-gas failures
denial of service conditions
failed transactions
scalability issues

If similar logic exists in:
DeFi routers
governance protocols
multicall systems
NFT batch operations
staking contracts
critical protocol functionality may become too expensive or unusable.

Proof of Concept:
Deploy the contract.
Call:
calculateSum([1,2,3])

Result:
6
Now call with a massive array.

OBSERVE:
gas usage increases significantly
execution becomes expensive
transaction may revert due to out-of-gas

The same issue affects:
saveValues()
and:
calculateSumMemory()

Root Cause:
The contract uses unbounded loops on attacker-controlled input:
for (uint256 i = 0; i < _numbers.length; i++)
No maximum input length validation exists before processing arrays.

Recommendation:
Add maximum array size validation before looping.

Example:
require(
    _numbers.length <= 100,
    "Array too large"
);

For scalable systems, consider:
batching
pagination
chunk processing
gas-safe execution limits

Auditors should inspect:
loop scalability
calldata efficiency
DOS resistance
unnecessary memory copying
attacker-controlled input handling
*/

//Patched Code:

contract ExternalCalldataOptimization {

    uint256[] public savedNumbers;

    function calculateSum(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {

        require(
            _numbers.length <= 100,
            "Array too large"
        );

        uint256 total = 0;

        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }

    function saveValues(
        uint256[] calldata _numbers
    )
        external
    {

        require(
            _numbers.length <= 100,
            "Array too large"
        );

        for (uint256 i = 0; i < _numbers.length; i++) {

            savedNumbers.push(_numbers[i]);
        }
    }

    function echoMessage(
        string calldata _message
    )
        external
        pure
        returns (string memory)
    {

        return _message;
    }

    function calculateSumMemory(
        uint256[] memory _numbers
    )
        public
        pure
        returns (uint256)
    {

        require(
            _numbers.length <= 100,
            "Array too large"
        );

        uint256 total = 0;

        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }
}