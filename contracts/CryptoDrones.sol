// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "base64-sol/base64.sol";

contract CryptoDrones is ERC721Enumerable, Ownable, ReentrancyGuard {
    enum DroneElementType {
        Fire,
        Water,
        Ice,
        Electricity,
        Earth,
        Wind,
        Light,
        Dark
    }

    struct DroneAttributes {
        /**
         * Elements of the drone
         * Type structure (example for type Light level 5):
         * 0 0 0 0   0 0 0 0   0 1 0 1   0 1 1 0
         *
         * First 4 bytes (on the right) are reserved for the drone element type  (max of 16 types)
         * Last 12 bytes (on the left)  are reserved for the drone element level (max of 4096 levels)
         */
        uint16[] elements;
        uint8 attacksPerSecond;
        uint8 attackDamages;
        uint8 attackRange;
    }

    function droneElementTypeToString(DroneElementType elementType)
        internal
        pure
        returns (string memory)
    {
        if (elementType == DroneElementType.Fire) return "Fire";
        if (elementType == DroneElementType.Water) return "Water";
        if (elementType == DroneElementType.Ice) return "Ice";
        if (elementType == DroneElementType.Electricity) return "Electricity";
        if (elementType == DroneElementType.Earth) return "Earth";
        if (elementType == DroneElementType.Wind) return "Wind";
        if (elementType == DroneElementType.Light) return "Light";
        if (elementType == DroneElementType.Dark) return "Dark";
        return "Unknown";
    }

    function droneElementToString(uint32 element)
        internal
        pure
        returns (string memory)
    {
        uint32 elementType = element & 0xF;
        uint32 elementLevel = element >> 4;

        return
            string(
                abi.encodePacked(
                    droneElementTypeToString(DroneElementType(elementType)),
                    " ",
                    Strings.toString(elementLevel)
                )
            );
    }

    mapping(uint256 => DroneAttributes) private _drones;

    constructor() ERC721("CryptoDrones", "DRN") Ownable() {}

    function random(string memory prefix) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        prefix,
                        blockhash(block.number - 1),
                        totalSupply()
                    )
                )
            );
    }

    function mint() public nonReentrant returns (uint256) {
        require(balanceOf(_msgSender()) == 0, "You already have a drone");
        return createDrone(_msgSender());
    }

    function burn(uint256 id) public nonReentrant {
        require(_exists(id), "Drone does not exist");
        require(
            ownerOf(id) == _msgSender(),
            "You are not the owner of this drone"
        );

        _burn(id);
    }

    function mintOwner(address receiver)
        public
        nonReentrant
        onlyOwner
        returns (uint256)
    {
        return createDrone(receiver);
    }

    function createDrone(address receiver) internal returns (uint256) {
        uint256 id = totalSupply();

        uint256 numElements = (random("ELEMENTS") % 2) + 1;

        DroneAttributes memory attributes = DroneAttributes({
            elements: new uint16[](numElements),
            attacksPerSecond: uint8(random("APERSECOND") % 3) + 1,
            attackDamages: uint8(random("ADAMAGES") % 20) + 5,
            attackRange: uint8(random("ARANGE") % 10) + 4
        });

        for (uint256 i = 0; i < numElements; i++) {
            uint256 rand = random(string(abi.encodePacked("ELEMENTS_", i)));

            uint16 element = ((uint16(rand % 2) + 1) << 4) +
                uint16(DroneElementType(rand % 8));

            attributes.elements[i] = element;
        }

        _drones[id] = attributes;
        _safeMint(receiver, id);

        return id;
    }

    function getDrone(uint256 id) public view returns (string memory) {
        require(_exists(id), "Drone does not exist");

        DroneAttributes memory attributes = _drones[id];

        string memory elements = "[";

        for (uint256 i = 0; i < attributes.elements.length; i++) {
            elements = string(
                abi.encodePacked(
                    elements,
                    '"',
                    droneElementToString(attributes.elements[i]),
                    '"',
                    (i < (attributes.elements.length - 1)) ? ", " : ""
                )
            );
        }

        elements = string(abi.encodePacked(elements, "]"));

        return
            string(
                abi.encodePacked(
                    '{"id": "',
                    Strings.toString(id),
                    '"',
                    ', "elements": ',
                    elements,
                    ', "attacksPerSecond": ',
                    Strings.toString(attributes.attacksPerSecond),
                    ', "attackDamages": ',
                    Strings.toString(attributes.attackDamages),
                    ', "attackRange": ',
                    Strings.toString(attributes.attackRange),
                    "}"
                )
            );
    }

    function tokenURILine(uint64 line, string memory data)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<text x="10" dy="',
                    line * 20,
                    '" class="base">Element: ',
                    data,
                    "</text>"
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Drone does not exist");

        DroneAttributes memory drone = _drones[tokenId];

        string[] memory parts = new string[](5 + drone.elements.length);
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />';

        uint64 i = 1;

        for (uint256 j = 0; j < drone.elements.length; j++) {
            parts[i++] = tokenURILine(
                i,
                droneElementToString(drone.elements[j])
            );
        }

        parts[i++] = tokenURILine(i, Strings.toString(drone.attacksPerSecond));
        parts[i++] = tokenURILine(i, Strings.toString(drone.attackDamages));
        parts[i++] = tokenURILine(i, Strings.toString(drone.attackRange));

        parts[i++] = "</svg>";

        string memory output = "";
        for (uint256 j = 0; j < i; j++) {
            output = string(abi.encodePacked(output, parts[j]));
        }

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Drone #',
                        Strings.toString(tokenId),
                        '", "description": "Drones used in Thousands Sheep game.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
