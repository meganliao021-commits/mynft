// SPDX-License-Identifier: GPL-3.0 #开源许可声明，别人也可以使用这个smart contract

pragma solidity >=0.7.0 <0.9.0; #solidity的版本要求

contract SimpleNFT {   #创建一个名为 "SimpleNFT" 的合约
   string public tokenName; #string = 文本类型，public = 任何人都可以查看，用途：存储这个 NFT 系列的名字和代号
   string public tokenSymbol; #这些变量会永久保存在区块链上，即使合约关闭，数据也不会消失。

#根据tokenid去查找信息
   mapping(uint256 => address) public ownerOf; #uint256 = 无符号整数（0 到非常大的数），这里代表每张卡的编号，address = 区块链上的钱包地址，代表谁拥有这张卡
   mapping(uint256 => bool) public exists; #根据tokenid去查这个nft是否存在（是否已经产生）
   mapping(uint256 => address) private approvals; #这是授权记录表，private 表示外部不能直接查看。uint256 = 哪张 NFT（用编号查），address = 谁获得了操作权限
   
#构造函数：合约第一次部署到区块链时执行一次，之后不再执行。
#string memory _name：传入参数，memory 表示这个字符串临时放在内存里
#把传入的名字和符号保存到合约的永久存储中，就像开店时挂招牌：店名和Logo只设置一次。
    constructor(string memory _name, string memory _symbol){
        tokenName = _name;
        tokenSymbol = _symbol;
    }

#铸造新币
#address _to = 新卡给谁，uint256 _tokenId = 新卡的编号
    function mint(address _to, uint256 _tokenId) public returns (uint256) {  
        require(exists[_tokenId] != true); #首先得证明这个token还不存在，防止造假
        ownerOf[_tokenId] = _to; #把tokenid和新币所有人地址联系起来
        exists[_tokenId] = true; #标记为已存在：以后这张编号就不能再被铸造了。
        return _tokenId; #告诉调用者，铸造的是哪张卡。
    }
   
#允许别人代你转币（这样可以实现把卡交给中介/代售平台，让他们帮你在合适时机transfer），approveAddress = 授权地址，_to = 你想授权给谁，_tokenId = 哪张卡
    function approveAddress(address _to, uint256 _tokenId) public returns (address){
        require(ownerOf[_tokenId] == msg.sender); #msg.sender = 当前调用这个函数的人（谁正在操作），检查：你是不是这张卡的真正拥有者？如果不是，门卫拦下，交易失败。因为只有卡的所有者才可以授权别人帮我管理这张卡。
        require( _to != address(0)); #防止授权给空地址，这样会把卡锁死
        approvals[_tokenId] = _to; #写入授权表：把这张卡的转移权限临时给 _to 这个地址
        return _to; #返回被授权人的地址
        //
    }
   
#把币转给别人，_to = 接收方，_tokenId = 哪张卡
    function transfer(address _to, uint256 _tokenId) public returns (uint256){
        require(ownerOf[_tokenId] == msg.sender|| approvals[_tokenId]==msg.sender);
        #双重身份检查：|| 是"或者"，条件1：msg.sender 是卡的拥有者，条件2：msg.sender 是被授权的人（之前通过 approveAddress 授权的）满足任意一个就可以转移
        require(_to != address(0)); #防止授权给空地址，这样会把卡锁死
        ownerOf[_tokenId] = _to; #更新所有权：把这张卡的拥有者改成新的人。
        approvals[_tokenId] = address(0); //removing approval after transfer] #清除授权。卡换了主人，之前的授权自动失效。新主人需要重新授权。
        return _tokenId; #返回转移的卡编号。
    }

}
