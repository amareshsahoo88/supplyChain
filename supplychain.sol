// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {

    uint public productID;
    address public owner;

// This is the structure of the product and its details
    struct Product {
        uint id;
        string name;
        string description;
        address payable producer;
        address payable currentOwner;
        address[] ownerHistory;
        uint price;
    }

    // mapping for the product number to its mapping

    mapping(uint => Product) public products;

    event ProductCreated(uint id, string name, string description, address producer, uint price);
    event ProductSold(uint id, string name, address oldOwner, address newOwner);
    event FundsTransferred(uint id, address from, address to, uint amount);

// assigning msg.sender as the owner
    constructor() {
        owner = msg.sender;
    }

    // function for creating the product 

    function createProduct(string memory _name, string memory _description, uint _price) public {
    
    // incrementing the product id
        productID++;

    // creating the owner history array

        address[] memory history;

        history = new address[](0);

        products[productID] = Product(productID, _name, _description, payable(msg.sender), payable(msg.sender), history, _price);

        emit ProductCreated(productID, _name, _description, msg.sender, _price);
    }

    // function for buying the product

    function buyProduct(uint _productID) public payable {
    
    // fetching the product for updation
        
        Product storage product = products[_productID];

    // checking with the require statements if the input parameters meets the requirements

        require(msg.sender != product.currentOwner, "Current owner cannot buy their own product");
        require(msg.value == product.price, "Incorrect value transferred");

    // adding owner history to the waner history array
        product.ownerHistory.push(product.currentOwner);

    // making the current owner as the old owner
        address payable oldOwner = product.currentOwner;

    //transfering the money to the old owner
        oldOwner.transfer(msg.value);

    // updaing the current owner to the structure
        product.currentOwner = payable(msg.sender);

        emit ProductSold(product.id, product.name, oldOwner, product.currentOwner);
        emit FundsTransferred(product.id, oldOwner, product.currentOwner, msg.value);
    }

    // function to get owner history of the product bought and sold 
    function getOwnerHistory(uint _productID) public view returns (address[] memory) {
        Product memory product = products[_productID];
        return product.ownerHistory;
    }
}
