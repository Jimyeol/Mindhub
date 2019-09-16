pragma solidity ^0.5.0;

contract MindHub {
    /*
    물품 Struct */
    struct Product {
        uint32 product_id;
        string product_name;
        uint32 price;
        uint32 time;
    }
    uint32 productSeq;    //물품 갯수
     
    /*
    판매자 Struct */
    struct Seller {
        address account;
        uint32 sellerNumber;
        string name;
        uint[] productArray;
        mapping(uint => Product) products_list;
    }
    uint32 sellerSeq;

    /*
    구매자 Struct */
    struct Buyer {
        address account;
        uint24 buyerNumber;
        string name;
    }

    //상태
    enum State { Buy, Delivery, Arrive, Pay, Cancel, ForcePay }
    State public state;
   

    
    Seller[] private sellers;
    Buyer[] private buyers;
    Product[] private products;

    mapping(address => Seller)sellerInfo;
    mapping(address => Buyer)buyerInfo;

    event RegisterSellerConfirm();
    event RegisterBuyerConfirm();
    
    constructor() public {
        productSeq = 0; //시퀀스 넘버 초기화
        sellerSeq = 0;
    }

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

    function _seller_add_seq() private { 
        sellerSeq++;
    }

    //판매자 등록
    function _register_seller(string memory _name) public {
        //sellers.push(Seller(msg.sender, _sellerNumber, _name, ));
        sellerInfo[msg.sender].account = msg.sender;
        sellerInfo[msg.sender].sellerNumber = sellerSeq;
        sellerInfo[msg.sender].name = _name;
         _seller_add_seq();
        emit RegisterSellerConfirm();
    }
    
    //판매자 정보 불러오기
    function _get_seller_info(address _account) view public returns  (address, uint32, string memory) {
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

    //물품 갯수 증가
    function _product_add_seq() private { 
        productSeq++;
    }

    //물품 갯수 불러오기
    function _get_productseq() view public returns (uint32) { 
        return productSeq;
    }

    //판매 물품 등록
    function _register_product(string memory _product_name, uint32 _price) public onlySeller(msg.sender) {
        
        sellerInfo[msg.sender].productArray.push(productSeq);
        sellerInfo[msg.sender].products_list[productSeq].product_id = productSeq;
        sellerInfo[msg.sender].products_list[productSeq].product_name = _product_name;
        sellerInfo[msg.sender].products_list[productSeq].price = _price;
        sellerInfo[msg.sender].products_list[productSeq].time = uint32(now);
        _product_add_seq();
        //products.push(Product(_product_id, _product_name, _price, uint32(now)));
    }

    //판매자의 판매 물품 불러오기
    //문제점 불러오는걸 굳이 해야하나???
    function _get_product(address _account, uint32 _seq) view public returns (string memory, uint32, uint32) {
        return( sellerInfo[_account].products_list[_seq].product_name,
        sellerInfo[_account].products_list[_seq].price,
        sellerInfo[_account].products_list[_seq].time);
        //products.push(Product(_product_id, _product_name, _price, uint32(now)));
    }

    // function _purchase_product() public payable onlybuyer(msg.sender) {
    // }
}