// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SocialFactory.sol";

contract SocialFactoryTest is Test {
    SocialFactory sf;

    function setUp() public {
        sf = new SocialFactory();
    }

    function testMintFactory() public {
        uint256 id = sf.mintFactory(2);
        assertEq(sf.balanceOf(address(this), id), 1);
        (uint256 level, , ) = sf.factories(id);
        assertEq(level, 2);
    }

    function testProduceCooldown() public {
        uint256 fid = sf.mintFactory(1);
        // First produce should succeed (no prior production)
        sf.produce(fid);
        // Second should revert due to cooldown
        vm.expectRevert("Cooldown active");
        sf.produce(fid);
    }

    // ERC1155Receiver stubs
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes calldata) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x01ffc9a7 || interfaceId == 0x4e2312e0;
    }
}
