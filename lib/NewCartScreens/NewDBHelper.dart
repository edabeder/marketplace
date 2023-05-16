import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import '/NewCartScreens/NewCartModel.dart';
import 'package:untitled1/NewCartScreens/Product.dart';

class DBHelper {

static Database? _db;
late Product product;

  Future<Database?> get db async {
    
    product = Product.empty();

    if (_db != null) {
      return _db;
    }

    product.setConnection();
    _db = await initDatabase();
        
    return _db;
  }

  initDatabase()async{
    io.Directory documentDirectory = await getApplicationDocumentsDirectory() ;
    String path = join(documentDirectory.path , 'cart.db');
    Database db = await openDatabase(path , version: 1 , onCreate: _onCreate,);
    return db ;
  }

  _onCreate (Database db , int version )async{
    await db
        .execute('CREATE TABLE cart (id INTEGER PRIMARY KEY AUTOINCREMENT,productName TEXT, initialPrice REAL, quantity INTEGER , image TEXT )');
  }

Future<Cart> insert(Cart cart) async {
  Database? dbClient = await db;
  int id = await dbClient!.insert('cart', cart.toMap());
  cart.id = id;
  product.addToCart(id);
  return cart;
}


  Future<List<Cart>> getCartList()async{
    Database? dbClient = await db ;
    final List<Map<String , Object?>> queryResult =  await dbClient!.query('cart');
    return queryResult.map((Map<String, Object?> e) => Cart.fromMap(e)).toList();

  }

  Future<int> delete(int id)async{
    Database? dbClient = await db ;
      product.removeFromCart(id);
    return await dbClient!.delete(
        'cart',
        where: 'id = ?',
        whereArgs: [id]
    );
    
  }

  Future<int> updateQuantity(Cart cart)async{
    Database? dbClient = await db ;
      product.addToCart(cart.id as int);
    return await dbClient!.update(
        'cart',
        cart.toMap(),
        where: 'id = ?',
        whereArgs: [cart.id]
    );
  }
}