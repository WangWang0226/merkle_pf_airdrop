// SPDX-License-Identifier: GPL-v3-or-later
pragma solidity 0.8.17;

import "src/lib/MerkleProof.sol";
import "src/lib/TransferHelper.sol";
import "src/interface/IERC20.sol";


/**
 * @title Airdrop
 * @dev Airdrop contract
 */
contract Airdrop {
    using TransferHelper for address;

    address public owner;
    address public airdropToken;
    mapping(uint256 => uint256) claimedBitMap;
    bytes32 public merkleRoot;

    uint public claimStartTime;
    uint public claimEndTime;

    event Claimed(uint256 index, address account, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner, address _airdropToken, bytes32 _merkleRoot, uint256 _claimStartTime, uint256 _claimEndTime) {
        owner = _owner;
        airdropToken = _airdropToken;
        merkleRoot = _merkleRoot;
        claimStartTime = _claimStartTime;
        claimEndTime = _claimEndTime;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setAirdropTime(uint256 _claimStartTime, uint256 _claimEndTime) external onlyOwner {
        claimStartTime = _claimStartTime;
        claimEndTime = _claimEndTime;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /**
     * @notice Claim airdrop.
     */
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external {
        require(!isClaimed(index), 'Airdrop: Drop already claimed.');
        require(block.timestamp < claimEndTime, "Airdrop: Expired");
        require(block.timestamp > claimStartTime, "Airdrop: Not started");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'Airdrop: Invalid proof');
       
        // Mark it claimed and send the token.
        _setClaimed(index);

        // Transfer token to account
        IERC20(airdropToken).transfer(account, amount);

        emit Claimed(index, account, amount);
    }

    function ownerWithdraw() external onlyOwner {
        require(block.timestamp > claimEndTime, "Airdrop: Not ended");
        uint amount = IERC20(airdropToken).balanceOf(address(this));
        airdropToken.safeTransfer(owner, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Airdrop: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Airdrop: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}