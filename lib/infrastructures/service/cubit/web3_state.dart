part of 'web3_cubit.dart';

class Web3State {
  const Web3State();
}

/// Event classes

class InitializeProviderLoading extends Web3State {
  InitializeProviderLoading();
}

class InitializeProviderSuccess extends Web3State {
  const InitializeProviderSuccess({
    required this.accountAddress,
    required this.networkName,
  });

  final String accountAddress;
  final String networkName;
}

class InitializeProviderFailed extends Web3State {
  const InitializeProviderFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class SessionTerminated extends Web3State {
  SessionTerminated();
}

/// Greeter contract
/// Contains Greeter contract related events

class FetchGreetingLoading extends Web3State {
  FetchGreetingLoading();
}

class FetchGreetingSuccess extends Web3State {
  const FetchGreetingSuccess({required this.message});
  final String message;
}

class FetchingFailed extends Web3State {
  const FetchingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class TransactionLoading extends Web3State {
  TransactionLoading();
}

class TransactionSuccess extends Web3State {
  const TransactionSuccess();
}

class TransactionFailed extends Web3State {
  const TransactionFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

/// TODO: <another> contract
/// You can add and specify more contracts here