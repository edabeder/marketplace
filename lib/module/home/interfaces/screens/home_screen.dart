import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/NewCartScreens/NewCartModel.dart';
import 'package:untitled1/NewCartScreens/NewDBHelper.dart';
import 'package:untitled1/screens/home/custom_home_screen.dart';
import 'package:untitled1/screens/sign_in/components/sign_form.dart';
import '../../../../screens/profile/order_screen.dart';
import '/module/auth/interfaces/screens/authentication_screen.dart';
import '/infrastructures/service/cubit/web3_cubit.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postgres/postgres.dart'; // postgres SQL
import '/configs/themes.dart';
import 'package:web3dart/web3dart.dart';
import 'package:untitled1/NewCartScreens/Product.dart';
import 'package:untitled1/module/PostgresDBConnector.dart';
import 'package:untitled1/screens/sign_in/components/sign_form.dart';
import 'package:http/http.dart' as http;

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
  late String contractAddress = '';
  String amountInput = '';
  String userId = '';
  late BigInt balance = BigInt.zero;
  Product product = Product.empty();
  late PostgreSQLConnection connection;
  bool isSeller = false;
  DBHelper? dbHelper = DBHelper();
  late List<Cart> cartList = [];

  TextEditingController greetingTextController = TextEditingController();
  bool showCreateContractButton = false;

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
  void setConnection() async {
    connection = await PostgresDBConnector().connection;

    cartList = await dbHelper!.getCartList();

    isSeller = Product.isSeller;
    await fetchGlobalUserId();
  }
 Future<void> fetchGlobalUserId() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/get-global-user-id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String customerId = jsonResponse['customerId']
          .toString(); // Convert the customer ID to String

        userId = customerId;
        GlobalData.globalUserId = customerId;

    } 
  }
  dynamic sellerAddressHistoryQuery(int row) async {
    List<
        Map<String,
            Map<String, dynamic>>> result = await connection.mappedResultsQuery(
        'SELECT s.walletaddress FROM public.history h JOIN public.seller s ON h.sellerid = s.id WHERE h.row = @aRow',
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

  dynamic buyerAddressHistoryQuery(int row) async {
    List<
        Map<String,
            Map<String, dynamic>>> result = await connection.mappedResultsQuery(
        'SELECT c.walletaddress FROM public.history h JOIN public.customer c ON h.customerid = c.id WHERE h.row = @aRow',
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

  void saveWalletAddress(int id) async {
    List<
        Map<String,
            Map<String, dynamic>>> result = await connection.mappedResultsQuery(
        'UPDATE public.customer SET walletaddress = @aAddress WHERE id = @aID',
        substitutionValues: {
          'aAddress': accountAddress,
          'aID': id,
        });
    print(
        "Successfully saved address $accountAddress to customer ${id.toString()}");
  }
  /*void updateGreeting() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().updateGreeting(greetingTextController.text);
    greetingTextController.text = '';
  }*/

  // BUYER FUNCTIONS
  void checkButtonStatus() async {
    EthereumAddress responseAddress =
        await context.read<Web3Cubit>().getBuyerContract();

    if (responseAddress ==
        EthereumAddress.fromHex('0x0000000000000000000000000000000000000000')) {
      setState(() {
        showCreateContractButton = true;
        contractAddress = responseAddress.hex;
      });
      print("no contract address");
    } else {
      setState(() {
        showCreateContractButton = false;
        contractAddress = responseAddress.hex;
      });
      print("contract address exists" + contractAddress);
    }
  }

  void createBuyerContract() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);
    context.read<Web3Cubit>().createBuyerContract();
  }

  void getBuyerContract() async {
    EthereumAddress e = await context.read<Web3Cubit>().getBuyerContract();
    contractAddress = e.hex;
  }

  void payShopping() async{
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);
    await product.buyProducts(); 
    await context
        .read<Web3Cubit>()
        .payShopping(EthereumAddress.fromHex("0x3F3f8C25cff70508A7F48Da0EB7EECa38330C5ad"), "hello", 
        BigInt.from(20))
        .then((value) => cartList = []);
  }

  void requestReturn(int row) {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context
        .read<Web3Cubit>()
        .requestReturn(sellerAddressHistoryQuery(row), row);
  }

  void getBuyerContractBalance() async {
    BigInt getBalance =
        await context.read<Web3Cubit>().getBuyerContractBalance();
    setState(() {
      balance = getBalance;
    });
  }

  void scanTransaction() {
    // DB conn
    context.read<Web3Cubit>().scanTransaction(0);
  }

  void loadToBuyerContract(int input) {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    // get input for amount
    EtherAmount amount = EtherAmount.inWei(BigInt.from(input));
    context.read<Web3Cubit>().loadToBuyerContract(amount);
  }

  // SELLER FUNCTIONS
  void createSellerContract() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().createSellerContract();
  }

  void getSellerContract() async {
    EthereumAddress e = await context.read<Web3Cubit>().getSellerContract();
    contractAddress = e.hex;
  }

  void returnTokensToCustomer(int row) {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    // DB conn
    context
        .read<Web3Cubit>()
        .returnTokensToCustomer(buyerAddressHistoryQuery(row), row);
  }

  void sendTokensToSeller(int row) {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    // DB conn
    context
        .read<Web3Cubit>()
        .sendTokensToSeller(buyerAddressHistoryQuery(row), row);
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
 
    Future.delayed(Duration(seconds: 1), () {
    setConnection();
    saveWalletAddress(int.parse(GlobalData.globalUserId));
      checkButtonStatus();
      if (!isSeller) {
        getBuyerContractBalance();
      }
    });
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
                                return Column(
                                  children: [
                                    const Text(
                                      "Connected to MetaMask successfully!",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomHomeScreen()),
                                        );
                                      },
                                      style: buttonStyle,
                                      child: const Text("Back To App"),
                                    ),
                                    const SizedBox(height: 16),
                                    showCreateContractButton
                                        ? const Text(
                                            "Create a contract to start shopping!",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            "Your contract address: ",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                    const SizedBox(height: 16),
                                    showCreateContractButton
                                        ? ElevatedButton(
                                            onPressed: () {
                                              if (!isSeller) {
                                                createBuyerContract();
                                                getBuyerContract();
                                              } else {
                                                createSellerContract();
                                                getSellerContract();
                                              }

                                              setState(() {
                                                showCreateContractButton =
                                                    false;
                                              });
                                            },
                                            style: buttonStyle,
                                            child: const Text(
                                                "Create My Contract Now"),
                                          )
                                        : Text(
                                            contractAddress,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                    const SizedBox(height: 16),
                                    showCreateContractButton || isSeller
                                        ? SizedBox(height: 1)
                                        : TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                amountInput = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Enter an amount (in wei)',
                                            ),
                                          ),
                                    const SizedBox(height: 16),
                                    showCreateContractButton
                                        ? SizedBox(height: 1)
                                        : ElevatedButton(
                                            onPressed: () {
                                              if (!isSeller) {
                                                try {
                                                  int inputValue =
                                                      int.parse(amountInput);
                                                  loadToBuyerContract(
                                                      inputValue);
                                                  print(
                                                      "Loaded: " + amountInput);
                                                  getBuyerContractBalance();
                                                } catch (e) {
                                                  print(e);
                                                  // Display an error message to the user
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Error: Invalid input.'),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                //sendTokensToSeller();
                                              }
                                            },
                                            style: buttonStyle,
                                            child: !isSeller
                                                ? const Text(
                                                    "Load To My Contract")
                                                : const Text(
                                                    "Load To My Account"),
                                          ),
                                    const SizedBox(height: 16),
                                    showCreateContractButton
                                        ? SizedBox(height: 1)
                                        : Text(
                                            "Balance: " + balance.toString(),
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                    const SizedBox(height: 16),
                                    showCreateContractButton || isSeller
                                        ? SizedBox(height: 1)
                                        : ElevatedButton(
                                            onPressed: cartList.isEmpty
                                                ? null
                                                : () {
                                                    payShopping();
                                                  },
                                            style: buttonStyle,
                                            child: const Text("Purchase Cart"),
                                          ),
                                  ],
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
