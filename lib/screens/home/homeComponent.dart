import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import '../../NewCartScreens/NewCartModel.dart';
import '../../NewCartScreens/NewDBHelper.dart';
import '../../NewCartScreens/Product.dart';
import '../../module/PostgresDBConnector.dart';
import '/components/product_card.dart';

import '../../../size_config.dart';
import 'components/section_title.dart';
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/NewCartScreens/new_cart_screen.dart';
import '/NewCartScreens/NewDBHelper.dart';
import '/NewCartScreens/NewCartModel.dart';
import '/NewCartScreens/NewCartProvider.dart';


class HomeProducts extends StatefulWidget {



  @override
  State<HomeProducts> createState() => _HomeProductsState();
}

class _HomeProductsState extends State<HomeProducts> {
  List<String> productName = ['Dualsense Wireless Controller' , 'Air Jordan 1 Low SE' , 'Iphone 14 Pro Max 128GB Black' ,] ;
  List<String> productUnit = ['KG' , 'Dozen' , 'KG' ] ;
  List<int> productPrice = [80, 70 , 100] ;
  List<String> productImage = [
    'https://gmedia.playstation.com/is/image/SIEPDC/dualsense-thumbnail-ps5-01-en-17jul20?' ,
    'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/34dec221-0f96-4c6c-b76e-40b42f679e26/air-jordan-1-low-se-ayakkab%C4%B1s%C4%B1-j6GSq5.png' ,
    'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcRg0S6oIC9gdRAXKhz-Wrjrz8F_z1DE3iTWzjc0xynSCOSS2Ox6s8wrGDdovESTCE5cwRCmStmExkjp79_sgFQSfiR9doGRbBgO7FHbYnCIgLh1bZVHdHAg&usqp=CAE' ,
  ] ;

  DBHelper? dbHelper = DBHelper();

  var product;
  late PostgreSQLConnection connection;

  void connectDB() async{

    connection = await PostgresDBConnector().connection;
    product = Product.empty();
    product.setConnection();

  }

  @override
  void initState() {
    super.initState();
    connectDB();
  }


  @override
  Widget build(BuildContext context) {
    final CartProvider cart  = Provider.of<CartProvider>(context);
    return SizedBox(
      height: 500,
      width: 500,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: productName.length,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Image(
                                height: 100,
                                width: 100,
                                image: NetworkImage(productImage[index].toString()),
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productName[index].toString() ,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 5,),
                                    Text(' '+r'$'+ productPrice[index].toString() ,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 5,),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: (){
                                          print(index);
                                          print(index);
                                          print(productName[index].toString());
                                          print( productPrice[index].toString());
                                          print( productPrice[index]);
                                          print('1');
                                          print(productUnit[index].toString());
                                          print(productImage[index].toString());

                                          dbHelper!.insert(
                                              Cart(
                                                  id: index,
                                                  productId: index.toString(),
                                                  productName: productName[index].toString(),
                                                  initialPrice: productPrice[index],
                                                  productPrice: productPrice[index],
                                                  quantity: 1,
                                                  unitTag: productUnit[index].toString(),
                                                  image: productImage[index].toString())
                                          ).then((Cart value){

                                            cart.addTotalPrice(double.parse(productPrice[index].toString()));
                                            cart.addCounter();

                                            const SnackBar snackBar = SnackBar(backgroundColor: Colors.green,content: Text('Product is added to cart'), duration: Duration(seconds: 1),);

                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                          }).onError((Object? error, StackTrace stackTrace){
                                            print('error$error');
                                            const SnackBar snackBar = SnackBar(backgroundColor: Colors.red ,content: Text('Product is already added in cart'), duration: Duration(seconds: 1));

                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          });
                                        },
                                        child:  Container(
                                          height: 35,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.orange.shade300,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: const Center(
                                            child:  Text('Add to cart' , style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )

                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),

        ],
      ),
    );
  }
}
