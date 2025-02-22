/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

pragma solidity ^0.4.23;

library SafeMath{

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a+b;
        assert (c>=a);
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(a>=b);
        return (a-b);
    }

    function mul(uint256 a,uint256 b)internal pure returns (uint256)
    {
        if (a==0)
        {
        return 0;
        }
        uint256 c = a*b;
        assert ((c/a)==b);
        return c;
    }

    function div(uint256 a,uint256 b)internal pure returns (uint256)
    {
        return a/b;
    }
}

contract ERC20{

    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value); 
}

contract Owned{

    address public owner;

    constructor() internal
    {
        owner = msg.sender;
    }

    modifier onlyowner()
    {
        require(msg.sender==owner);
        _;
    }
}

contract pausable is Owned{

    event Pause();
    event Unpause();
    bool public pause = false;

    modifier whenNotPaused()
    {
        require(!pause);
        _;
    }
    modifier whenPaused()
    {
        require(pause);
        _;
    }

    function pause() onlyowner whenNotPaused public{
        pause = true;
        emit Pause();
    }

    function unpause() onlyowner whenPaused public{
        pause = false;
        emit Unpause();
    }
}

contract claimable is ERC20,Owned,pausable{
    address public pendingOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyPendingOwner(){
        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) onlyowner public{
        pendingOwner = newOwner;
    }

    function claimOwnership() onlyPendingOwner public{
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

contract CTOKEN is claimable{
    using SafeMath for uint256;
    string public constant name = "ZTOKEN";
    string public constant symbol = "ZT";
    uint256 public decimals = 1;
    uint256 totalsupply =  16000000000*(10**decimals);
    address public owner;//超級地址
    address public swap_addr;//特定地址(swap)
    uint256 public start_time = 1648598400;//2022-03-30 00:00(+0)

    mapping (address => uint256) public swap_balances;
    mapping (address => bool) public is_send;//是否能發送
    mapping (address => uint256) internal balances;
    mapping (address => mapping(address =>uint256)) internal allowed;
    mapping (address => address) public referer;
    uint256 totaltoken;

    uint public max_balance = 1000;//最多擁有1000
    uint public oneday_send = 200; // 每日發送上限200
    uint public oneday_receive = 200; // 每日接收上限200
    uint public fourhour_send = 50; // 每4小時發送上限50
    uint public fourhour_receive = 80; // 每4小時接收上限80
    

    mapping (address => mapping (uint8 => uint)) public user_ods;//1天-send
    mapping (address => mapping (uint8 => uint)) public user_odr;//1天-receive
    mapping (address => mapping (uint8 => uint)) public user_fhs;//4小-sned
    mapping (address => mapping (uint8 => uint)) public user_fhr;//4小-receive
    mapping (address => mapping (uint8 => uint)) public user_freeze;//接收96小時無法發送
   

    event transfer_event(uint256 start_time, uint256 end_time, address _from, address _to, uint256 _num);
    event chk_log(string _type,uint256 _hour, uint256 end_time, address _addr, uint256 _0, uint256 _1, bool is_next);
    event require_log(string _type, uint256 _a, uint256 _b);

    constructor () public{
        balances[msg.sender] = totalsupply;
        totaltoken = totalsupply;

        swap_addr = msg.sender;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
     }

    function totalSupply() public view returns (uint256){
        return totaltoken;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool){
        require(_to!=address(0));
        require(_value <= balances[msg.sender]);
        if(msg.sender != owner && _to != owner)//超級地址無限制
        {
            //接收代幣96小時內無法轉出
            uint256 freeze_b = get_freeze_balance(msg.sender, now);
            require(balances[msg.sender].sub(freeze_b) >= _value,"Not enough available balance.");
            emit require_log("freeze", balances[msg.sender].sub(freeze_b), _value);

            //從特定地址接收100個代幣,才可使用發送功能
            require(is_send[msg.sender],"Unable to send.");

            //每個帳戶最多持有1000個代幣
            require(balances[_to].add(_value) <= max_balance*1*10**decimals,"Max 1000");

            emit require_log("balances_1000", balances[_to].add(_value), max_balance*1*10**decimals);

            //判斷發送額度是否超過
            bool A; 
            string memory B;
            (A, B) = chk_transaction(msg.sender,_value,"send"); 
            require(A,B);

            //判斷接收額度是否超過
            bool C; 
            string memory D;
            (C, D) = chk_transaction(_to,_value,"receive"); 
            require(C,D);
        }
        

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        user_freeze[_to][1] = user_freeze[_to][1].add(_value);//凍結的數量

        if(msg.sender == swap_addr)
        {
            //從特定地址接收100個代幣,才可使用發送功能
            swap_balances[_to] = swap_balances[_to].add(_value);
            if(swap_balances[_to] >= 100*1*10**decimals)
            {
                is_send[_to] = true;
            }
        }

        emit Transfer(msg.sender, _to, _value);
        emit transfer_event(start_time, now, msg.sender, _to, _value);//寫入交易時間

        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused  returns (bool){
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        if(msg.sender != owner && _to != owner && _from != owner)//超級地址無限制
        {
            //接收代幣96小時內無法轉出
            uint256 freeze_b = get_freeze_balance(_from, now);
            require(balances[_from].sub(freeze_b) >= _value,"Not enough available balance.");

            //從特定地址接收100個代幣,才可使用發送功能
            require(is_send[_from],"Unable to send.");

            //每個帳戶最多持有1000個代幣
            require(balances[_to].add(_value) <= max_balance*1*10**decimals,"Max 1000");

            //判斷發送額度是否超過
            bool A; 
            string memory B;
            (A, B) = chk_transaction(msg.sender,_value,"send"); 
            require(A,B);

            //判斷接收額度是否超過
            bool C; 
            string memory D;
            (C, D) = chk_transaction(_to,_value,"receive"); 
            require(C,D);
        }
        

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        user_freeze[_to][1] = user_freeze[_to][1].add(_value);//凍結的數量

        if(_from == swap_addr)
        {
            //從特定地址接收100個代幣,才可使用發送功能
            swap_balances[_to] = swap_balances[_to].add(_value);
            if(swap_balances[_to] >= 100*1*10**decimals)
            {
                is_send[_to] = true;
            }
        }

        emit Transfer(_from, _to, _value);
        emit transfer_event(start_time, now, _from, _to, _value);//寫入交易時間

        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool){
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool){
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue)
        {
            allowed[msg.sender][_spender] = 0;
        }
        else
        {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    function burn(uint256 tokens) public returns (bool){
        // 檢查夠不夠燒
        require(tokens <= balances[msg.sender]);
        // 減少 total supply
        totaltoken = totaltoken.sub(tokens);
        // 減少 msg.sender balance
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        emit Burn(msg.sender, tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function get_time_key(address _addr, uint256 _e, uint256 _hour, string memory _type) public returns (uint256){
        uint256 x1 = 0;
        x1 = (_e.sub(start_time)) / (60*_hour);//測試用分鐘(24分鐘 or 4分鐘)
        if(chk_string(_type,"send"))
        {
            if(_hour==24)
            {
                if(x1 > user_ods[_addr][0])
                {
                    user_ods[_addr][0] = x1;//紀錄時間區間
                    user_ods[_addr][1] = 0;//已發送額度

                    emit chk_log("send", _hour, _e, _addr, user_ods[_addr][0], user_ods[_addr][1], true);

                    return user_ods[_addr][1];
                }
                else
                {
                    emit chk_log("send", _hour, _e, _addr, user_ods[_addr][0], user_ods[_addr][1], false);
                    return user_ods[_addr][1];
                }
            }
            else if(_hour==4)
            {
                if(x1 > user_fhs[_addr][0])
                {
                    user_fhs[_addr][0] = x1;//紀錄時間區間
                    user_fhs[_addr][1] = 0;//已發送額度

                    emit chk_log("send", _hour, _e, _addr, user_fhs[_addr][0], user_fhs[_addr][1], true);
                    return user_fhs[_addr][1];
                }
                else
                {
                    emit chk_log("send", _hour, _e, _addr, user_fhs[_addr][0], user_fhs[_addr][1], false);
                    return user_fhs[_addr][1];
                }
            }
        }
        else if(chk_string(_type,"receive"))
        {
            if(_hour==24)
            {
                if(x1 > user_odr[_addr][0])
                {
                    user_odr[_addr][0] = x1;//紀錄時間區間
                    user_odr[_addr][1] = 0;//已接收額度

                    emit chk_log("receive", _hour, _e, _addr, user_odr[_addr][0], user_odr[_addr][1], true);

                    return user_odr[_addr][1];
                }
                else
                {
                    emit chk_log("receive", _hour, _e, _addr, user_odr[_addr][0], user_odr[_addr][1], false);
                    return user_odr[_addr][1];
                }
            }
            else if(_hour==4)
            {
                if(x1 > user_fhr[_addr][0])
                {
                    user_fhr[_addr][0] = x1;//紀錄時間區間 
                    user_fhr[_addr][1] = 0;//已接收額度

                    emit chk_log("receive", _hour, _e, _addr, user_fhr[_addr][0], user_fhr[_addr][1], true);

                    return user_fhr[_addr][1];
                }
                else
                {
                    emit chk_log("receive", _hour, _e, _addr, user_fhr[_addr][0], user_fhr[_addr][1], false);

                    return user_fhr[_addr][1];
                }
            }
        }

    }

    function chk_transaction(address _addr, uint256 _num, string memory _type) public returns (bool, string){
        uint256 end_time = now;
        string memory m;

        uint256 day_b = get_time_key(_addr, end_time, 24, _type);
        uint256 hour_b = get_time_key(_addr, end_time, 4, _type);

        bool r = true;
        if(_addr != owner)
        {
            if(chk_string(_type,"send"))
            {
                if(hour_b.add(_num) > fourhour_send*1*10**decimals)
                {
                    r = false;
                    m = "Sending limit exceeded. (4 Hour)";
                }
                else if(day_b.add(_num) > oneday_send*1*10**decimals)
                {
                    r = false;
                    m = "Sending limit exceeded. (1 Day)";
                }
                else
                {
                    user_ods[_addr][1] = user_ods[_addr][1].add(_num);//1day_send
                    user_fhs[_addr][1] = user_fhs[_addr][1].add(_num);//4hour_send
                }
            }
            else if(chk_string(_type,"receive"))
            {
                if(hour_b.add(_num) > fourhour_receive*1*10**decimals)
                {
                    r = false;
                    m = "Receiving limit exceeded. (4 Hour)";
                }
                else if(day_b.add(_num) > oneday_receive*1*10**decimals)
                {
                    r = false;
                    m = "Receiving limit exceeded. (1 Day)";
                }
                else
                {
                    user_odr[_addr][1] = user_odr[_addr][1].add(_num);//1day_receive
                    user_fhr[_addr][1] = user_fhr[_addr][1].add(_num);//4hour_receive
                }
            }
        }

        return (r,m);
    }

    function get_freeze_balance(address _addr, uint256 _e) public returns (uint256){
        uint256 x1 = 0;
        x1 = (_e.sub(start_time)) / (60*10);//測試用分鐘(10分鐘)

        if(x1 > user_freeze[_addr][0])
        {
            user_freeze[_addr][0] = x1;//紀錄時間區間
            user_freeze[_addr][1] = 0;//目前凍結的額度


            emit chk_log("freeze", 10, _e, _addr, user_freeze[_addr][0], user_freeze[_addr][1], true);

            return user_freeze[_addr][1];
        }
        else
        {
            emit chk_log("freeze", 10, _e, _addr, user_freeze[_addr][0], user_freeze[_addr][1], false);

            return user_freeze[_addr][1];
        }
    }

    function set_max_balance(uint256 num) public onlyOwner {
        max_balance = num;
    }

    function set_oneday(uint num, string memory _type) public onlyOwner {
        require(num>0);
        if(chk_string(_type,"send"))
        {
            oneday_send = num;
        }
        else if(chk_string(_type,"receive"))
        {
            oneday_receive = num;
        }
    }

    function set_fourhour(uint num, string memory _type) public onlyOwner {
        require(num>0);
        if(chk_string(_type,"send"))
        {
            fourhour_send = num;
        }
        else if(chk_string(_type,"receive"))
        {
            fourhour_receive = num;
        }
    }

    function chk_string(string a, string b) internal returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function set_referer(address _addr) public returns (bool) {
        require(_addr != address(0));
        referer[msg.sender] = _addr;
        return true;
    }
    
}