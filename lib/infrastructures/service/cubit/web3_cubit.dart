import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/internal/ethereum_credentials.dart';
import '/internal/web3_contract.dart';
import '/internal/web3_utils.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

part 'web3_state.dart';

class Web3Cubit extends Cubit<Web3State> {
  Web3Cubit({
    required this.web3Client,
    required this.greeterContract,
    required this.customerContract,
  }) : super(const Web3State());

  // core declarations
  final Web3Client web3Client;
  final DeployedContract greeterContract;
  final DeployedContract customerContract;
  late String sender;
  late SessionStatus sessionStatus;
  late EthereumWalletConnectProvider provider;
  late WalletConnect walletConnector;
  late WalletConnectEthereumCredentials wcCredentials;

  // contract-specific declarations
  //keep the user interface up-to-date with the latest value on the blockchain
  late Timer timer;

  /// Terminates metamask, provider, contract connections
  void closeConnection() {
    timer.cancel();
    walletConnector.killSession();
    walletConnector.close();

    emit(SessionTerminated());
  }

  /// Initialize provider provided by [session] and [connector]
  void initializeProvider({
    required WalletConnect connector,
    required SessionStatus session,
  }) {
    walletConnector = connector;
    sessionStatus = session;
    sender = connector.session.accounts[0];
    provider = EthereumWalletConnectProvider(connector);
    wcCredentials = WalletConnectEthereumCredentials(provider: provider);

    /// periodically fetch greeting from chain
    timer =
        Timer.periodic(const Duration(seconds: 5), (_) => getBuyerContract());

    emit(InitializeProviderSuccess(
        accountAddress: sender, networkName: getNetworkName(session.chainId)));
  }

  /// Greeter contract

  /// Get greeting from
  Future<void> fetchGreeting() async {
    try {
      List<dynamic> response = await web3Client.call(
        contract: greeterContract,
        function: greeterContract.function(greetFunction),
        params: <dynamic>[],
      );
      emit(FetchGreetingSuccess(message: response[0]));
    } catch (e) {
      emit(FetchingFailed(errorCode: '', message: e.toString()));
    }
  }

  /// Update greeter contract with provided [text]
  Future<void> updateGreeting(String text) async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: greeterContract,
          function: greeterContract.function(setGreetingFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <String>[text],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          fetchGreeting();
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }

  /// TODO: <another> contract
  
  /// BUYER FUNCTIONS
   Future<void> createBuyerContract() async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: customerContract,
          function: customerContract.function(createContractFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <dynamic>[EthereumAddress.fromHex(sender)],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }
  Future<dynamic> getBuyerContract() async {
  try {
    List<dynamic> response = await web3Client.call(
      contract: customerContract,
      function: customerContract.function(getContractFunction),
      params: <dynamic>[EthereumAddress.fromHex(sender)],
    );
    print(response[0]); // contract address
    return response[0];
  } catch (e) {
    emit(FetchingFailed(errorCode: '', message: e.toString()));
    return '';
  }
}
Future<dynamic> getBuyerContractBalance() async {
  try {
    List<dynamic> response = await web3Client.call(
      contract: customerContract,
      function: customerContract.function(getBalanceFunction),
      params: <dynamic>[EthereumAddress.fromHex(sender)],
    );
    print(response[0]); // balance
    return response[0];
  } catch (e) {
    emit(FetchingFailed(errorCode: '', message: e.toString()));
    return '';
  }
}
Future<dynamic> scanTransaction(int index) async {
  try {
    List<dynamic> response = await web3Client.call(
      contract: customerContract,
      function: customerContract.function(viewTransactionFunction),
      params: <dynamic>[EthereumAddress.fromHex(sender), index],
    );
    print(response[0]); // transaction - shopping
    return response[0];
  } catch (e) {
    emit(FetchingFailed(errorCode: '', message: e.toString()));
    return '';
  }
}
Future<void> payShopping() async {
    emit(TransactionLoading());
    List<String> sellers = List.empty(growable: true);
    List<String> info = List.empty(growable: true);
    List<String> prices = List.empty(growable: true);

    /// fill the arrays from the basket
    /// compare the balance wiith the total amount
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: customerContract,
          function: customerContract.function(paymentFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <dynamic>[EthereumAddress.fromHex(sender), sellers, info, prices],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          getBuyerContract();
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }
Future<void> requestReturn(String seller, int index) async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: customerContract,
          function: customerContract.function(requestReturnFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <dynamic>[EthereumAddress.fromHex(sender), EthereumAddress.fromHex(seller), index],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }
  Future<void> loadToBuyerContract(dynamic amount) async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials, Transaction(
          from: EthereumAddress.fromHex(sender),
          to: await getBuyerContract(),
          value: amount
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }
  /// SELLER FUNCTIONS
  Future<void> createSellerContract() async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: customerContract,
          function: customerContract.function(createSellerContractFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <dynamic>[EthereumAddress.fromHex(sender)],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }
  Future<dynamic> getSellerContract() async {
  try {
    List<dynamic> response = await web3Client.call(
      contract: customerContract,
      function: customerContract.function(getSellerContractFunction),
      params: <dynamic>[EthereumAddress.fromHex(sender)],
    );
    print(response[0]); // contract address
    return response[0];
  } catch (e) {
    emit(FetchingFailed(errorCode: '', message: e.toString()));
    return '';
  }
}
Future<void> returnTokensToCustomer(String buyer, int index) async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: customerContract,
          function: customerContract.function(returnTokensFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <dynamic>[EthereumAddress.fromHex(buyer), EthereumAddress.fromHex(sender), index],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }
  Future<void> sendTokensToSeller(String buyer, int index) async {
    emit(TransactionLoading());
    try {
      String txnHash = await web3Client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          contract: customerContract,
          function: customerContract.function(sendSellerFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <dynamic>[EthereumAddress.fromHex(buyer), EthereumAddress.fromHex(sender), index],
        ),
        chainId: sessionStatus.chainId,
      );

      late Timer txnTimer;
      txnTimer = Timer.periodic(
          Duration(milliseconds: getBlockTime(sessionStatus.chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          emit(const TransactionSuccess());
          txnTimer.cancel();
        }
      });
    } catch (e) {
      emit(TransactionFailed(errorCode: '', message: e.toString()));
    }
  }

}
