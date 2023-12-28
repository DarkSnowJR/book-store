import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({Key? key}) : super(key: key);

  static final GlobalKey<ShoppingCartPageState> cartKey =
      GlobalKey<ShoppingCartPageState>();

  @override
  ShoppingCartPageState createState() => ShoppingCartPageState();
}

class ShoppingCartPageState extends State<ShoppingCartPage> {
  late Future<List<Book>> shoppingCartFuture; // Added Future variable

  @override
  void initState() {
    super.initState();
    shoppingCartFuture = getShoppingCart(); // Initialize Future in initState
  }

  Future<List<Book>> getShoppingCart() async {
    var box = await Hive.openBox<Book>('shopping_cart');
    return box.values.toList();
  }

  void removeFromShoppingCart(Book book, BuildContext context) async {
    var box = await Hive.openBox<Book>('shopping_cart');
    box.deleteAt(
        box.values.toList().indexWhere((cartBook) => cartBook.id == book.id));

    // Update the Future variable to trigger a rebuild
    setState(() {
      shoppingCartFuture = getShoppingCart();
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 500),
        content: Text('Removed from Shopping Cart'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.red, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: shoppingCartFuture, // Use the updated Future variable
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<Book> shoppingCart = snapshot.data ?? [];
              if (shoppingCart.isEmpty) {
                return const Center(
                  child: Text('Your shopping cart is empty.'),
                );
              }

              // Calculate the total price
              double totalPrice = shoppingCart.fold(
                  0, (previousValue, book) => previousValue + book.price);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: shoppingCart.length,
                      itemBuilder: (context, index) {
                        final Book book = shoppingCart[index];
                        return ListTile(
                          leading: Image.network(book.imageUrl),
                          title: Text(book.title),
                          subtitle: Text('Price: \$${book.price}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_shopping_cart),
                            onPressed: () {
                              removeFromShoppingCart(book, context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
