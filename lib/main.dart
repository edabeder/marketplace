import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'routes.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import '/NewCartScreens/NewCartProvider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/configs/themes.dart';
import '/configs/web3_config.dart';
import '/infrastructures/repository/secure_storage_repository.dart';
import '/infrastructures/service/cubit/secure_storage_cubit.dart';
import '/module/auth/interfaces/screens/authentication_screen.dart';
import '/module/auth/service/cubit/auth_cubit.dart';
import '/infrastructures/service/cubit/web3_cubit.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

Future<void> main() async {
  /// Load env file
  await dotenv.load();

  runApp(
    MyApp(
      walletConnect: await walletConnect,
      greeterContract: await deployedGreeterContract,
      customerContract: await deployedCustomerContract,
      web3client: web3Client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.walletConnect,
    required this.greeterContract,
    required this.customerContract,
    required this.web3client,
    Key? key,
  }) : super(key: key);
  final WalletConnect walletConnect;
  final DeployedContract greeterContract;
  final DeployedContract customerContract;
  final Web3Client web3client;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Web3Cubit>(
          create: (BuildContext context) => Web3Cubit(
            web3Client: web3client,
            greeterContract: greeterContract,
            customerContract: customerContract,
          ),
        ),
        Provider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(
            storage: SecureStorageRepository(),
            connector: walletConnect,
          ),
        ),
        Provider<SecureStorageCubit>(
          create: (BuildContext context) => SecureStorageCubit(
            storage: SecureStorageRepository(),
          ),
        ),
        ChangeNotifierProvider.value(
          value: CartProvider(),
        ),
      ],
      child: MaterialApp(
        title: '',
        debugShowCheckedModeBanner: false,
        theme: buildDefaultTheme(context),
        home: SplashScreen(),
      ),
    );

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    /// Lock app to portrait mode
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return const AuthenticationScreen();
  }
}