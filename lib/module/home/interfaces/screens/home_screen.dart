import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled1/screens/home/custom_home_screen.dart';
import '/module/auth/interfaces/screens/authentication_screen.dart';
import '/infrastructures/service/cubit/web3_cubit.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postgres/postgres.dart'; // postgres SQL
import '/configs/themes.dart';
import 'package:web3dart/web3dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.session,
    required this.connector,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final dynamic session;
  final WalletConnect connector;
  final String uri;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountAddress = '';
  String networkName = '';
  TextEditingController greetingTextController = TextEditingController();
  
  ButtonStyle buttonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all(
      Colors.white.withAlpha(60),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );

// Database connection object
PostgreSQLConnection connection = PostgreSQLConnection(
  '10.0.2.2', 5432, 'GeekchainDB', username: 'postgres', password: '1234');

 void connectDB() async{
    try {
    await connection.query('SELECT 1');
    print('Connection is already open.');
  } catch (_) {
    await connection.open();
    print('Connection opened successfully!');
  }
  saveWalletAddress(1);
 }
 dynamic sellerAddressQuery(int row) async
 {
  List<Map<String, Map<String, dynamic>>> result = await connection
    .mappedResultsQuery('SELECT s.walletaddress FROM public.history h JOIN public.seller s ON h.sellerid = s.id WHERE h.row = @aRow',
         substitutionValues: {
       'aRow': row,
       });


  if (result.length == 1) {
     for (Map<String, Map<String, dynamic>> element in result) {
      print(result);         
     }
   }
   return result;
 }
void saveWalletAddress(int id) async
{
    List<Map<String, Map<String, dynamic>>> result = await connection
    .mappedResultsQuery('UPDATE public.customer SET walletaddress = @aAddress WHERE id = @aID',
         substitutionValues: {
       'aAddress': accountAddress,
       'aID': id,
       });
}
  /*void updateGreeting() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().updateGreeting(greetingTextController.text);
    greetingTextController.text = '';
  }*/

  // BUYER FUNCTIONS
  void createBuyerContract() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().createBuyerContract();
  }
  void payShopping() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().payShopping();
  }
  void requestReturn(int row) {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);  
    
    context.read<Web3Cubit>().requestReturn(sellerAddressQuery(row), row);
  }
  void getBuyerContract() {
    context.read<Web3Cubit>().getBuyerContract();
  }
  void getBuyerContractBalance() {
    context.read<Web3Cubit>().getBuyerContractBalance();
  }
  void scanTransaction() {
    // DB conn
    context.read<Web3Cubit>().scanTransaction(0);
  }
  void loadToBuyerContract()
  {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    // get input for amount
    EtherAmount amount = EtherAmount.inWei(BigInt.from(100));
    context.read<Web3Cubit>().loadToBuyerContract(amount);
  }
  // SELLER FUNCTIONS
  void createSellerContract() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().createSellerContract();
  }
    void getSellerContract() {
    context.read<Web3Cubit>().getSellerContract();
  }
    void returnTokensToCustomer() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    // DB conn
    context.read<Web3Cubit>().returnTokensToCustomer('buyerAddr', 0);
  }
    void sendTokensToSeller() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    // DB conn
    context.read<Web3Cubit>().sendTokensToSeller('buyerAddr', 0);
  }

  @override
  void initState() {
    super.initState();

    /// Execute after frame is rendered to get the emit state of InitializeProviderSuccess
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<Web3Cubit>().initializeProvider(
            connector: widget.connector,
            session: widget.session,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<Web3Cubit, Web3State>(
      listener: (BuildContext context, Web3State state) {
        if (state is SessionTerminated) {
          Future<void>.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AuthenticationScreen(),
              ),
            );
          });
        } else if (state is TransactionFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is FetchingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is InitializeProviderSuccess) {
          setState(() {
            accountAddress = state.accountAddress;
            networkName = state.networkName;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          // ignore: use_decorated_box
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: flirtGradient),
            ),
          ),
          toolbarHeight: 0,
          automaticallyImplyLeading: false,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.1,
                    vertical: width * 0.05,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    gradient: const LinearGradient(colors: flirtGradient),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 13),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(60),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Account Address: ',
                              style: theme.textTheme.titleSmall,
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: width * 0.6,
                                child: Text(
                                  accountAddress,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(60),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Chain: ',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              networkName,
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.03,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: flirtGradient),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                          top: Radius.circular(10),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                              0,
                              13,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: width,
                            child: BlocBuilder<Web3Cubit, Web3State>(
                              buildWhen:
                                  (Web3State previous, Web3State current) =>
                                      current is TransactionLoading ||
                                      current is TransactionSuccess ||
                                      current is TransactionFailed,
                              builder: (BuildContext context, Web3State state) {
                                if (state is TransactionLoading) {
                                  return ElevatedButton.icon(
                                    onPressed: () {},
                                    style: buttonStyle,
                                    icon: SizedBox(
                                      height: height * 0.03,
                                      width: height * 0.03,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    label: const Text(''),
                                  );
                                }
                                return ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CustomHomeScreen()),
                                      );
                                    },
                                  style: buttonStyle, child: Text("Successfully connected. Go back to home."),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    gradient: const LinearGradient(colors: flirtGradient),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: width,
                        child: ElevatedButton.icon(
                          onPressed: context.read<Web3Cubit>().closeConnection,
                          icon: const Icon(
                            Icons.power_settings_new,
                          ),
                          label: Text('Disconnect',
                              style: theme.textTheme.titleMedium),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white.withAlpha(60),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ),
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
