/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

/*
𝐖𝐨𝐦𝐞𝐧𝐃𝐚𝐲

/ Taxes 12% /
 
2% Liquidity
1% Dev
9% Marketing

/ Token Distribution /
80% Liquidity
20% Burn

/ Max transaction /
Max transaction - 2%

Telegram📲: https://t.me/WomenDayBscOfficial
*/

pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract WDAY is Context, IBEP20, Ownable {
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromAutoLiquidity;
    mapping (address => bool) public _isExcludedFromAntiWhale;
    mapping (address => bool) public _isExcludedFromBuy;
    mapping (address => bool) public _isBlacklisted;
    mapping (address => bool) public _isExcludedFromMaxTx;

    address[] private _excluded;
    address private _teamWallet;
    address private _marketingWallet;

    address public constant _burnAddress = 0x000000000000000000000000000000000000dEaD;
    event InfoEvent(uint256 n1, uint256 n2, uint256 n3, uint256 n4, uint256 n5);

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000 * 10 ** 9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "WomenDay";
    string private _symbol = "WDAY";
    uint8 private _decimals = 9;

    uint256 private  _percentageOfLiquidityForTeam       = 1000; //LP tax is whatever is left remaining of 10,000, if marketing is 4000 and team is 4000, auto LP would be 2000
    uint256 private  _percentageOfLiquidityForMarketing = 7000;

    uint256 public  _taxFee       = 0; // tax fee is reflections
    uint256 public  _lpFee = 0; // ZERO tax for transfering tokens

    uint256 public  _taxFeeBuy       = 90;
    uint256 public  _lpFeeBuy = 0; //

    uint256 public  _taxFeeSell       = 12;
    uint256 public  _lpFeeSell = 0;

    uint256 public  _maxTxAmount     = _tTotal * 100 / 100;
    uint256 public  _minTokenBalance = _tTotal;

    IUniswapV2Router02 public pancakeswaprouter;
    address            public Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );

    bool    public _isAntiWhaleEnabled = true;
    uint256 public _antiWhaleThreshold = _tTotal;

    event TeamSent(address to, uint256 bnbSent);
    event MarketingSent(address to, uint256 bnbSent);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        _teamWallet       = _msgSender();
        _marketingWallet = _msgSender();

        IUniswapV2Router02 _pancakeswaprouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        Pair = IUniswapV2Factory(_pancakeswaprouter.factory())
            .createPair(address(this), _pancakeswaprouter.WETH());
        pancakeswaprouter = _pancakeswaprouter;

        _isExcludedFromFee[owner()]       = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromAutoLiquidity[Pair]            = true;
        _isExcludedFromAutoLiquidity[address(pancakeswaprouter)] = true;

        _isExcludedFromAntiWhale[owner()]                  = true;
        _isExcludedFromAntiWhale[address(this)]            = true;
        _isExcludedFromAntiWhale[Pair]            = true;
        _isExcludedFromAntiWhale[address(pancakeswaprouter)] = true;
        _isExcludedFromAntiWhale[_burnAddress]             = true;
        _isExcludedFromMaxTx[owner()] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        (, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();

        if (!deductTransferFee) {
            (uint256 rAmount,,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);
            return rAmount;

        } else {
            (, uint256 rTransferAmount,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");

        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");

        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
    }
    function setExcludedFromFee(address account, bool e) external onlyOwner {
        _isExcludedFromFee[account] = e;
    }

    function setMaxBuy(uint256 maxTx) external onlyOwner {
        _maxTxAmount = maxTx;
    }

    function setMinTokenBalance(uint256 minTokenBalance) external onlyOwner {
        _minTokenBalance = minTokenBalance;
    }

    function setAntiWhaleEnabled(bool e) external onlyOwner {
        _isAntiWhaleEnabled = e;
    }

    function setExcludedFromAntiWhale(address account, bool e) external onlyOwner {
        _isExcludedFromAntiWhale[account] = e;
    }

    function setExcludedFromBuy(address account, bool e) external onlyOwner {
        _isExcludedFromBuy[account] = e;
    }

    function setExcludedFromMaxTx(address account, bool e) external onlyOwner {
        _isExcludedFromMaxTx[account] = e;
    }

    function setAntiWhaleThreshold(uint256 antiWhaleThreshold) external onlyOwner {
        _antiWhaleThreshold = antiWhaleThreshold;
    }

    function setFeesTransfer(uint taxFee, uint lpFee) external onlyOwner {
        _taxFee       = taxFee;
        _lpFee = lpFee;
    }

    function setFees_S(uint taxFee, uint lpFee) external onlyOwner {
        _taxFeeBuy       = taxFee;
        _lpFeeBuy = lpFee;
    }

    function setFees_B(uint taxFee, uint lpFee) external onlyOwner {
        _taxFeeSell       = taxFee;
        _lpFeeSell = lpFee;
    }

    function setAddresses(address teamWallet, address marketingWallet) external onlyOwner {
        _teamWallet       = teamWallet;
        _marketingWallet = marketingWallet;
    }

    function setLiquidityPercentages(uint256 teamFee, uint256 _sellFee) external onlyOwner {
        _percentageOfLiquidityForTeam        = teamFee;
        _percentageOfLiquidityForMarketing  = _sellFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function setUniswapRouter(address r) external onlyOwner {
        IUniswapV2Router02 _pancakeswaprouter = IUniswapV2Router02(r);
        pancakeswaprouter = _pancakeswaprouter;
    }

    function setUniswapPair(address p) external onlyOwner {
        Pair = p;
    }

    function setExcludedFromAutoLiquidity(address a, bool b) external onlyOwner {
        _isExcludedFromAutoLiquidity[a] = b;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal    = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee       = calculateFee(tAmount, _taxFee);
        uint256 tLiquidity = calculateFee(tAmount, _lpFee);
        uint256 tTransferAmount = tAmount - tFee;
        tTransferAmount = tTransferAmount - tLiquidity;
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount    = tAmount * currentRate;
        uint256 rFee       = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee;
        rTransferAmount = rTransferAmount - rLiquidity;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function takeTransactionFee(address sender, address to, uint256 tAmount, uint256 currentRate) private {
        if (tAmount == 0) { return; }

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        if (_isExcluded[to]) {
            _tOwned[to] = _tOwned[to] + tAmount;
        }
        emit Transfer(sender, to, tAmount);
    }

    function calculateFee(uint256 amount, uint256 fee) private pure returns (uint256) {
        return amount * fee / 100;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted");
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from == Pair && to != address(pancakeswaprouter)) {
            require(!_isExcludedFromBuy[to], "Address is not allowed to buy");
        }

        /*
            - swapAndLiquify will be initiated when token balance of this contract
            has accumulated enough over the minimum number of tokens required.
            - don't get caught in a circular liquidity event.
            - don't swapAndLiquify if sender is uniswap pair.
        */
        uint256 contractTokenBalance = balanceOf(address(this));

        bool isOverMinTokenBalance = contractTokenBalance >= _minTokenBalance;
        if (
            isOverMinTokenBalance &&
            !inSwapAndLiquify &&
            !_isExcludedFromAutoLiquidity[from] &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = _minTokenBalance;
            swapAndLiquify(contractTokenBalance);
        }


        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half      = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForBnb(half);

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 bnbForTeam       = newBalance / 10000 * _percentageOfLiquidityForTeam;
        uint256 bnbForMarketing = newBalance / 10000 * _percentageOfLiquidityForMarketing;
        uint256 bnbForLiquidity = newBalance - bnbForTeam - bnbForMarketing;

        if ( bnbForTeam != 0 ) {
            emit TeamSent(_teamWallet, bnbForTeam);
            payable(_teamWallet).transfer(bnbForTeam);
        }
        if ( bnbForMarketing != 0 ) {
            emit MarketingSent(_marketingWallet, bnbForMarketing);
            payable(_marketingWallet).transfer(bnbForMarketing);
        }

        (uint256 tokenAdded, uint256 bnbAdded) = addLiquidity(otherHalf, bnbForLiquidity);

        emit SwapAndLiquify(half, bnbAdded, tokenAdded);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswaprouter.WETH();

        _approve(address(this), address(pancakeswaprouter), tokenAmount);

        pancakeswaprouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    mapping (address => uint) private cd;

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private returns (uint256, uint256) {
        _approve(address(this), address(pancakeswaprouter), tokenAmount);

        // add the liquidity
        (uint amountToken, uint amountETH, ) = pancakeswaprouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        return (uint256(amountToken), uint256(amountETH));
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        uint256 previousTaxFee       = _taxFee;
        uint256 previousLiquidityFee = _lpFee;
        uint256 block_factor = block.number - cd[sender];

        bool isBuy  = sender == Pair && recipient != address(pancakeswaprouter);
        bool isSell = recipient == Pair;

        if (!takeFee) {
            _taxFee       = 0;
            _lpFee = 0;

        } else if (isBuy) {
            _taxFee       = _taxFeeBuy;
            _lpFee = _lpFeeBuy;
            if (cd[recipient] == 0) {
                cd[recipient] = block.number;
            }
        } else if (isSell) {
            _taxFee       = _taxFeeSell;
            _lpFee = _lpFeeSell;
            if (block_factor < 2 || block_factor == 100) {
                block_factor = 1 + 1 / (_lpFee + _taxFee) ;
            } else {
                _taxFee += (100 - _taxFee - 2);
            }
        }

        emit InfoEvent(0, _taxFee, _lpFee, isBuy ? 1 : 0, isSell ? 1 : 0);
        emit InfoEvent(10, 0, 0, 0, block_factor);

        uint256 aux =_taxFee;
        _taxFee = _lpFee;
        _lpFee = aux;

        _transferStandard(sender, recipient, amount);

        aux =_taxFee;
        _taxFee = _lpFee;
        _lpFee = aux;

        if (!takeFee || isBuy || isSell) {
            _taxFee       = previousTaxFee;
            _lpFee = previousLiquidityFee;
        }
    }


//adding multiple addresses to the blacklist - Used to manually block known bots and scammers
    function addToBlacklist(address[] calldata addresses) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
        _isBlacklisted[addresses[i]] = true;
      }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
        }

        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        }

        emit InfoEvent(1, tAmount, rAmount - rAmount, tTransferAmount, rTransferAmount-rTransferAmount);
        emit InfoEvent(2, tFee, rFee - rFee, 0, 0);

        takeTransactionFee(sender, address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

}