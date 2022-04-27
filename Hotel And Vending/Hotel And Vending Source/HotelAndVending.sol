// SPDX-License-Identifier: MIT
pragma solidity >0.6.0;

/*
 * @title: Hotel and vending Solidity smart contract.
 * @author: Anthony (fps) https://github.com/fps8k .
 * @dev: 
*/

contract HAV
{
    event Book(address, bytes32);
    event BookFor(address, address, bytes32);
    event Unlock(address, address, uint256);
    event Lock(address, address, uint256);
    event Approve(address, address, bool);
    event Revoke(address, address, bool);
    event Leave(address, uint256);


    // Room attributes. Assuming that there are infinite rooms in the hotel all capped at 50,000 gwei flat.

    struct Rooms
    {
        address occupant;
        uint256 price;
        bytes32 key;
        bool door_open;
    }


    // Mappings.

    mapping(address => Rooms) private guests;                           // Maps each user to a room.
    mapping(address => mapping(address => bool)) private approvals;     // Allows one to allow a person or some people ability to their rooms.


    // Modifiers and control functions.

    modifier isValidSender()
    {
        require(msg.sender != address(0), "! Address");
        _;
    }


    /*
    * @dev:
    *
    * Makes sure the `_address` has a room already in the hotel.
    */

    function hasRoom(address _address) private view returns(bool)
    {
        return guests[_address].occupant != address(0);

        // Returns true if the address has a room.
    }


    /*
    * @dev:
    *
    * Checks if `_address` is allowed to access a room.
    */

    function isAllowed(address _address) private view returns(bool)
    {
        address owner = guests[_address].occupant;
        return ((msg.sender == owner) || (approvals[_address][msg.sender]));

        // Returns true if the `msg.sender` is the owner of the room -- OR -- the `msg.sender` is approved by the `_address`.
    }
    



    /*
    * @dev:
    *
    * Grants `msg.sender` access to a room and he sets his password.
    * 
    */

    function book(string memory _password) public payable isValidSender
    {
        require(!hasRoom(msg.sender), "You have a room.");                  // Makes sure the `msg.sender` has no room at the moment.
        require(bytes(_password).length != 0, "Password length == 0");
        require(msg.value >= 50_000 gwei, "Price >= 50,000 gwei");

        bytes32 password = keccak256(bytes(_password));

        Rooms memory room = Rooms(
            msg.sender,
            msg.value,
            password,
            false
        );

        guests[msg.sender] = room;

        emit Book(msg.sender, password);
    }




    /*
    * @dev:
    *
    * Grants `msg.sender` access to book a room for `_address` and he sets his password.
    * 
    */

    function bookFor(address _address, string memory _password) public payable isValidSender
    {
        require(_address != address(0), "! For Address");
        require(!hasRoom(_address), "You have a room.");                  // Makes sure the `msg.sender` has no room at the moment.
        require(bytes(_password).length != 0, "Password length == 0");
        require(msg.value >= 50_000 gwei, "Price >= 50,000 gwei");

        bytes32 password = keccak256(bytes(_password));

        Rooms memory room = Rooms(
            _address,
            msg.value,
            password,
            false
        );

        guests[_address] = room;

        emit BookFor(msg.sender, _address, password);
    }




    /*
    * @dev:
    *
    * Unlocks your door.
    * `msg.sender` must be approved or own the room.
    */

    function unlock(address _address, string memory _key) public isValidSender          // `_address` is the address of the room you want to access.
    {
        require(hasRoom(_address), "! Booked");
        require(isAllowed(_address), "! Permitted");                                    // `_address` has allowed the `msg.sender` to unlock.
        require(bytes(_key).length != 0, "Password length == 0");
        bytes32 test_password = keccak256(bytes(_key));

        require(test_password == guests[_address].key, "! Password");                   // Tests for the key and password.

        uint256 unlock_time = block.timestamp;

        guests[_address].door_open = true;

        emit Unlock(msg.sender, _address, unlock_time);
    }




    /*
    * @dev:
    *
    * Locks your door.
    * `msg.sender` must be approved or own the room.
    */

    function lock(address _address) public isValidSender          // `_address` is the address of the room you want to access.
    {
        require(hasRoom(_address), "! Booked");
        require(isAllowed(_address), "! Permitted");

        uint256 lock_time = block.timestamp;

        guests[_address].door_open = false;

        emit Lock(msg.sender, _address, lock_time);
    }




    /*
    * @dev: 
    * 
    * Approves `address` to access `msg.sender`'s room.
    */

    function approve(address _address) public isValidSender
    {
        require(hasRoom(msg.sender), "! Room.");                  // Makes sure the `msg.sender` has a room at the moment.   
        require(_address != address(0), "! Address");

        require(!approvals[msg.sender][_address], "Already approved");

        approvals[msg.sender][_address] = true;

        emit Approve(msg.sender, _address, true);
    }




    /*
    * @dev: 
    * 
    * Revokes `address` to access `msg.sender`'s room.
    */

    function revoke(address _address) public isValidSender
    {
        require(hasRoom(msg.sender), "! Room.");                  // Makes sure the `msg.sender` has a room at the moment.   
        require(_address != address(0), "! Address");

        require(approvals[msg.sender][_address], "Already revoked");

        approvals[msg.sender][_address] = false;

        emit Revoke(msg.sender, _address, false);
    }




    /*
    * @dev:
    *
    * Leave, says bye to the hotel.
    */

    function leave(address _address) public isValidSender
    {
        require(hasRoom(msg.sender), "! Room.");                  // Makes sure the `msg.sender` has no room at the moment.
        require(msg.sender == guests[_address].occupant, "! Owned");
        
        uint256 left = block.timestamp;
        delete guests[msg.sender];

        emit Leave(msg.sender, left);
    }




    /*
    * @dev:
    *
    * Sees the owner of the room
    */

    function viewOwner(address _address) public view isValidSender returns(address)
    {
        require(_address != address(0), "! Address");
        require(hasRoom(_address), "! Room.");                  // Makes sure the `msg.sender` has no room at the moment.
        
        return guests[_address].occupant;
    }

}