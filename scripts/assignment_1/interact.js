


require('dotenv').config();
const {BigNumber, ethers} = require("ethers");
console.log(ethers.version);

// Without INFTMINTER interface.
// const cAddress = "0x0295ab4bC0b97eDf83B5E046787C461B3C3C2030";
// With INFTMINTER interface.
const cAddress = "0x5811C8D377Dfe673Cb4D77a974e0F118Bd2Ce6a9";

const cName = "Assignment1";
const BASE_PRICE = 0.001;
const MINT_INCREASE = 0.0001;

const notUniMaUrl = process.env.NOT_UNIMA_URL_1;
const notUniMaProvider = new ethers.providers.JsonRpcProvider(notUniMaUrl);


let signer = new ethers.Wallet(process.env.METAMASK_1_PRIVATE_KEY, notUniMaProvider);
console.log(signer.address);

let deployer = new ethers.Wallet(process.env.METAMASK_2_PRIVATE_KEY, notUniMaProvider);
console.log(deployer.address);


const networkInfo = async () => {
    let net = await notUniMaProvider.getNetwork();
    console.log('NUMA Info:');
    console.log('Network name: ', net.name);
    console.log('Network chain id: ', Number(net.chainId));

    let blockNumber = await notUniMaProvider.getBlockNumber();
    console.log('Block number: ', blockNumber);
};

// networkInfo();

const getAssContract = async(signer) => {

    // Fetch the ABI from the artifacts.
    const assABI = require("../../artifacts/contracts/assignment_1/" + cName + 
                            ".sol/" + cName + ".json").abi;

    // d.2 Create the contract and print the address.
    const ass = new ethers.Contract(cAddress, assABI, signer);

    console.log(cName + " address standard Ethers", ass.address);

    return ass;
};

const getContractInfo = async () => {
    const contract = await getAssContract(signer);
    // console.log("_owner: ", await contract._owner());
    // Private.
    // console.log("Price: " , await contract.price());
    // console.log("Is Sale Active: ", await contract.isSaleActive());
    console.log("Get sale status: ", await contract.getSaleStatus());
    console.log("Total Supply: ", Number(await contract.totalSupply()));
    await getContractBalance();
};
// getContractInfo();

const getContractBalance = async (formatEther = true) => {
    let balance = await notUniMaProvider.getBalance(cAddress);
    if (formatEther) balance = ethers.utils.formatEther(balance);
    console.log("ETH in contract: ", balance);
    return balance;
};
// getContractBalance();

const waitForTx = async (tx, verbose) => {
    console.log('Transaction in mempool!');
    if (verbose) console.log(tx);
    else console.log(tx.nonce, tx.hash);
    await tx.wait();
    console.log('Transaction mined!');
};

const computePrice = async (totalSupply, parseEther = true) => {
    // When totalSupply = 2 it already messes up due to rounding errors.
    // https://docs.ethers.org/v5/troubleshooting/errors/#help-NUMERIC_FAULT
    let price = BASE_PRICE + (totalSupply * MINT_INCREASE);
    console.log('Current price:', price);
    // price = BigNumber.from(price);
    if (parseEther) price = ethers.utils.parseEther("" + price);
    return price;
};

const mint = async () => {
    const contract = await getAssContract(signer);
    const totalSupply = Number(await contract.totalSupply());
    console.log('Total supply:', totalSupply);
    const price = computePrice(totalSupply);
    let tx = await contract.mint(signer.address, { value: price });
    await waitForTx(tx, true);
    const newTotalSupply = Number(await contract.totalSupply());
    console.log('New total supply:', newTotalSupply);
};
mint();

const withdraw = async () => {
    const contract = await getAssContract(deployer);
    let balance = await getContractBalance();
    let amountToWithdraw = 0.00001;
    console.log("ETH to withdraw: ", amountToWithdraw);
    amountToWithdraw = ethers.utils.parseEther("" + amountToWithdraw);
    let tx = await contract.withdraw(amountToWithdraw);
    await waitForTx(tx);
    getContractBalance();
};

// withdraw();

const getMoreContractInfo = async () => {
    const contract = await getAssContract(deployer);
    console.log("Price: ", await contract.getPrice());
    console.log("Token URI: ", await contract.getTokenURI());
};



