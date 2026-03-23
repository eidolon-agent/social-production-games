// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SocialFactory is ERC1155, Ownable {
    uint256 public constant FACTORY_TYPE = 0;
    uint256 public constant GOODS_TYPE = 1;

    uint256 public factoryCounter;
    uint256 public goodsCounter;
    uint256 public feeBps = 250; // 2.5%

    struct Factory {
        uint256 level;
        uint256 lastProduced;
        address owner;
    }

    mapping(uint256 => Factory) public factories;

    event FactoryMinted(address indexed owner, uint256 indexed factoryId, uint256 level);
    event Produced(uint256 indexed factoryId, uint256 goodsId, uint256 amount);
    event GoodSold(uint256 indexed goodsId, address seller, address buyer, uint256 price);
    event FeeCollected(uint256 amount);

    constructor() ERC1155("https://api.socialprod.games/metadata/{id}") Ownable(msg.sender) {}

    function mintFactory(uint256 level) external returns (uint256) {
        require(level >= 1 && level <= 5, "Invalid level");
        factoryCounter++;
        factories[factoryCounter] = Factory({ level: level, lastProduced: 0, owner: msg.sender });
        _mint(msg.sender, factoryCounter, 1, "");
        emit FactoryMinted(msg.sender, factoryCounter, level);
        return factoryCounter;
    }

    function produce(uint256 factoryId) external {
        Factory storage f = factories[factoryId];
        require(f.owner == msg.sender, "Not owner");
        uint256 cooldown = 24 hours / f.level;
        if (f.lastProduced != 0) {
            require(block.timestamp >= f.lastProduced + cooldown, "Cooldown active");
        }
        uint256 amount = f.level * 10;
        for (uint256 i = 0; i < amount; i++) {
            goodsCounter++;
            _mint(msg.sender, goodsCounter, 1, "");
            emit Produced(factoryId, goodsCounter, 1);
        }
        f.lastProduced = block.timestamp;
    }

    function sellGood(uint256 goodsId, uint256 price) external {
        require(balanceOf(msg.sender, goodsId) >= 1, "No goods");
        uint256 fee = (price * feeBps) / 10_000;
        uint256 net = price - fee;
        _burn(msg.sender, goodsId, 1);
        // Pay seller net proceeds (use transfer for simplicity)
        (bool ok, ) = payable(msg.sender).call{value: net}("");
        require(ok, "Payment failed");
        // Collect fee to owner
        (bool ok2, ) = payable(owner()).call{value: fee}("");
        require(ok2, "Fee transfer failed");
        emit GoodSold(goodsId, msg.sender, address(this), price);
        emit FeeCollected(fee);
    }

    function setFeeBps(uint256 _feeBps) external onlyOwner {
        require(_feeBps <= 500, "Fee too high");
        feeBps = _feeBps;
    }

    receive() external payable {}
}
