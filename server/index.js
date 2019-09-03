var Web3 = require("web3")
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    
    
var newAccount = web3.eth.personal.newAccount("yo");
console.log(newAccount)