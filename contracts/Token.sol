pragma solidity ^0.6.0;
import "@openzeppelin/upgrades/contracts/Initializable.sol";
contract Token is Initializable{
    string _name;
    string _symbol;
    //bool private _initialized=false;
    address _owner;
    uint256[] allTokens;
    mapping(address=>uint256) _balance;
    mapping(address=>uint256[]) _ownerof;
    mapping(uint256=>address) _rightowner;
    mapping(address=>uint256) noOftokens;
    mapping(address=> mapping(address=>uint256)) _allownce;
    function initialize() public initializer{
        
        _name="Armughan";
        _symbol="armu";
        _owner=msg.sender;
    }
    function balanceOf(address addr) public view returns(uint256){
        return _balance[addr];
    }
    function ownerOf(uint256 tokenId)public view returns (address){
        return _rightowner[tokenId];
    }

    function mint(uint256 tokenId) public {
        require(_rightowner[tokenId]==address(0));
        mintHelper(msg.sender,tokenId);
    }
    function mintHelper(address owner,uint256 tokenId) internal{
        _rightowner[tokenId]=owner;
        _balance[owner]=noOftokens[owner]+1;
    }
    function transferFrom(address from, address to, uint256 tokenId) public{
        require(_rightowner[tokenId]==from,"Not the Owner");
        require(to!=address(0),"address zero");
        require(_allownce[from][to]==tokenId,"Not the allowed tokenId");
        _rightowner[tokenId]=to;
        _balance[from]=noOftokens[from]-1;
        _balance[to]=noOftokens[to]+1;
    }
    function approve(address to,uint256 tokenId) external{
        address owner=_rightowner[tokenId];
        require(to!=owner);
        require(msg.sender==owner);
        ApproveHelper(msg.sender,to,tokenId);
    }
    function ApproveHelper(address _sender,address _spender,uint256 tokenId) public{
        _allownce[_sender][_spender]=tokenId;
    }
    function Transfer(address from, address to, uint256 tokenId) public{
        require(_rightowner[tokenId]==from,"Not the Owner");
        require(to!=address(0),"address zero");
        _rightowner[tokenId]=to;
        _balance[from]=noOftokens[from]-1;
        _balance[to]=noOftokens[to]+1;
    }
    function burn(address owner,uint256 tokenId) public{
        require(owner==_rightowner[tokenId],"nothing to burn");
        _rightowner[tokenId]=address(0);
        _balance[owner]=noOftokens[owner]-1;
    }
}