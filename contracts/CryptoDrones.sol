// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "base64-sol/base64.sol";

contract CryptoDrones is ERC721Enumerable, Ownable, ReentrancyGuard {
    enum DroneElement {
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
        DroneElement[] elements;
        uint8 attacksPerSecond;
        uint8 attackDamages;
        uint8 attackRange;
    }

    mapping(uint256 => DroneAttributes) private _drones;

    constructor() ERC721("CryptoDrones", "DRN") Ownable() {}

    function random(string memory seed, string memory prefix)
        internal
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(prefix, seed)));
    }

    function createDrone(string memory seed, address receiver)
        public
        nonReentrant
        onlyOwner
        returns (uint256)
    {
        uint256 id = totalSupply();

        uint256 numElements = (random(seed, "ELEMENTS") % 2) + 1;

        DroneAttributes memory attributes = DroneAttributes({
            elements: new DroneElement[](numElements),
            attacksPerSecond: uint8(random(seed, "APERSECOND") % 3) + 1,
            attackDamages: uint8(random(seed, "ADAMAGES") % 20) + 5,
            attackRange: uint8(random(seed, "ARANGE") % 10) + 4
        });

        for (uint256 i = 0; i < numElements; i++) {
            uint256 rand = random(
                seed,
                string(abi.encodePacked("ELEMENTS_", Strings.toString(i)))
            );

            attributes.elements[i] = DroneElement(uint256(rand % 8));
        }

        _drones[id] = attributes;
        _safeMint(receiver, id);

        return id;
    }

    function elementToString(DroneElement element)
        internal
        pure
        returns (string memory)
    {
        if (element == DroneElement.Fire) return "Fire";
        if (element == DroneElement.Water) return "Water";
        if (element == DroneElement.Ice) return "Ice";
        if (element == DroneElement.Electricity) return "Electricity";
        if (element == DroneElement.Earth) return "Earth";
        if (element == DroneElement.Wind) return "Wind";
        if (element == DroneElement.Light) return "Light";
        if (element == DroneElement.Dark) return "Dark";
        return "Unknown";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(tokenId < totalSupply(), "CryptoDrones: Token must exists");

        DroneAttributes memory drone = _drones[tokenId];

        string[] memory parts = new string[](5 + drone.elements.length);
        uint64 i = 0;
        parts[
            i++
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />';
        // i++;

        for (uint256 j = 0; j < drone.elements.length; j++) {
            parts[i++] = string(
                abi.encodePacked(
                    '<text x="10" dy="',
                    Strings.toString(i * 20),
                    '" class="base">Element ',
                    elementToString(drone.elements[j]),
                    "</text>"
                )
            );
        }

        parts[i++] = string(
            abi.encodePacked(
                '<text x="10" dy="',
                Strings.toString(i * 20),
                '" class="base">Attacks Per Second: ',
                Strings.toString(drone.attacksPerSecond),
                "</text>"
            )
        );

        parts[i++] = string(
            abi.encodePacked(
                '<text x="10" dy="',
                Strings.toString(i * 20),
                '" class="base">Attack Damages: ',
                Strings.toString(drone.attackDamages),
                "</text>"
            )
        );

        parts[i++] = string(
            abi.encodePacked(
                '<text x="10" dy="',
                Strings.toString(i * 20),
                '" class="base">Attack Range: ',
                Strings.toString(drone.attackRange),
                "</text>"
            )
        );

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
