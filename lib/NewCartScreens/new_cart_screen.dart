import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:untitled1/main.dart';
import '/NewCartScreens/NewCartModel.dart';
import '/NewCartScreens/NewDBHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/NewCartScreens/Product.dart';
import '/NewCartScreens/NewCartProvider.dart';


class NewCartScreen extends StatefulWidget {
  const NewCartScreen({Key? key}) : super(key: key);

  @override
  _NewCartScreenState createState() => _NewCartScreenState();
}

class _NewCartScreenState extends State<NewCartScreen> {

  DBHelper? dbHelper = DBHelper();
  var product;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    product = Product.empty();
  }
  @override
  Widget build(BuildContext context) {
    final CartProvider cart  = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
        actions: [
          Center(
            child: badges.Badge(
              badgeContent: Consumer<CartProvider>(
                builder: (BuildContext context, CartProvider value , Widget? child){
                  return Text(value.getCounter().toString(),style: const TextStyle(color: Colors.white));
                },

              ),
              animationDuration: const Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 20.0)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            FutureBuilder(
                future:cart.getData() ,
                builder: (BuildContext context , AsyncSnapshot<List<Cart>> snapshot){
                  if(snapshot.hasData){

                    if(snapshot.data!.isEmpty){
                      return Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [

                            const SizedBox(height: 20,),
                            Text('Your cart is empty 😌' ,style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 20,),
                            Text('Explore products and shop your\nfavourite items' , textAlign: TextAlign.center ,style: Theme.of(context).textTheme.titleSmall)

                          ],
                        ),
                      );
                    }else {
                      return Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.length,
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
                                            image: NetworkImage(snapshot.data![index].image.toString()),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(snapshot.data![index].productName.toString() ,
                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                    ),
                                                    InkWell(
                                                        onTap: (){
                                                          dbHelper!.delete(snapshot.data![index].id!);
                                                          cart.removerCounter();
                                                          cart.removeTotalPrice(double.parse(snapshot.data![index].price.toString()));
                                                        },
                                                        child: const Icon(Icons.delete))
                                                  ],
                                                ),

                                                const SizedBox(height: 5,),
                                                Text(' '+r''+ snapshot.data![index].price.toString() + ' wei',
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(height: 5,),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: InkWell(
                                                    onTap: (){


                                                    },
                                                    child:  Container(
                                                      height: 35,
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange.shade300,
                                                          borderRadius: BorderRadius.circular(5)
                                                      ),
                                                      child:  Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
InkWell(
                                                                onTap: (){

                                                                  int quantity =  snapshot.data![index].quantity! ;
                                                                  double price = snapshot.data![index].price!;
                                                                  quantity--;
                                                                  double? newPrice = price * quantity ;

                                                                  if(quantity > 0){
                                                                    dbHelper!.updateQuantity(
                                                                        Cart(
                                                                            id: snapshot.data![index].id!,
                                                                            productId: snapshot.data![index].id!.toString(),
                                                                            productName: snapshot.data![index].productName!,
                                                                            price: snapshot.data![index].price!,
                                                                            quantity: quantity,
                                                                            image: snapshot.data![index].image.toString())
                                                                    ).then((int value){
                                                                      newPrice = 0 ;
                                                                      quantity = 0;
                                                                      cart.removeTotalPrice(double.parse(snapshot.data![index].price!.toString()));
                                                                    }).onError((Object? error, StackTrace stackTrace){
                                                                      print(error.toString());
                                                                    });
                                                                  }

                                                                },
                                                                child: const Icon(Icons.remove , color: Colors.white,)),
                                                            Text( snapshot.data![index].quantity.toString(), style: const TextStyle(color: Colors.white)),
InkWell(
                                                                onTap: (){
                                                                  int quantity =  snapshot.data![index].quantity! ;
                                                                  double price = snapshot.data![index].price!;
                                                                  quantity++;
                                                                  double? newPrice = price * quantity ;

                                                                  dbHelper!.updateQuantity(
                                                                      Cart(
                                                                          id: snapshot.data![index].id!,
                                                                          productId: snapshot.data![index].id!.toString(),
                                                                          productName: snapshot.data![index].productName!,
                                                                          price: snapshot.data![index].price!,
                                                                          quantity: quantity,
                                                                          image: snapshot.data![index].image.toString())
                                                                  ).then((int value){
                                                                    newPrice = 0 ;
                                                                    quantity = 0;
                                                                    cart.addTotalPrice(double.parse(snapshot.data![index].price!.toString()));
                                                                  }).onError((Object? error, StackTrace stackTrace){
                                                                    print(error.toString());
                                                                  });
                                                                },
                                                                child: const Icon(Icons.add , color: Colors.white,)),
                                                          ],
                                                        ),
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
                      );
                    }

                  }
                  return const Text('') ;
                }),
            Consumer<CartProvider>(builder: (BuildContext context, CartProvider value, Widget? child){
              return Visibility(
                visible: value.getTotalPrice().toStringAsFixed(2) == '0.00' ? false : true,
                child: Column(
                  children: [
                    ReusableWidget(title: 'Total', value: r'wei'+value.getTotalPrice().toStringAsFixed(2),),
                    ElevatedButton(onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ),
                      );
                    }, child: Text("Purchase")),
                    
                  ],
                ),
              );
            })
          ],
        ),
      ) ,
    );
  }
}


class ReusableWidget extends StatelessWidget {
  const ReusableWidget({super.key, required this.title, required this.value});
  final String title , value ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title , style: Theme.of(context).textTheme.titleSmall,),
          Text(value.toString() , style: Theme.of(context).textTheme.titleSmall,)
        ],
      ),
    );
  }
}