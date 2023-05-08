require("dotenv").config();
const { BigNumber, ethers } = require("ethers");
console.log(ethers.version);

const path = require('path');

// Contract names.
const cName = "Assignment4Exchange";
const cTokenName = "Assignment4Coin";
const cRegistryName = "Assignment4Registry";

// Provider and Addresses: localhost and on-chain.

// Localhost (Hardhat private keys--do not use in production).
const provider = new ethers.providers.JsonRpcProvider(
    "http://127.0.0.1:8545"
);
let signer = new ethers.Wallet(
    "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
    provider
);
let deployer = new ethers.Wallet(
    "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a",
    provider
);
// Loading addresses from file saved from deploy script.
const [ cAddress, cTokenAddress, cRegistryAddress ] = 
    require(path.join(__dirname, '.addresses.json'));


// On-chain.
// const provider = new ethers.providers.JsonRpcProvider(
//     "http://134.155.50.136:8506"
// );
// let signer = new ethers.Wallet(
//     process.env.METAMASK_1_PRIVATE_KEY,
//     provider
// );
// let deployer = new ethers.Wallet(
//     process.env.METAMASK_2_PRIVATE_KEY,
//     provider
// );
// const cAddress = "0x3156890063399A474Da9E59fae4919AC875BCA29";
// const cTokenAddress = "0x9044369C4D51B6a04c2f84dF28c2c1C16d151429";
// const cRegistryAddress = "0xCd7368D363d30469bf70A7135578716988FC1BdD";

console.log("Signer 1: ", signer.address);
console.log("Signer 2: ", deployer.address);

const getAssContract = async (
    signer = deployer,
    _cAddress = cAddress,
    _cName = cName
) => {
    // Fetch the ABI from the artifacts.
    const assABI = require("../../artifacts/contracts/assignment_4/" +
        _cName +
        ".sol/" +
        _cName +
        ".json").abi;

    // Create the contract and print the address.
    const ass = new ethers.Contract(_cAddress, assABI, signer);

    console.log(_cName + " address: ", ass.address);

    return ass;
};

// Interaction starts here!

const getTokenAddress = async() => {
    const cAMM = await getAssContract(signer);
    // Simulates the execution on a single node.
    return await cAMM.callStatic.getTokenAddress();
};
// (async () => { console.log(await getTokenAddress()); })()

const setup = async() => {

    const _cTokenAddress = await getTokenAddress();
    if (_cTokenAddress !== cTokenAddress) {
        console.log("Invalid address returned");
        return;
    }

    const cToken = await getAssContract(signer, _cTokenAddress, cTokenName);
    let tx = await cToken.mint(signer.address, 1000);
    await tx.wait();
    let balanceTokens = await cToken.balanceOf(signer.address);
    let balanceEther = await provider.getBalance(signer.address);
    console.log("Available Tokens: ", Number(balanceTokens));
    console.log("Available  Ether:", ethers.utils.formatEther(balanceEther));
};

// setup();
// return;

const checkPool = async() => {
    const cAMM = await getAssContract(signer);

    let ethLocked = await provider.getBalance(cAddress);
    let tokenLocked = await cAMM.getReserve();

    console.log("Available Tokens: ", Number(tokenLocked));
    console.log("Available  Ether:", ethers.utils.formatEther(ethLocked));

    // Simulates the execution on a single node.
    // return await cAMM.callStatic.getTokenAmount(1);
};

checkPool();

const checkExchangeRates = async() => {
    const cAMM = await getAssContract(signer);

    // Simulates the execution on a single node.
    const ethToToken = await cAMM.callStatic.getTokenAmount(1);

    // Simulates the execution on a single node.
    const tokenToEth = await cAMM.callStatic.getEthAmount(1);

    console.log("For 1 ETH, I get: ", Number(tokenLocked), "Tokens");
    console.log("For 1 Token, I get: ", ethers.utils.formatEther(tokenToEth), "ETH");

};
checkExchangeRates();

const approveSpending = async(amount) => {
    const _cTokenAddress = await getTokenAddress();
    const cToken = await getAssContract(signer, _cTokenAddress, cTokenName);
    let tx = await cToken.approve(_cTokenAddress, amount);
    await waitForTx(tx);

    const allowance = await cToken.allowance(signer.address, _cTokenAddress);
    console.log("Allowance:", _cTokenAddress, Number(allowance), "tokens");
};

const addLiquidity = async(amount, approve = 0) => {
    if (approve) await approveSpending(approve);
    // return;
    const cAMM = await getAssContract(signer);

    // Simulates the execution on a single node.
    const tx = await cAMM.addLiquidity(amount, {
        value: amount
    });
    await waitForTx(tx, true);

    await checkExchangeRates();

};

// addLiquidity(10, 100);
// addLiquidity(1);

// Helper function.

const waitForTx = async (tx, verbose) => {
    console.log("Transaction in mempool!");
    if (verbose) console.log(tx);
    else console.log(tx.nonce, tx.hash);
    await tx.wait();
    console.log("Transaction mined!");
};
