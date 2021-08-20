import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Web3 {
  late Client httpClient;
  late Web3Client ethClient;
  String rpcUrl = 'http://0.0.0.0:7545';
  String privateKey = '4b06df99f45219fe636bdd7ea6aa54e53f9ad15f8ababe2be369040e4a3a27a0';
  late Credentials credentials;
  late EthereumAddress myAddress;
  late String abi;
  late EthereumAddress contractAddress;
  late DeployedContract contract;
  late ContractFunction getBalanceAmount, getDepositAmount, addDepositAmount, withdrawBalance;

  init() async {
    httpClient = Client();
    ethClient = Web3Client(rpcUrl, httpClient);
    credentials = await ethClient.credentialsFromPrivateKey(privateKey);
    myAddress = await credentials.extractAddress();

    String abiString = await rootBundle.loadString('src/abis/Storage.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);

    contractAddress = EthereumAddress.fromHex(abiJson['networks']['5777']['address']);
    contract = DeployedContract(ContractAbi.fromJson(abi, "Investment"), contractAddress);

    getBalanceAmount = contract.function('getBalanceAmount');
    getDepositAmount = contract.function('getDepositAmount');
    addDepositAmount = contract.function('addDepositAmount');
    withdrawBalance = contract.function('withdrawBalance');
  }

  Future<List<dynamic>> readContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    var queryResult = await ethClient.call(
      contract: contract,
      function: functionName,
      params: functionArgs,
    );

    return queryResult;
  }

  Future<void> writeContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );
  }
}

final web3 = Web3();
