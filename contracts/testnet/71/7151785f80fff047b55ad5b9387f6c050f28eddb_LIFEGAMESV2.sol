// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address lpPair);

    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract LIFEGAMESV2 is IERC20, Initializable {
    using SafeMath for uint256;

    // reflection
    uint256 private _tTotal;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 public _taxFee;
    uint256 private _previousTaxFee;
    mapping(address => uint256) private _rOwned;
    address[] private _excluded;
    mapping(address => bool) private _isExcludedFromReward;
    mapping(address => bool) private _isExcludedFromFee;
    // ---------------------------------------------------

    bool private autoAddLiquidity;
    uint256 public autoAddLiquidityThreshold;

    event Burn(
        address indexed sender,
        uint256 amount
    );

    mapping(address => bool) public bridges;
    bool private isLaunched;

    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping(address => uint256) _tOwned;
    mapping(address => bool) lpPairs;
    uint256 private timeSinceLastPair;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) _isFeeExcluded;
    mapping(address => bool) private _isSniper;

    mapping(address => bool) private _liquidityHolders;

    string constant private _name = "LIFEGAMES";
    string constant private _symbol = "LFG";
    uint8 private _decimals;

    uint256 private snipeBlockAmt;
    uint256 public snipersCaught;
    bool private sameBlockActive;
    bool private sniperProtection;
    uint256 private _liqAddBlock;

    struct Fees {
        uint16 distributionToHoldersFee;
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct StaticValuesStruct {
        uint16 maxTotalFee;
        uint16 distributionToHoldersFee;
        uint16 maxBuyTaxes;
        uint16 maxSellTaxes;
        uint16 maxTransferTaxes;
        uint16 masterTaxDivisor;
    }

    struct Ratios {
        uint16 liquidity;
        uint16 buyBackAndBurn;
        uint16 total;
    }

    Fees public _taxRates;

    Ratios public _ratios;

    StaticValuesStruct public staticVals;

    IUniswapV2Router02 public dexRouter;
    address public lpPair;
    //address public currentRouter;

    //address private WETH;
    address public DEAD;
    address private zero;

    address payable public liquidityAddress;
    // si la cartera de buybackandburn y la de liquidez son la misma eliminamos esta declaración y su update (línea 1147)
    address payable public buybackAndBurnAddress;

    bool public contractSwapEnabled;
    uint256 private swapThreshold;
    uint256 private swapAmount;
    bool inSwap;

    bool public tradingActive;
    bool public hasLiqBeenAdded;
    bool public antiWhaleActivated;

    address public busdAddress;

    uint256 whaleFeePercent;
    uint256 whaleFee;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyBridge() {
        require(bridges[msg.sender] == true, "Only bridges contracts can call this function");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountAVAX, uint256 amount);
    event SniperCaught(address sniperAddress);

//    constructor (address[] memory addresses) {
//
//        // _tOwned[msgSender] = _tTotal  / 100 * 100;
//        // _tOwned[address(this)] = 0;
//
//        //_rOwned[msgSender] = _rTotal / 100 * 100; // 100%
//        //_rOwned[_msgSender()] = _rTotal;
//        _rOwned[address(this)] = 0;
//        _tOwned[address(this)] = 0;
//
//        //_tOwned[msg.sender] = _rTotal;
//        _rOwned[msg.sender] = _rTotal;
//        _owner = msg.sender;
//
//        busdAddress = address(addresses[0]);
//
//        _isFeeExcluded[_owner] = true;
//        _isFeeExcluded[address(this)] = true;
//        _isFeeExcluded[busdAddress] = true;
//
//        _approve(msg.sender, addresses[1], type(uint256).max);
//        _approve(address(this), addresses[1], type(uint256).max);
//        _approve(msg.sender, busdAddress, type(uint256).max);
//        _approve(address(this), busdAddress, type(uint256).max);
//        //setNewRouter(addresses[1], busdAddress);
//
//        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addresses[1]);
//        lpPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), busdAddress);
//        lpPairs[lpPair] = true;
//        dexRouter = _uniswapV2Router;
//
//        bridges[addresses[2]] = true;
//
//        setLiquidityAddress(addresses[3]);
//        setBuybackAndBurnAddress(addresses[4]);
//
//        emit Transfer(zero, msg.sender, _tTotal);
//        emit OwnershipTransferred(address(0), msg.sender);
//    }

    function initialize(address[] memory addresses) public initializer {

        _tTotal = 1 * 1e6 * 1e18;
        _rTotal = (MAX - (MAX % _tTotal));
        _taxFee = 10;
        _previousTaxFee = _taxFee;
        autoAddLiquidity = false;
        autoAddLiquidityThreshold = 0;
        isLaunched = false;
        timeSinceLastPair = 0;
        _decimals = 18;
        snipeBlockAmt = 0;
        snipersCaught = 0;
        sameBlockActive = true;
        sniperProtection = true;
        _liqAddBlock = 0;
        _taxRates = Fees({
        distributionToHoldersFee : 500,
        buyFee : 500,
        sellFee : 1000,
        transferFee : 0
        });
        _ratios = Ratios({
        liquidity : 300,
        buyBackAndBurn : 300,
        total: 600
        });
        staticVals = StaticValuesStruct({
        maxTotalFee: 300,
        distributionToHoldersFee: 300,
        maxBuyTaxes : 300,
        maxSellTaxes : 300,
        maxTransferTaxes : 300,
        masterTaxDivisor : 10000
        });
        DEAD = 0x000000000000000000000000000000000000dEaD;
        zero = 0x0000000000000000000000000000000000000000;
        contractSwapEnabled = false;
        tradingActive = false;
        hasLiqBeenAdded = false;
        antiWhaleActivated = false;
        swapThreshold = _tTotal / 20000;
        swapAmount = _tTotal * 5 / 1000;
        whaleFeePercent = 100;
        whaleFee = 100;

        // _tOwned[msgSender] = _tTotal  / 100 * 100;
        // _tOwned[address(this)] = 0;

        //_rOwned[msgSender] = _rTotal / 100 * 100; // 100%
        //_rOwned[_msgSender()] = _rTotal;
        _rOwned[address(this)] = 0;
        _tOwned[address(this)] = 0;

        //_tOwned[msg.sender] = _rTotal;
        _rOwned[msg.sender] = _rTotal;
        _owner = msg.sender;

        busdAddress = address(addresses[0]);

        _isFeeExcluded[_owner] = true;
        _isFeeExcluded[address(this)] = true;
        _isFeeExcluded[busdAddress] = true;

        _approve(msg.sender, addresses[1], type(uint256).max);
        _approve(address(this), addresses[1], type(uint256).max);
        _approve(msg.sender, busdAddress, type(uint256).max);
        _approve(address(this), busdAddress, type(uint256).max);
        //setNewRouter(addresses[1], busdAddress);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addresses[1]);
        lpPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), busdAddress);
        lpPairs[lpPair] = true;
        dexRouter = _uniswapV2Router;

        bridges[addresses[2]] = true;

        setLiquidityAddress(addresses[3]);
        setBuybackAndBurnAddress(addresses[4]);

        emit Transfer(zero, msg.sender, _tTotal);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    //===============================================================================================================
    //===============================================================================================================
    //===============================================================================================================
    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        _isFeeExcluded[_owner] = false;
        _isFeeExcluded[newOwner] = true;

        if (_tOwned[_owner] > 0) {
            _transfer(_owner, newOwner, _tOwned[_owner]);
        }

        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _isFeeExcluded[_owner] = false;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
    //===============================================================================================================
    //===============================================================================================================
    //===============================================================================================================

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _tTotal;}

    function decimals() external view override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner();}

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() public onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function setStartingProtections(uint8 _block) external onlyOwner {
        require(snipeBlockAmt == 0 && _block <= 5 && !hasLiqBeenAdded);
        snipeBlockAmt = _block;
    }

    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    function removeSniper(address account) external onlyOwner() {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    function setProtectionSettings(bool antiSnipe, bool antiBlock) external onlyOwner() {
        sniperProtection = antiSnipe;
        sameBlockActive = antiBlock;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isFeeExcluded(address account) public view returns (bool) {
        return _isFeeExcluded[account];
    }

    function enableTrading() public onlyOwner {
        require(!tradingActive, "Trading already enabled!");
        require(hasLiqBeenAdded, "Liquidity must be added.");
        _liqAddBlock = block.number;
        tradingActive = true;
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFee[account] = enabled;
    }

    function setTaxes(uint16 distributionToHoldersFee, uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(
            distributionToHoldersFee <= staticVals.distributionToHoldersFee &&
            buyFee <= staticVals.maxBuyTaxes &&
            sellFee <= staticVals.maxSellTaxes &&
            transferFee <= staticVals.maxTransferTaxes, "MAX TOTAL BUY FEES EXCEEDED 3%");

        require((distributionToHoldersFee + buyFee + transferFee) <= staticVals.maxTotalFee, "MAX TOTAL BUY FEES EXCEEDED 3%");
        require((distributionToHoldersFee + sellFee + transferFee) <= staticVals.maxTotalFee,  "MAX TOTAL SELL FEES EXCEEDED 3%");

        _taxRates.distributionToHoldersFee = distributionToHoldersFee;
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function setRatios(uint16 liquidity, uint16 buyBackAndBurn) external onlyOwner {
        _ratios.liquidity = liquidity;
        _ratios.buyBackAndBurn = buyBackAndBurn;
        _ratios.total = liquidity + buyBackAndBurn;
    }

    function setLiquidityAddress(address _liquidityAddress) public onlyOwner {
        require(
            _liquidityAddress != address(0),
            "_liquidityAddress address cannot be 0"
        );
        liquidityAddress = payable(_liquidityAddress);
    }

    function setBuybackAndBurnAddress(address _buybackAndBurnAddress)
    public
    onlyOwner
    {
        require(
            _buybackAndBurnAddress != address(0),
            "_buybackAndBurnAddress address cannot be 0"
        );
        buybackAndBurnAddress = payable(_buybackAndBurnAddress);
    }

    function setContractSwapSettings(bool _enabled) external onlyOwner {
        contractSwapEnabled = _enabled;
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function setNewRouter(address newRouter, address busd) public onlyOwner() {
        require(!hasLiqBeenAdded);
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(busd), address(this));
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(busd), address(this));
        }
        else {
            lpPair = get_pair;
        }
        lpPairs[lpPair] = true;
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (enabled = false) {
            lpPairs[pair] = false;
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "Cannot set a new pair this week!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
        }
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
        && to != owner()
        && tx.origin != owner()
        && !_liquidityHolders[to]
        && !_liquidityHolders[from]
        && to != DEAD
        && to != address(0)
        && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_hasLimits(from, to)) {
            if (!tradingActive) {
                revert("Trading not yet enabled!");
            }
        }

        bool takeFee = true;

        if (_isFeeExcluded[from] || _isFeeExcluded[to]) {
            takeFee = false;
        }

        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function _finalizeTransfer(address from, address to, uint256 amount, bool takeFee) internal returns (bool) {
        if (sniperProtection) {
            if (isSniper(from) || isSniper(to)) {
                revert("Sniper rejected.");
            }

            if (!hasLiqBeenAdded) {
                _checkLiquidityAdd(from, to);
                if (!hasLiqBeenAdded && _hasLimits(from, to)) {
                    revert("Only owner can transfer at this time.");
                }
            } else {
                if (_liqAddBlock > 0
                && lpPairs[from]
                    && _hasLimits(from, to)
                ) {
                    if (block.number - _liqAddBlock < snipeBlockAmt) {
                        _isSniper[to] = true;
                        snipersCaught ++;
                        emit SniperCaught(to);
                    }
                }
            }
        }

        //_tOwned[from] -= amount;

        if (inSwap) {
            return _basicTransfer(from, to, amount);
        }

        /*
        uint256 contractTokenBalance = _tOwned[address(this)];
        if (contractTokenBalance >= swapAmount) {
            contractTokenBalance = swapAmount;
        }
            

        if (!inSwap
        && !lpPairs[from]
        && contractSwapEnabled
        && contractTokenBalance >= swapThreshold
        ) {
            contractSwap(contractTokenBalance);
        }

        uint256 amountReceived = amount;

        if (takeFee) {
            amountReceived = takeTaxes(from, to, amount);
        }

        _tOwned[to] += amountReceived;

        */

        _tokenTransfer(from, to, amount, takeFee);

        //emit Transfer(from, to, amount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _tOwned[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // todo max whale fees
    function setWhaleFeesPercentage(uint256 _whaleFeePercent) external onlyOwner {
        whaleFeePercent = _whaleFeePercent;
    }

    // todo max whale fees
    function setWhaleFees(uint256 _whaleFee) external onlyOwner {
        whaleFee = _whaleFee;
    }

    // 0 -> Token -> 1000000
    // 1 -> BUSD  -> 1000

    function calculateWhaleFee(uint256 amount) public view returns (uint256) {
        uint256 busdAmount  = getOutEstimatedTokensForTokens(address(this), busdAddress, amount);
        uint256 liquidityAmount  = getOutEstimatedTokensForTokens(address(this), busdAddress, getReserves()[0]);

        // if amount in busd exceeded the % setted as whale, calc the estimated fee
        if (busdAmount >= ((liquidityAmount * whaleFeePercent) / staticVals.masterTaxDivisor)) {
            // mod of busd amount sold and whale amount
            uint256 modAmount = busdAmount % ((liquidityAmount * whaleFeePercent) / staticVals.masterTaxDivisor);
            return whaleFee * modAmount;
        } else {
            return 0;
        }
    }

    function takeTaxes(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 totalFee;
        uint256 antiWhaleAmount = 0;
        if (from == lpPair) {
            // BUY
            totalFee = _taxRates.buyFee + _taxRates.distributionToHoldersFee;
        } else if (to == lpPair) {
            // SELL
            if (antiWhaleActivated && whaleFee > 0){
                antiWhaleAmount = calculateWhaleFee(amount);
            }
            totalFee = _taxRates.sellFee + _taxRates.distributionToHoldersFee + antiWhaleAmount;
        } else {
            // TRANSFER
            totalFee = _taxRates.transferFee;
        }

        if (totalFee == 0) {
            return amount;
        }

        uint256 feeAmount = amount * totalFee / staticVals.masterTaxDivisor;
        _tOwned[address(this)] += feeAmount;
        emit Transfer(from, address(this), feeAmount);
        return amount - feeAmount;
    }

    function contractSwap(uint256 numTokensToSwap) internal swapping {
        if (_ratios.total == 0) {
            return;
        }

        if (_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        uint256 amountToLiquidity = (numTokensToSwap * _ratios.liquidity) / (_ratios.total);
        uint256 amountToBuyBackAndBurn = (numTokensToSwap * _ratios.buyBackAndBurn) / (_ratios.total);

        uint256 estimatedBusdForLiquidity = getOutEstimatedTokensForTokens(address(this), busdAddress, amountToBuyBackAndBurn);
        uint256 estimatedBusdForBuybackAndBurn = getOutEstimatedTokensForTokens(address(this), busdAddress, amountToLiquidity);

        address[] memory tokensBusdPath = getPathForTokensToTokens(address(this), busdAddress);
        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            //numTokensToSwap - amountToLiquidity - amountToBuyBackAndBurn,
            numTokensToSwap,
            0,
            tokensBusdPath,
            address(this),
            block.timestamp
        );

        if (amountToLiquidity > 0 && estimatedBusdForLiquidity > 0) {
            IERC20(address(busdAddress)).transferFrom(address(this), liquidityAddress, estimatedBusdForLiquidity);
        }

        if (amountToLiquidity > 0 && estimatedBusdForBuybackAndBurn > 0) {
            IERC20(address(busdAddress)).transferFrom(address(this), buybackAndBurnAddress, estimatedBusdForBuybackAndBurn);
        }

        if (autoAddLiquidity) {

            uint256 estimatedBusdForAutoLiquidity  = 0;
            uint256 estimatedTokensForAutoLiquidity  = 0;

            if (estimatedTokensForAutoLiquidity > autoAddLiquidityThreshold) {
                IERC20(address(busdAddress)).transferFrom(liquidityAddress, address(this), estimatedBusdForAutoLiquidity);
                IERC20(address(this)).transferFrom(liquidityAddress, address(this), estimatedTokensForAutoLiquidity);

                addLiquidity(address(this), busdAddress, estimatedTokensForAutoLiquidity, estimatedBusdForAutoLiquidity, 0, 0, msg.sender);
            }
        }
    }


    function _checkLiquidityAdd(address from, address to) private {
        require(!hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {

            _liqAddBlock = block.number;
            _liquidityHolders[from] = true;
            hasLiqBeenAdded = true;

            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i] * 10 ** _decimals);
        }
    }

    function multiSendPercents(address[] memory accounts, uint256[] memory percents, uint256[] memory divisors) external {
        require(accounts.length == percents.length && percents.length == divisors.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= (_tTotal * percents[i]) / divisors[i]);
            _transfer(msg.sender, accounts[i], (_tTotal * percents[i]) / divisors[i]);
        }
    }

    function updateAntiWhaleActivated(bool newValue) external onlyOwner {
        antiWhaleActivated = newValue;
    }

    function updateBUSDAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "ROUTER CANNOT BE ZERO");
        require(
            newAddress != address(busdAddress),
            "TKN: The BUSD already has that address"
        );
        busdAddress = address(newAddress);
    }

    function updateHasLiqBeenAdded() external onlyOwner {
        require(!hasLiqBeenAdded, "Liquidity already added and marked.");
        hasLiqBeenAdded = true;
    }
    
    function updateAutoAddLiquidity(bool newValue) external onlyOwner {
        autoAddLiquidity = newValue;
    }

    function updateAutoAddLiquidityThreshold(uint256 newValue) external onlyOwner {
        autoAddLiquidityThreshold = newValue;
    }

    function launch() external onlyOwner {
        require(!isLaunched, "Already lauched, cannot relaunch.");
        isLaunched = true;
    }

    function getReserves() public view returns (uint[] memory) {
        IUniswapV2Pair pair = IUniswapV2Pair(lpPair);
        (uint Res0, uint Res1,) = pair.getReserves();

        uint[] memory reserves = new uint[](2);
        reserves[0] = Res0;
        reserves[1] = Res1;

        return reserves;
        // return amount of token0 needed to buy token1
    }

    function getTokenPrice(uint amount) public view returns (uint) {
        uint[] memory reserves = getReserves();
        uint res0 = reserves[0] * (10 ** _decimals);
        return ((amount * res0) / reserves[1]);
        // return amount of token0 needed to buy token1
    }

    function getOutEstimatedTokensForTokens(address tokenAddressA, address tokenAddressB, uint amount) public view returns (uint256) {
        return dexRouter.getAmountsOut(amount, getPathForTokensToTokens(tokenAddressA, tokenAddressB))[0];
    }

    function getInEstimatedTokensForTokens(address tokenAddressA, address tokenAddressB, uint amount) public view returns (uint256) {
        return dexRouter.getAmountsIn(amount, getPathForTokensToTokens(tokenAddressA, tokenAddressB))[1];
    }

    function getPathForTokensToTokens(address tokenAddressA, address tokenAddressB) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenAddressA;
        path[1] = tokenAddressB;
        return path;
    }

    function updateBridges(address bridgeAddress, bool newVal) external onlyBridge {
        require(bridgeAddress != address(0), "new bridge cant be zero address");
        bridges[bridgeAddress] = newVal;
    }

    function mint(address to, uint amount) external onlyBridge {
        _tOwned[to] = _tOwned[to] + amount;
    }

    function burn(address to, uint256 amount) public {
        require(amount >= 0, "Burn amount should be greater than zero");

        if (msg.sender != to) {
            uint256 currentAllowance = _allowances[to][msg.sender];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            }
        }

        require(
            amount <= balanceOf(to),
            "Burn amount should be less than account balance"
        );

        _tOwned[to] = _tOwned[to] - amount;
        _tTotal = _tTotal - amount;
        emit Burn(to, amount);
    }


    // reflection
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10000);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
    external
    view
    returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , ,) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , ,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
    public
    view
    returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcludedFromReward[account], "Account is already excluded");
        require(
            _excluded.length + 1 <= 50,
            "Cannot exclude more than 50 accounts.  Include a previously excluded address."
        );
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcludedFromReward[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function removeAllFee() private {
        if (_taxFee == 0) return;
        _previousTaxFee = _taxFee;
        _taxFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
    }

    function _takeDistributionHoldersFee(uint256 tDistributionHoldersFee) private {
        uint256 currentRate = _getRate();
        uint256 rDistributionHoldersFee = tDistributionHoldersFee.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rDistributionHoldersFee);

        if (_isExcludedFromReward[address(this)]) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tDistributionHoldersFee);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        //_takeDistributionHoldersFee(tDistributionHoldersFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        //_takeDistributionHoldersFee(tDistributionHoldersFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        //_takeDistributionHoldersFee(tDistributionHoldersFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        //_takeDistributionHoldersFee(tDistributionHoldersFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee)
            removeAllFee();

        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee)
            restoreAllFee();
    }

    function deliver(uint256 tAmount) public {
        address sender = msg.sender;
        require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) private {
        _approve(address(this), address(dexRouter), amountADesired);
        _approve(address(this), address(dexRouter), amountBDesired);
        dexRouter.addLiquidity(
            tokenA,
            tokenB,
            amountADesired, // slippage is unavoidable
            amountBDesired, // slippage is unavoidable
            amountAMin,
            amountBMin,
            to,
            block.timestamp
        );
    }

    function testForProxy(
    ) external {
        _tTotal = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}