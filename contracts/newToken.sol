pragma solidity ^0.4.18;

import "./ERC721Basic.sol";
import "./ERC721Receiver.sol";
import "../../math/SafeMath.sol";
import "../../AddressUtils.sol";

contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
      }

modifier canTransfer(uint256 _tokenId) {
require(isApprovedOrOwner(msg.sender, _tokenId));
_;
}

function balanceOf(address _owner) public view returns (uint256) {
require(_owner != address(0));
return ownedTokensCount[_owner];
}

function ownerOf(uint256 _tokenId) public view returns (address) {
address owner = tokenOwner[_tokenId];
require(owner != address(0));
return owner;
}

function exists(uint256 _tokenId) public view returns (bool) {
address owner = tokenOwner[_tokenId];
return owner != address(0);
}

function approve(address _to, uint256 _tokenId) public {
address owner = ownerOf(_tokenId);
require(_to != owner);
require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

if (getApproved(_tokenId) != address(0) || _to != address(0)) {
  tokenApprovals[_tokenId] = _to;
  emit Approval(owner, _to, _tokenId);
    }
}

function getApproved(uint256 _tokenId) public view returns (address) {
return tokenApprovals[_tokenId];
}

function setApprovalForAll(address _to, bool _approved) public {
require(_to != msg.sender);
operatorApprovals[msg.sender][_to] = _approved;
emit ApprovalForAll(msg.sender, _to, _approved);
}

function isApprovedForAll(
address _owner,
address _operator
)
public
view
returns (bool)
{
return operatorApprovals[_owner][_operator];
}

function transferFrom(
address _from,
address _to,
uint256 _tokenId
)
public
canTransfer(_tokenId)
{
require(_from != address(0));
require(_to != address(0));

clearApproval(_from, _tokenId);
removeTokenFrom(_from, _tokenId);
addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
}

function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId
)
public
canTransfer(_tokenId)
{
// solium-disable-next-line arg-overflow
safeTransferFrom(_from, _to, _tokenId, "");
}

function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId,
bytes _data
)
public
canTransfer(_tokenId)
{
transferFrom(_from, _to, _tokenId);
// solium-disable-next-line arg-overflow
require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
}

function isApprovedOrOwner(
address _spender,
uint256 _tokenId
)
internal
view
returns (bool)
{
address owner = ownerOf(_tokenId);
// Disable solium check because of
// https://github.com/duaraghav8/Solium/issues/175
// solium-disable-next-line operator-whitespace
return (
  _spender == owner ||
  getApproved(_tokenId) == _spender ||
  isApprovedForAll(owner, _spender)
);
}

function _mint(address _to, uint256 _tokenId) internal {
require(_to != address(0));
addTokenTo(_to, _tokenId);
emit Transfer(address(0), _to, _tokenId);
}

function _burn(address _owner, uint256 _tokenId) internal {
clearApproval(_owner, _tokenId);
removeTokenFrom(_owner, _tokenId);
emit Transfer(_owner, address(0), _tokenId);
}

function clearApproval(address _owner, uint256 _tokenId) internal {
require(ownerOf(_tokenId) == _owner);
if (tokenApprovals[_tokenId] != address(0)) {
  tokenApprovals[_tokenId] = address(0);
  emit Approval(_owner, address(0), _tokenId);
}
}

function addTokenTo(address _to, uint256 _tokenId) internal {
require(tokenOwner[_tokenId] == address(0));
tokenOwner[_tokenId] = _to;
ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
}

function removeTokenFrom(address _from, uint256 _tokenId) internal {
require(ownerOf(_tokenId) == _from);
ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
tokenOwner[_tokenId] = address(0);
}

function checkAndCallSafeTransfer(
address _from,
address _to,
uint256 _tokenId,
bytes _data
)
internal
returns (bool)
{
if (!_to.isContract()) {
  return true;
}
bytes4 retval = ERC721Receiver(_to).onERC721Received(
  _from, _tokenId, _data);
return (retval == ERC721_RECEIVED);
}
}