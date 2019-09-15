pragma solidity ^0.5.0;

contract MindHub {
    /*
    물품 Struct */
    struct Product {
        string product_name;
        uint32 price;
        uint32 time;
    }
    /*
    판매자 Struct */
    struct Seller {
        address account;
        uint24 sellerNumber;
        string name;
        Product[] products;
    }

    /*
    구매자 Struct */
    struct Buyer {
        address account;
        uint24 buyerNumber;
        string name;
    }

    
    Seller[] public sellers;
    Buyer[] public buyers;

    mapping(address => Seller)sellerInfo;
    mapping(address => Buyer)buyerInfo;

    event RegisterSellerConfirm();
    event RegisterBuyerConfirm();

    //오직 판매자만 접근하는 모디파이어
    modifier onlySeller(address _address) {
        require(sellerInfo[_address].account == msg.sender);
        _;
    }

     //오직 구매자만 접근하는 모디파이어
    modifier onlyBuyer(address _address) {
        require(buyerInfo[_address].account == msg.sender);
        _;
    }


    //판매자 등록
    function _register_seller(uint24 _sellerNumber, string memory _name) public {
        //sellers.push(Seller(msg.sender, _sellerNumber, _name, ));
        sellerInfo[msg.sender].account = msg.sender;
        sellerInfo[msg.sender].sellerNumber = _sellerNumber;
        sellerInfo[msg.sender].name = _name;
        emit RegisterSellerConfirm();
    }
    
    //판매자 정보 불러오기
    function _get_seller_info(address _account) view public returns  (address, uint24, string memory) {
        return (sellerInfo[_account].account, sellerInfo[_account].sellerNumber, sellerInfo[_account].name);
    }


    /*-----------------------------------------------------------------------------------*/
    /*-----------------------------------------------------------------------------------*/
    //구매자 등록
    function _register_buyer(uint24 _buyerNumber, string memory _name) public {
        buyers.push(Buyer(msg.sender, _buyerNumber, _name));
        buyerInfo[msg.sender].account = msg.sender;
        buyerInfo[msg.sender].buyerNumber = _buyerNumber;
        buyerInfo[msg.sender].name = _name;
        emit RegisterBuyerConfirm();
    }
    
    //구매자 정보 불러오기
    function _get_buyer_info(address _account) view public returns (address, uint24, string memory) {
        return (buyerInfo[_account].account, buyerInfo[_account].buyerNumber, buyerInfo[_account].name);
    }

    /*-----------------------------------------------------------------------------------*/
    /*-----------------------------------------------------------------------------------*/
    function _register_product() public onlySeller(msg.sender) {
        //sellers.push(Seller(msg.sender, _sellerNumber, _name, ));
        uint a;
        a = 20;
    }
}