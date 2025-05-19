// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract nameRegistry{ // a contract to register names for respective addresses
   address user;   // takes user address
    mapping (address => string) names; // maps respective address to name inputted

//func to set the name of user
    function setName(string memory name) public {
        user = msg.sender;
        names[msg.sender] = name;
    }

//func to get the name of user
    function getName() public view returns(string memory){
        return names[msg.sender];
    }

//func to show the name of the user based on the address
    function showNameOf(address _user) public view  returns (string memory){
        return names[_user];
    }

}

contract nameRegistry2 is nameRegistry{ //update for the first contract

//new updatte to change the name already stored in the mapping
    function changeName (string memory newName) public {
        names[msg.sender] = newName;
    }
}

contract Proxy{ // contract for proxy used to delegate calls to the implementation logic above

// Unique storage slot for implementation address per EIP-1967 standard
    bytes32 private constant IMPLEMENTATION_SLOT =  bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

// Unique storage slot for admin address per EIP-1967 standard
    bytes32 private constant ADMIN_SLOT =  bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

//set the deployer of the contract as admin
    constructor(){
        setAdmin(msg.sender);
    }

//created a modifier to only allow the admin to perform certain functions
    modifier OnlyAdmin(){
        if(msg.sender == getAdmin()){
            _;
        }
        else{
            _fallback();
        }
    }

//returns the address of the admin
    function getAdmin() private view returns (address){
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

//sets the address of the admin
    function setAdmin(address _admin) private {
        require(_admin != address(0), "Invalid address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

//returns the address of the logic addres
    function getImpl() private view returns (address){
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

//sets the address of the logic address 
    function setImpl(address _impl) private {
        require(_impl.code.length > 0, "Address is not a contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _impl;
    }

//to change the current admin to a new admin
    function changeAdmin(address _admin) external OnlyAdmin{
     setAdmin(_admin);
    }

//to upgrade the logic address to the new updated address
    function updateImpl(address _impl) external OnlyAdmin{
        setImpl(_impl);
    }

//to get the value of the logic address
    function readImpl() external OnlyAdmin returns (address){
        return getImpl();
    }

//to get the value of the admin address
     function readAdmin() external OnlyAdmin returns (address){
        return getAdmin();
    }


// Delegates the current call to the implementation contract using delegatecall
    function _delegate(address _implementation) private  {
        assembly {
            
            calldatacopy(0, 0, calldatasize())

            let result :=
                delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            
            returndatacopy(0, 0, returndatasize())

            switch result
            
            case 0 {
              
                revert(0, returndatasize())
            }
            default {
               
                return(0, returndatasize())
            }
        }
    }


// Internal function to perform fallback by delegating call to implementation
    function _fallback() private   {
        _delegate(getImpl());
    }

// Fallback function to catch calls to non-existent functions and delegate them
    fallback() external payable { 
        _fallback();
    }
    
// Receive function to accept plain ether transfers and delegate the call
    receive() external payable {
        _fallback();
     }
}

contract ProxyAdmin { // ProxyAdmin contract manages upgrades and admin changes of Proxy contracts
    address public owner;

 // Set deployer as owner on deployment
    constructor(){
        owner = msg.sender;
    }

    // Restricts function access to only the owner
    modifier OnlyOwner(){
        require(msg.sender == owner, "You can't do this");
        _;
    }

    // Reads the admin address from a given proxy contract
    function getProxyAdmin(address proxy) external view returns (address){
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.readAdmin, ()));
        require(ok, "Execution failed");
        return abi.decode(res, (address));
    }

    // Reads the implementation address from a given proxy contract
     function getProxyImpl(address proxy) external view returns (address){
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.readImpl, ()));
        require(ok, "Execution failed");
        return abi.decode(res, (address));
    }

  // Changes the admin address of a given proxy contract; only callable by owner
     function changeProxyAdmin(address payable proxy, address admin) external OnlyOwner {
        Proxy(proxy).changeAdmin(admin);
     }

    // Changes the implementation address of a given proxy contract; only callable by owner
      function changeProxyImpl(address payable proxy, address impl) external OnlyOwner {
        Proxy(proxy).updateImpl(impl);
     }
}

library StorageSlot { // Library to read/write primitive types to specific storage slots safely

    // Struct for storing an address in a particular storage slot
    struct AddressSlot {
        address value;
    }

    // Returns an AddressSlot pointing to `slot` in storage
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r){
        assembly {
            r.slot := slot
        }
    } 
}