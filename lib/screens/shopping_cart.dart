import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/book.dart';
import '../screens/book_detail.dart';

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
    try {
      final Uri uri = Uri.parse('http://localhost:8000/cart/items/1/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> cartItems = json.decode(response.body);

        // Convert the cart items to a list of Book objects
        List<Book> shoppingCart = cartItems.map((item) {
          return Book(
            item['title'],
            item['author'],
            item['description'],
            item['imageUrl'],
            item['id'],
            item['price'],
          );
        }).toList();

        return shoppingCart;
      } else {
        // Handle error response
        throw Exception('Failed to load cart items');
      }
    } catch (error) {
      // Handle other errors
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> removeFromShoppingCart(Book book, BuildContext context) async {
  try {
    final Uri uri = Uri.parse('http://localhost:8000/cart/update/1/');
    final response = await http.post(
      uri,
      body: jsonEncode({
        'book_id': book.id,
        'add_to_cart': false, // Set to false since it's a removal
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Update the Future variable to trigger a rebuild
      setState(() {
        shoppingCartFuture = getShoppingCart();
      });

      // Show a SnackBar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500),
          content: Text('Removed from Shopping Cart'),
        ),
      );
    } else {
      // Handle error response
      throw Exception('Failed to remove item from the cart');
    }
  } catch (error) {
    // Handle other errors
    print(error);
    throw Exception('Failed to remove item from the cart');
  }
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
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(book: book),
                              )).then((value) {
                            setState(() {
                              shoppingCartFuture = getShoppingCart();
                            });
                          }),
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
