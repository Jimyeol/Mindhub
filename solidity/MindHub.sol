pragma solidity ^0.4.20;

contract MindHub {
    /*
    물품 Struct */
    struct Product {
        string product_name;
        uint price;
    }
    
    Product[] public products;
    
    //product번호로 판매자가 누구껀지 매핑
    mapping (uint => address) public productToSeller;
    //판매자로 판매물품 번호 매핑
    mapping (address => uint) sellerOwnerCount;
    
    //물품 등록 Event
    event evRegisterProduct(uint _id, string _name, uint _price);
    

    //물품등록
    function _register_product(string memory _product_name, uint _price) private {
        uint id = products.push(Product(_product_name, _price)) - 1;
        evRegisterProduct(id, _product_name, _price);
        
    }
    
    //function _get_product() private view returns (Product) {
    //    return Product("a", 1);
    //}
    
}