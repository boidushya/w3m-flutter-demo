import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import "utils/abi.dart";
import "utils/ext.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late W3MService _w3mService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    W3MChainPresets.chains.putIfAbsent('11155111', () => _sepoliaChain);
    _w3mService = W3MService(
      projectId: '2a2a5978a58aad734d13a2d194ec469a',
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'w3m://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
      featuredWalletIds: {
        "ecc4036f814562b41a5268adc86270fba1365471402006302e70169465b7ac18"
      },
    );
    await _w3mService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_ButtonsView(w3mService: _w3mService)],
    ));
  }
}

class _ButtonsView extends StatelessWidget {
  const _ButtonsView({required this.w3mService});
  final W3MService w3mService;

  void _onPersonalSign() async {
    await w3mService.launchConnectedWallet();
    var hash = await w3mService.web3App?.request(
      topic: w3mService.session!.topic,
      chainId: 'eip155:$_chainId',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: ['GM from W3M flutter!!', w3mService.address],
      ),
    );
    debugPrint(hash);
  }

  Future<dynamic> testContractCall() async {
    const ethChain = "eip155:$_chainId";
    final contract = DeployedContract(
      ContractDetails.abi,
      ContractDetails.address,
    );

    final balanceFunction = contract.function('name');

    final transaction = Transaction.callContract(
      contract: contract,
      function: balanceFunction,
      parameters: [
        // EthereumAddress.fromHex(ContractDetails.balanceAddress)
      ],
    );

    debugPrint("here");

    await w3mService.launchConnectedWallet();

    final tx = await w3mService.web3App!.request(
      topic: w3mService.session!.topic,
      chainId: ethChain,
      request: SessionRequestParams(
        method: "eth_sendTransaction",
        params: [
          transaction.toJson(fromAddress: ContractDetails.balanceAddress),
        ],
      ),
    );
    debugPrint(tx);
    return tx;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox.square(dimension: 8.0),
        ElevatedButton(
            onPressed: _onPersonalSign, child: const Text("Personal Sign")),
        W3MNetworkSelectButton(service: w3mService),
        W3MAccountButton(service: w3mService),
        W3MConnectWalletButton(service: w3mService),
        ElevatedButton(
            onPressed: () async {
              testContractCall();
            },
            child: const Text("Mint")),
      ],
    );
  }
}

class ContractDetails {
  static String balanceAddress = "0x898fe5b33da8793faab6f64867329a2d80bc1792";
  static ContractAbi abi = ContractAbi.fromJson(jsonEncode(ABI.abi), "mint");
  static EthereumAddress address =
      EthereumAddress.fromHex("0x267320B93f1FEb7E019fF700aD19D11A34d9544B");
}

const _chainId = "11155111";

final _sepoliaChain = W3MChainInfo(
  chainName: 'Sepolia',
  namespace: 'eip155:$_chainId',
  chainId: _chainId,
  tokenName: 'ETH',
  rpcUrl: 'https://rpc.sepolia.org/',
  blockExplorer: W3MBlockExplorer(
    name: 'Sepolia Explorer',
    url: 'https://sepolia.etherscan.io/',
  ),
);
