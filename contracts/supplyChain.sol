 

pragma solidity ^0.8.0;

contract SupplyChain {
    struct Event {
        string eventType;
        uint256 timestamp;
        string location;
        address participant;
    }

    struct Product {
        string name;
        string description;
        uint256 productId;
        address currentOwner;
        string status;
        string location;
        uint256 timestamp;
        uint256 eventCount;
    //    mapping(uint256 => Event) events;
    }
    mapping(uint256 => Event[])  events;
    mapping(uint256 => Product) public products;
    uint256 public productCount;

    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isParticipant;

    event ProductCreated(uint256 productId, string name, string description);
    event ProductTransferred(uint256 productId, address previousOwner, address newOwner, string status, string location);
    event EventAdded(uint256 productId, string eventType, uint256 timestamp, string location, address participant);

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Only admins can perform this action");
        _;
    }

    modifier onlyParticipant() {
        require(isParticipant[msg.sender], "Only participants can perform this action");
        _;
    }

    constructor(address[] memory _admins) {
        for (uint256 i = 0; i < _admins.length; i++) {
            isAdmin[_admins[i]] = true;
        }
    }

    function addParticipant(address _participant) public onlyAdmin {
        isParticipant[_participant] = true;
    }
     
    function getParticipant(address _participant) public view onlyAdmin returns (bool) {
        return isParticipant[_participant];
}


    function createProduct(string memory _name, string memory _description) public onlyAdmin {
        productCount++;
        products[productCount] = Product(_name, _description, productCount, msg.sender, "Created", "", block.timestamp, 0);
        emit ProductCreated(productCount, _name, _description);
    }

    function transferOwnership(uint256 _productId, address _newOwner, string memory _status, string memory _location) public onlyParticipant {
        Product storage product = products[_productId];
        require(msg.sender == product.currentOwner, "Only the current owner can transfer ownership");

        product.currentOwner = _newOwner;
        product.status = _status;
        product.location = _location;
        product.timestamp = block.timestamp;

        emit ProductTransferred(_productId, msg.sender, _newOwner, _status, _location);
        emit EventAdded(_productId, "Transfer", block.timestamp, _location, _newOwner);
    }

    function addEvent(uint256 _productId, string memory _eventType, string memory _location) public onlyParticipant {
        Product storage product = products[_productId];
        require(product.currentOwner != address(0), "Product does not exist");
        Event memory newEvent =  Event(_eventType, block.timestamp, _location, msg.sender);

    //     uint256 eventIndex = product.eventCount + 1;
    //      Event memory newEvent = Event({
    //     eventType: eventType,
    //     timestamp: block.timestamp,
    //     location: location,
    //     participant: msg.sender
    // });

        events[_productId].push(newEvent);
    //    events[eventIndex] =events[eventIndex].push(Event(_eventType, block.timestamp, _location, msg.sender));
        product.eventCount = product.eventCount +1;

        emit EventAdded(_productId, _eventType, block.timestamp, _location, msg.sender);
    }

    function getProduct(uint256 _productId) public view returns (string memory, string memory, uint256, address, string memory, string memory, uint256 ) {
        Product memory product = products[_productId];
        return (product.name, product.description, product.productId, product.currentOwner, product.status, product.location, product.timestamp);
    }
     function getEventzz(uint256 _productId) public view returns (string memory, string memory, uint256, address, string memory, string memory, uint256 ) {
        Product memory product = products[_productId];
        return (product.name, product.description, product.productId, product.currentOwner, product.status, product.location, product.timestamp);
    }
 
    function getProductEvent(uint256 productId, uint256 eventId) public view returns (Event memory) {
    require(productId > 0 && productId <= productCount, "Product does not exist");
    require(eventId > 0 && eventId <= events[productId].length, "Event does not exist");
    return events[productId][eventId - 1];
}
function getProductEvents(uint256 productId) public view returns (Event[] memory) {
    require(productId > 0 && productId <= productCount, "Product does not exist");
    return events[productId];
}

}
