pragma solidity ^0.5.0;

contract MindHub {


    function totalSupply() public view returns (uint256 supply) {}
    function balanceOf(address _owner) public view returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) public returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {}
    function approve(address _spender, uint256 _value) public returns (bool success) {}
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    
    /*
    배송 상태 {구매완료, 배송중, 배송완료, 구매확정, 완료}
    */
    enum State { PurchaseCompletion, 
    Shipping, 
    DeliveryComplete, 
    PurchaseConfirmation, 
    Completion }

    /*
    물품 Struct 
    name 물품이름
    price 가격
    seller_owner 물품 주인*/
    struct Product {
        string name;
        uint price;
        address payable seller_owner;
    }

    /*
    사용자 Struct */
    struct User {
        address account;
        uint[] paymentArray;
        uint[] productArray;
        bool isSeller;
    }

    struct Payment {
        uint paymentId;
        uint price;
        uint deliveryTime;
        address payable sellerAddress;
        address payable buyerAddress;
        State state;
    }

    uint private productId;
    uint private paymentId;
    uint private sellerId;
    uint private officialDelveryTime = 30;

    mapping(address => User) userList;
    mapping(uint => Payment) payList;
    mapping(uint => Product) productList;
    

    constructor() public {
        productId = 0;
        paymentId = 0;
        sellerId = 0;
    }
    
    //오직 판매자만 접근하는 모디파이어
    modifier onlySeller(address _address) {
        require(userList[_address].isSeller == true);
        _;
    }
    
    //구매를 했는지 확인하는 모디파이어
    modifier isPurchaseCompletion(State state) {
        require( state == State.PurchaseCompletion );
        _;
    }
    

    /*
    ============================구매부분================================
    */
    
    function _purchase_product(uint _productId) public payable {
        require(productList[_productId].price == msg.value);
        userList[msg.sender].paymentArray.push(paymentId);
        payList[paymentId].paymentId = paymentId;
        payList[paymentId].price = msg.value;
        payList[paymentId].sellerAddress = productList[_productId].seller_owner;
        payList[paymentId].buyerAddress = msg.sender;
        payList[paymentId].state = State.PurchaseCompletion;
        payList[paymentId].deliveryTime = now + officialDelveryTime;
        paymentId++;
    }
    
    function _confirm(uint _payId, uint _productId) public 
    isPurchaseCompletion(payList[_payId].state) {
        require(productList[_productId].seller_owner == payList[_payId].sellerAddress);
        transfer( payList[_payId].sellerAddress, payList[_payId].price);
        payList[_payId].state = State.Completion;
    }
    
    function _adobt(uint _payId) public 
    isPurchaseCompletion(payList[_payId].state) {
        payList[_payId].buyerAddress.transfer(payList[_payId].price);
        payList[_payId].state = State.Completion;
    }
    
    function _auto_confirm(uint _payId, uint _productId) public {
        require(now >= payList[_payId].deliveryTime);
        _confirm(_payId, _productId);
    }


    /*
    ============================판매자 등록================================
    */
    function _register_seller() public {
        userList[msg.sender].isSeller = true;
    }
    
    //판매자 정보 불러오기
    function _get_seller_info(address _account) view public returns  (address) {
        return (userList[_account].account);
    }
    
    //물품 갯수 불러오기
    function _get_product_count() view public returns (uint) { 
        return productId;
    }


    /*
    ============================물품 등록================================
    */
    //판매 물품 등록
    function _register_product(string memory _product_name, uint _price) public onlySeller(msg.sender) {
        userList[msg.sender].productArray.push(productId);
        productList[productId].name = _product_name;
        productList[productId].price = _price;
        productList[productId].seller_owner = msg.sender;
        productId++;
    }
}

contract StandardToken is MindHub {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply;
}

contract MindT is StandardToken { // CHANGE THIS. Update the contract name.

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address payable public fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    constructor() public {
        balances[msg.sender] = 1000000000000000000000;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        _totalSupply = 1000000000000000000000;                        // Update total supply (1000 for example) (CHANGE THIS)
        name = "MindT";                                              // Set the name for display purposes (CHANGE THIS)
        decimals = 18;                                               // Amount of decimals for display purposes (CHANGE THIS)
        symbol = "SUPC";                                             // Set the symbol for display purposes (CHANGE THIS)
        unitsOneEthCanBuy = 10;                                      // Set the price of your token for the ICO (CHANGE THIS)
        fundsWallet = msg.sender;                                    // The owner of the contract gets ETH
    }

    function() external payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        emit Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }
}