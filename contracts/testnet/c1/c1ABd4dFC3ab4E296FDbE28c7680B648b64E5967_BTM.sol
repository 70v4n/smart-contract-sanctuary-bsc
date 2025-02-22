/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

pragma solidity =0.6.6;

// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}

// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'BTM: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

    // renounce owner
    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }
}

// operator
contract Operator {
    address public operator;

    modifier onlyOperator() {
        require(msg.sender == operator, 'BTM: operator error');
        _;
    }

    function transferOperator(address newOperator) public onlyOperator {
        if (newOperator != address(0)) {
            operator = newOperator;
        }
    }
}

// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// BTM 
interface IBTM is IERC20 {
    function tokenRewardsFee() external view returns (uint256);
    function linkedinFee() external view returns (uint256);
    function liquidityFee() external view returns (uint256);
    function marketingFee() external view returns (uint256);
    function totalFees() external view returns (uint256);
    function getAllFees() external view returns (uint256, uint256, uint256, uint256);

    function superAddress(address _address) external view returns (address);
    function juniorAmount(address _address) external view returns (uint256);
    function juniorAddress(address _address) external view returns (address[] memory _addrs);
    function getLinkedinAddrs(address _address) external view returns (address[] memory _addrs);

    event BoundLinkedin(address from, address to);
}

// 接口
interface IDividendTracker {
    function dividendRewards(address _from) external;
    function addOrRemoveKey(address _from, uint256 _fromBalances, address _to, uint256 _toBalances) external;
}

