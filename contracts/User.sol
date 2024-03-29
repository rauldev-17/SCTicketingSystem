// SPDX-License-Identifier: MIT

import "./access/AccessControl.sol";
import 'hardhat/console.sol';

pragma solidity ^0.8.0;

contract User is AccessControl {
    struct UserInfo {
        bytes32 name;
        uint8 age;
        bytes32 email;
        string phone;
        string photo;
        string voiceId;
        string faceId;
        bool registered;
    }

    struct PromoterInfo {
        bytes32 name;
        bytes32 email;
        string phone;
        string website;
        string voiceId;
        string faceId;
        bool registered;
    }

    mapping(address => UserInfo) users;
    mapping(address => PromoterInfo) promoters;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor () {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function addUser(bytes32 name, uint8 age, bytes32 email, string memory phone, string memory photo,
        string memory voiceId, string memory faceId) public {
        require(!users[msg.sender].registered, "User already registered");

        users[msg.sender].name = name;
        users[msg.sender].age = age;
        users[msg.sender].email = email;
        users[msg.sender].phone = phone;
        users[msg.sender].photo = photo;
        users[msg.sender].voiceId = voiceId;
        users[msg.sender].faceId = faceId;
        users[msg.sender].registered = true;
    }

    function addPromoter(address promoter, bytes32 name, bytes32 email, string memory phone, string memory website,
        string memory voiceId, string memory faceId) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not admin");
        require(promoter != address(0x0), "Invalid user address");
        require(!promoters[promoter].registered, "Promoter already registered");

        promoters[promoter].name = name;
        promoters[promoter].email = email;
        promoters[promoter].phone = phone;
        promoters[promoter].website = website;
        promoters[promoter].voiceId = voiceId;
        promoters[promoter].faceId = faceId;
        promoters[promoter].registered = true;
    }

    function userExists(address user) external view returns (bool) {
        require(user != address(0x0), "Invalid user address");

        return users[user].registered;
    }

    function promoterExists(address user) external view returns (bool) {
        require(user != address(0x0), "Invalid user address");

        return promoters[user].registered;
    }

    function login(uint8 userType, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 hash) external view 
        returns (bool) {
        address user = _checkSignature(sigV, sigR, sigS, hash);
        require(user == msg.sender, "Login forbidden");

        if (userType == 1) {
            return users[user].registered;
        } else {
            return promoters[user].registered;
        }
    }

    function _checkSignature(uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 hashedMessage) internal pure 
        returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));
        address accountAddress = ecrecover(prefixedHashMessage, sigV, sigR, sigS);
        require(accountAddress != address(0x0));

        return accountAddress;
    }
}