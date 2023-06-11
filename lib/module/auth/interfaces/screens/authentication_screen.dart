import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/configs/themes.dart';
import '/internal/wallet_external_configuration.dart';
import '/module/auth/service/cubit/auth_cubit.dart';
import '/module/home/interfaces/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  Future<void> launchApp() async {
    final bool isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: metaMaskPackageName,
      iosUrlScheme: metamaskWalletScheme,
    );

    /// If there is an exisitng app, just launch the app.
    if (!isInstalled) {
      if (!mounted) return;
      context.read<AuthCubit>().loginWithMetamask();
      return;
    }

    /// If there is no exisitng app, launch app store.
    await LaunchApp.openApp(
      androidPackageName: metaMaskPackageName,
      iosUrlScheme: metamaskWalletScheme,
      appStoreLink: metamaskAppsStoreLink,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AuthCubit>().initiateListeners());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is EstablishConnectionSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => HomeScreen(
                session: state.session,
                connector: state.connector,
                uri: state.uri,
              ),
            ),
          );
        } else if (state is LoginWithMetamaskSuccess) {
          launchUrlString(state.url, mode: LaunchMode.externalApplication);
        } else if (state is LoginWithMetamaskFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: flirtGradient,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Ethereum Wallet',
                  style: theme.textTheme.displaySmall,
                ),
                SizedBox( child: Image.asset('assets/images/newlogo.png'),),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.2,
                    vertical: height * 0.05,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Connect your Ethereum Wallet',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () => launchApp(),
                              icon: Image.asset(
                                'assets/images/metamask-logo.png',
                                width: 16,
                              ),
                              label: Text('Login with Metamask',
                                  style: theme.textTheme.titleMedium),
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white.withAlpha(60),
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Back to shopping", style: theme.textTheme.titleMedium),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.white.withAlpha(60),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),)
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