// 主合约
contract BTM is IBTM, Ownable, Operator {
    using SafeMath for uint256;

    // tracker合约地址, 分红合约。
    address public dividendTracker;

    // 持币分红
    uint256 private _tokenRewardsFee = 5;
    // 上下级分红
    uint256 private _linkedinFee = 1;
    // 流动性分红,
    uint256 private _liquidityFee = 4;
    // 2%运营方分红
    uint256 private _marketingFee = 2;
    // 总的
    uint256 private _totalFees = _tokenRewardsFee + _linkedinFee + _liquidityFee + _marketingFee;

    // 每个地址持币数量的上限。
    uint256 public tokenLimit = 3 * 10**uint256(decimals);
    // 持币数量不受限制的地址。特殊地址持币不受限制, 如配对合约, 路由合约, 以及运营方地址
    mapping(address => bool) public notLimitAddress;
    // 交易不扣手续费的地址。任何交易都会扣除手续费, 除非设置地址为true
    mapping(address => bool) public notFeeAddress;

    // 上级地址
    mapping(address => address) private _superAddress;
    // 多个下级地址
    mapping(address => address[]) private _juniorAddress;


    // 名字
    string constant public name = "BTM";
    // 简称
    string constant public symbol = "BTM";
    // 小数位
    uint8 constant public decimals = 18;
    // 总量
    uint256 constant public totalSupply = 2100 * 10**uint256(decimals);
    // 余额
    mapping (address => uint256) public balances;
    // 授权
    mapping (address => mapping (address => uint256)) public allowed;


    // 构造函数
    constructor(
        address _owner,
        address _operator,
        address _dividendTracker
    ) public {
        owner = _owner;
        operator = _operator;
        dividendTracker = _dividendTracker;
        balances[owner] = totalSupply;

        notFeeAddress[owner] = true; // 管理员不扣手续费
        notFeeAddress[dividendTracker] = true; // 分红合约不扣手续费
        emit Transfer(address(0), owner, totalSupply);
    }

    // 设置分红的百分比
    function setFee(uint256 tokenRewardsFee_, uint256 linkedinFee_, uint256 liquidityFee_, uint256 marketingFee_) public onlyOwner {
        _tokenRewardsFee = tokenRewardsFee_;
        _linkedinFee = linkedinFee_;
        _liquidityFee = liquidityFee_;
        _marketingFee = marketingFee_;
        _totalFees = _tokenRewardsFee + _linkedinFee + _liquidityFee + _marketingFee;
    }

    // 设置分红合约地址
    function setDividendTracker(address _dividendTracker) public onlyOperator {
        dividendTracker = _dividendTracker;
    }
    // 设置持币上限
    function setTokenLimit(uint256 _tokenLimit) public onlyOperator {
        tokenLimit = _tokenLimit;
    }
    // 设置持币数量不受限制的地址
    function setNotLimitAddress(address _address) public onlyOperator {
        notLimitAddress[_address] = !notLimitAddress[_address];
    }
    // 设置交易不扣手续费的地址
    function setNotFeeAddress(address _address) public onlyOperator {
        notFeeAddress[_address] = !notLimitAddress[_address];
    }


    function balanceOf(address _address) external view override returns (uint256) {
        return balances[_address];
    }

    function _approve(address _owner, address _spender, uint256 _value) private {
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(_from, _to, _value);
    }

    function _transferFull(address _from, address _to, uint256 _value) private {
        // 发送者是否扣除手续费, 不扣手续费也就不能进行分红。
        if(notFeeAddress[_from]) {
            // 不扣除
            _transfer(_from, _to, _value);
        }else {
            // 扣除
            uint256 _fee = _value.mul(_totalFees).div(100);
            uint256 _val = _value.sub(_fee);
            _transfer(_from, dividendTracker, _fee);
            _transfer(_from, _to, _val);

            // 调用分红合约进行分红
            // 兑换,持币分红,上下级分红,回流LP分红,运营分红
            try IDividendTracker(dividendTracker).dividendRewards(_from) {} catch {}
        }
        // 增加或移除地址
        try IDividendTracker(dividendTracker).addOrRemoveKey(_from, balances[_from], _to, balances[_to]) {} catch {}

        // 绑定关系
        boundLinkedin(_from, _to);
        // 交易余额上限验证
        verifyTokenLimit(_to);
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        // 不能交易0地址
        require(_to != address(0), 'BTM: 0address error');
        // 金额需要足够
        require(balances[msg.sender] >= _value, 'BTM: balance error');
        _transferFull(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        // 不能交易0地址
        require(_to != address(0), 'BTM: 0address error');
        // 金额需要足够
        require(balances[_from] >= _value, 'BTM: balance error');
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
       _transferFull(_from, _to, _value);
        return true;
    }

    // 判断是不是合约地址
    // 返回值true=合约, false=普通地址。
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    // 持币上限的验证
    // 如果触发上限, 将会抛出错误, 终结交易。
    function verifyTokenLimit(address _toAdress) internal view {
        // 必须是合约 || 必须是不受上限地址 || 必须余额<余额上限限制
        require(isContract(_toAdress) || notLimitAddress[_toAdress] || balances[_toAdress] < tokenLimit, 'BTM: balance limit');
    }

    // 查询持币分红. 上下级分红. 流动性分红. 运营方分红. 总的
    function tokenRewardsFee() public view override returns (uint256) {
        return _tokenRewardsFee;
    }
    function linkedinFee() public view override returns (uint256) {
        return _linkedinFee;
    }
    function liquidityFee() public view override returns (uint256) {
        return _liquidityFee;
    }
    function marketingFee() public view override returns (uint256) {
        return _marketingFee;
    }
    function totalFees() public view override returns (uint256) {
        return _totalFees;
    }
    // 返回全部的
    function getAllFees() public view override returns (uint256, uint256, uint256, uint256) {
        return (_tokenRewardsFee, _linkedinFee, _liquidityFee, _marketingFee);
    }

    // 绑定关系
    function boundLinkedin(address _from, address _to) private {
        // 不能和合约绑定关系, 不能和自己绑定关系, 过。
        if(isContract(_from) || isContract(_to) || _from == _to) {
            return;
        }
        // 如果to地址没有上级
        if(_superAddress[_to] == address(0)) {
            _superAddress[_to] = _from;
            _juniorAddress[_from].push(_to);
            // 触发事件
            emit BoundLinkedin(_from, _to);
        }
    }

    // 查询上级地址
    function superAddress(address _address) public view override returns (address) {
        return _superAddress[_address];
    }

    // 查询下级数量
    function juniorAmount(address _address) public view override returns (uint256) {
        return _juniorAddress[_address].length;
    }

    // 查询全部的下级地址
    function juniorAddress(address _address) public view override returns (address[] memory _addrs) {
        uint256 _length = _juniorAddress[_address].length;
        _addrs = new address[](_length);
        for(uint256 i = 0; i < _length; i++) {
            _addrs[i] = _juniorAddress[_address][i];
        }
    }

    // 查询要分红的六个关系地址
    function getLinkedinAddrs(address _address) public view override returns (address[] memory _addrs) {
        _addrs = new address[](6);

        address _superNow = _address;
        address _juniorNow = _address;
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(i < 3) {
                // 上三级
                _addrs[i] = _superAddress[_superNow];
                _superNow = _addrs[i];
            }else {
                // 下三级
                if(_juniorAddress[_juniorNow].length > 0) {
                    // 说明有下级
                    uint256 _index = radomNumber(_juniorAddress[_juniorNow].length);
                    _addrs[i] = _juniorAddress[_juniorNow][_index];
                    _juniorNow = _addrs[i];
                }else {
                    // 没有下级
                    _addrs[i] = address(0);
                }
            }
        }
    }

    // 随机生成一个区间数, [0-max)
    function radomNumber(uint256 _max) internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _max;
    }

}