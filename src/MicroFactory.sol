// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MicroFactory is ERC1155, Ownable {
    uint256 public constant FACTORY_TYPE = 0;
    uint256 public constant ITEM_TYPE = 1;

    uint256 public factoryCounter;
    uint256 public itemCounter;

    struct Factory {
        uint256 level;
        uint256 lastProduction;
        address owner;
    }

    mapping(uint256 => Factory) public factories;

    event FactoryMinted(address indexed owner, uint256 indexed factoryId, uint256 level);
    event Produced(uint256 indexed factoryId, uint256 itemId, uint256 amount);
    event ItemSold(uint256 indexed itemId, address seller, address buyer, uint256 price);

    constructor() ERC1155("https://api.example.com/metadata/{id}") Ownable(msg.sender) {}

    // Mint a new factory (cost in base token - simplified, no token here for MVP)
    function mintFactory(uint256 level) external returns (uint256) {
        require(level >= 1 && level <= 5, "Invalid level");
        factoryCounter++;
        factories[factoryCounter] = Factory(level, block.timestamp, msg.sender);
        _mint(msg.sender, factoryCounter, 1, "");
        emit FactoryMinted(msg.sender, factoryCounter, level);
        return factoryCounter;
    }

    // Produce items from a factory (cooldown based on level)
    function produce(uint256 factoryId) external {
        Factory storage f = factories[factoryId];
        require(f.owner == msg.sender, "Not owner");
        uint256 cooldown = 24 hours / f.level;
        require(block.timestamp >= f.lastProduction + cooldown, "Cooldown");
        uint256 amount = f.level * 10;
        itemCounter += amount;
        // Mint items
        for (uint256 i = 0; i < amount; i++) {
            _mint(msg.sender, itemCounter, 1, "");
            emit Produced(factoryId, itemCounter, 1);
        }
        f.lastProduction = block.timestamp;
    }

    // Sell an item (fixed price in ETH for simplicity)
    function sellItem(uint256 itemId, uint256 price) external {
        require(balanceOf(msg.sender, itemId) > 0, "No item");
        _burn(msg.sender, itemId, 1);
        // Transfer price to seller (ETH sent with call)
        (bool ok, ) = payable(msg.sender).call{value: price}("");
        require(ok, "Transfer failed");
        emit ItemSold(itemId, msg.sender, address(this), price);
    }

    // Admin withdraw collected fees (if any)
    function withdraw() external onlyOwner {
        (bool ok, ) = payable(owner()).call{value: address(this).balance}("");
        require(ok, "Withdraw failed");
    }

    receive() external payable {}
}
