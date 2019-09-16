pragma solidity ^0.5.0;

//Slight Modification to run in Remix
//Source: http://solidity.readthedocs.io/en/v0.3.2/solidity-by-example.html#safe-remote-purchase

contract purtest {
    
    enum State { Purchase, Confirm, Adbot, Finish }
    
    struct Product {
        string name;
    }

    struct Seller {
        address account;
        uint[] paymentArray;
        uint[] products;
    }
    struct Buyer {
        address account;
        uint[] paymentArray;
    }
    struct Payment {
        uint paymentId;
        uint price;
        address payable seller_payment;
        address payable buyer_payment;
        State state;
    }

    mapping(address => Buyer) buyerlist;
    mapping(address => Seller) sellerlist;
    mapping(uint => Payment) paylist;
    mapping(uint => Product) productlist;
    
    uint price = 0;
    address payable seller;
    uint public seq = 0;
    uint public producSeq = 0;
    
    constructor() public payable{
        seller = msg.sender;
    }
    
    
    function _purchase_product() public payable {
        require(msg.value == msg.value);
        buyerlist[msg.sender].paymentArray.push(seq);
        buyerlist[msg.sender].paymentArray.push(seq);
        paylist[seq].paymentId = seq;
        paylist[seq].price = msg.value;
        paylist[seq].seller_payment = seller;
        paylist[seq].buyer_payment = msg.sender;
        paylist[seq].state = State.Purchase;
        seq++;
    }
    
    function _confirm(uint _seq) public payable {
        require(msg.sender == paylist[_seq].buyer_payment);
        require(seller == paylist[_seq].seller_payment);
        require(paylist[_seq].state == State.Purchase);
        seller.transfer(paylist[_seq].price);
        paylist[_seq].state = State.Finish;
    }
    
    function _adobt(uint _seq) public payable {
        require(msg.sender == paylist[_seq].buyer_payment);
        require(paylist[_seq].state == State.Purchase);
        paylist[_seq].buyer_payment.transfer(paylist[_seq].price);
        paylist[_seq].state = State.Finish;
    }
    
    function set(uint _value) public {
        sellerlist[msg.sender].productlist[producSeq].
        price = _value;
        producSeq++;
    }
}