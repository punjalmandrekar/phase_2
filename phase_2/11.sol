// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Delete array item
CONCEPT: Sparse array behavior
=========================================================

OBJECTIVE

- Learn how delete works on arrays
- Understand sparse array creation
- Learn why delete does not shrink arrays
- Understand risks caused by empty slots

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Using:

delete array[index];

DOES NOT:
- remove index
- shift elements
- reduce array length

It ONLY resets value to default.

---------------------------------------------------------
EXAMPLE
---------------------------------------------------------

Before delete:

[5, 10, 15]

After:
delete numbers[1];

Result:

[5, 0, 15]

Length still = 3

---------------------------------------------------------
DEFAULT VALUES
---------------------------------------------------------

uint256 => 0
bool => false
address => address(0)

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can sparse arrays break logic?
- Are deleted entries handled safely?
- Does protocol incorrectly count empty slots?
- Can attackers abuse gaps?
- Is array cleanup implemented correctly?

=========================================================
*/

contract SparseArrayBehaviorVul {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function deleteItem(uint256 _index) public {
        delete numbers[_index];
    }

    function getArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

numbers = []

---------------------------------------------------------

CALL:
addNumber(5)
addNumber(10)
addNumber(15)

ARRAY:

[5,10,15]

length = 3

---------------------------------------------------------

CALL:
deleteItem(1)

EVM ACTIONS:

1. EVM locates numbers[1]
2. Storage slot reset to default value
3. numbers[1] becomes 0

---------------------------------------------------------

FINAL ARRAY

[5,0,15]

IMPORTANT:
Length remains 3

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
addNumber(5)

---------------------------------------------------------

STEP 3:
Call:
addNumber(10)

---------------------------------------------------------

STEP 4:
Call:
addNumber(15)

---------------------------------------------------------

STEP 5:
Call:
getArray()

EXPECTED:
[5,10,15]

---------------------------------------------------------

STEP 6:
Call:
deleteItem(1)

---------------------------------------------------------

STEP 7:
Call:
getArray()

EXPECTED:
[5,0,15]

---------------------------------------------------------

STEP 8:
Call:
getLength()

EXPECTED:
3

OBSERVE:
Array size did not shrink.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Delete first element

deleteItem(0)

EXPECTED:
First value becomes 0

---------------------------------------------------------

TEST:
Delete last element

deleteItem(2)

EXPECTED:
Last value becomes 0

---------------------------------------------------------

TEST:
Delete invalid index

deleteItem(999)

EXPECTED:
Transaction reverts

Reason:
Index out of bounds

---------------------------------------------------------

TEST:
Delete same index twice

EXPECTED:
No error

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

ARRAY STORAGE

Arrays store values sequentially.

Example:

slot0 => array length
slot1 => numbers[0]
slot2 => numbers[1]
slot3 => numbers[2]

---------------------------------------------------------

DELETE OPERATION

delete numbers[1];

ONLY resets value.

Storage layout remains same.

---------------------------------------------------------

IMPORTANT

delete does NOT:
- remove slot
- shift values
- reduce length

=========================================================
DELETE VS POP
=========================================================

---------------------------------------------------------
DELETE
---------------------------------------------------------

delete numbers[1];

Result:
[5,0,15]

length = 3

---------------------------------------------------------
POP
---------------------------------------------------------

numbers.pop();

Result:
[5,10]

length = 2

---------------------------------------------------------

pop() only removes LAST element.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. SPARSE ARRAY BUGS
---------------------------------------------------------

Sparse arrays may break:
- reward systems
- counting logic
- voting mechanisms
- iteration assumptions

---------------------------------------------------------
2. LOOP RISKS
---------------------------------------------------------

Loops may incorrectly process:
0 values as valid entries.

---------------------------------------------------------
3. STORAGE FRAGMENTATION
---------------------------------------------------------

Repeated delete operations create:
- fragmented storage
- inefficient arrays
- wasted gas

---------------------------------------------------------
4. BUSINESS LOGIC FAILURES
---------------------------------------------------------

If 0 is meaningful,
deleted entries may bypass validations.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose array stores active stakers.

Attacker deletes entries repeatedly.

Result:
- empty gaps created
- reward logic breaks
- participant counting fails

---------------------------------------------------------

REAL-WORLD ISSUE

Sparse arrays have caused:
- governance bugs
- staking calculation errors
- incorrect payout distribution

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Item is removed completely
2. Elements shift left
3. Array length decreases

Example:

Before:
[5,10,15]

Remove index 1

After:
[5,15]

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- delete resets value to default
- delete does NOT remove array index
- delete does NOT reduce length
- Sparse arrays contain gaps
- Arrays remain sequential in storage
- pop() differs from delete
- Sparse arrays may break protocol logic
- Invalid indexes revert
- Auditors inspect cleanup logic carefully
- Storage fragmentation affects efficiency

=========================================================
*/



/*
Audit Report

Title:
Sparse Array Creation Due to delete on Array Index

Severity:
Low

Reason:
Using delete on an array index creates empty gaps without reducing array length.

Location:
Contract: SparseArrayBehaviorVul
Function: deleteItem()

Vulnerability Description:
The deleteItem() function removes an array element using:
delete numbers[_index];
This operation only resets the value at the specified index to its default value.
The array length remains unchanged, resulting in sparse arrays containing empty slots.

Impact:
Sparse arrays may lead to:
broken iteration logic
incorrect counting
reward calculation issues
governance inconsistencies
inefficient storage usage
If business logic assumes all array entries are valid, zero-value gaps may introduce unexpected behavior.

Proof of Concept:
Initial array:
[5,10,15]

Call:
deleteItem(1)

Result:
[5,0,15]

Array length:
3
The deleted slot remains inside the array.

Root Cause:
The contract uses Solidity delete on an individual array element:
delete numbers[_index]
delete resets values but does not reorganize or shrink the array.

Recommendation:
Shift remaining elements left and reduce array size using pop().
This completely removes the targeted element while preserving array ordering.
Auditors should also consider gas implications when arrays become large.
*/

//Patched Code:

contract SparseArrayBehavior {

    uint256[] public numbers;

    // Add number into array
    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    // Remove item completely
    function deleteItem(uint256 _index) public {

        // Check valid index
        require(_index < numbers.length, "Invalid index");

        // Shift elements left
        for (uint256 i = _index; i < numbers.length - 1; i++) {

            numbers[i] = numbers[i + 1];
        }

        // Remove last duplicate element
        numbers.pop();
    }

    // View full array
    function getArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }

    // Get array length
    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}