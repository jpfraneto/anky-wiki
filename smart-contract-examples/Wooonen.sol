// SPDX-License-Identifier: MIT
// https://www.wooonen.org/

pragma solidityˆ0.8.0;

contract Wooonen is ERC721A, Ownable {
    uint256 public constant MAX_SUPPLY = 8888;
    uint256 public constant PUBLIC_SUPPLY = 8888;
    string public baseExtension = '.json';
    string private _baseTokenURI = "";
    mapping (address => uint256) public _claimed;
    mapping (address => uint256) public _whitelistClaimed;
    address public immutable cSigner;

    constructor(string memory name, string memory symbol, string memory baseURI) ERC721A(name, symbol, 100, MAX_SUPPLY){
        setBaseURI(baseURI);
        cSigner = "0x97591D4C59b35b7A3842735c5C3E3D131aB32251"
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function publicMint(uint256 num, uint8 v, bytes32 r, bytes32 s) external payable {
        require (totalSupply() < PUBLIC_SUPPLY, "All tokens minted");
        require (_claimed[msg.sender] == 0, "Claimed");
        bytes 32 digest = sha256(abi.encodePacked(msg.sender, num.toString()));
        require(ecrecover(digest, v, r, s) == cSigner, "Invalid signer");
        _claimed[msg.sender] = 1;
        _safeMint(msg.sender, num)
    }

    function whiteMint(uint256 num) external payable {
        require (totalSupply() < MAX_SUPPLY, "All tokens minted!");
        require (_whitelistClaimed[msg.sender] >= num, "Failed!");
        _whitelistClaimed[msg.sender] -= num;
        _safeMint(msg.sender, num);
    }

    function setWhiteList(uint256 num, address user) public onlyOwner {
        require(num > 0, " num <= 0");
        _whitelistClaimed[user] = num;
    }

    function setBaseURI(string memory val) public onlyOwner {
        _baseTokenURI = val;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

}
