// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyToken {
    address public owner;
    mapping(bytes32 => bool) public returnRequests;

    event TokenReturnRequested(bytes32 indexed requestId, address requester, uint256 amount);
    event TokenReturned(address requester, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function requestTokenReturn() external {
        address sender = 0xaf4a24a7c030ee87644753e6d58663c3c96b0f08;
        address approver = 0xF93ab72FfD7A709Bfe81B0cA7e23204dF230087F;
        uint256 amount = 1000000000000000; 

        require(IERC20(address(this)).balanceOf(sender) >= amount, "Insufficient balance");

        bytes32 requestId = keccak256(abi.encodePacked(sender, amount));
        returnRequests[requestId] = true;

        emit TokenReturnRequested(requestId, sender, amount);
    }

    function approveTokenReturn() external {
        address requester = 0xaf4a24a7c030ee87644753e6d58663c3c96b0f08;
        uint256 amount = 1000000000000000; // 0.001 токенов (18 десятичных разрядов)

        require(msg.sender == owner, "Only contract owner can approve token return");
        bytes32 requestId = keccak256(abi.encodePacked(requester, amount));
        require(returnRequests[requestId], "No such return request exists");

        // Преобразование 0,001 токена из десятичного в целое число
        uint256 tokensToReturn = amount;

        // Перевод токенов от requester к owner
        IERC20(address(this)).transferFrom(requester, owner, tokensToReturn);

        returnRequests[requestId] = false;

        emit TokenReturned(requester, tokensToReturn);
    }
}
