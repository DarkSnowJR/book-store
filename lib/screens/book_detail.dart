import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({required this.book, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<bool> isInShoppingCart;

  @override
  void initState() {
    super.initState();
    isInShoppingCart = checkShoppingCartStatus();
  }

  Future<bool> checkShoppingCartStatus() async {
    try {
      final Uri uri = Uri.parse('http://localhost:8000/cart/items/1/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> cartItems = json.decode(response.body);

        // Check if the book is in the cart based on its ID
        var isInCart =
            cartItems.any((cartItem) => cartItem['id'] == widget.book.id);
        return isInCart;
      } else {
        // Handle error response
        throw Exception('Failed to load cart items');
      }
    } catch (error) {
      // Handle other errors
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> updateShoppingCart(bool addToCart) async {
    try {
      final Uri uri = Uri.parse('http://localhost:8000/cart/update/1/');

      final response = await http.post(
        uri,
        body: jsonEncode({
          'book_id': widget.book.id,
          'add_to_cart': addToCart,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Update the local state and show a SnackBar
        setState(() {
          isInShoppingCart = Future.value(addToCart);
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: addToCart ? Colors.green : Colors.red,
            duration: const Duration(milliseconds: 500),
            content: Text(addToCart
                ? 'Added to Shopping Cart'
                : 'Removed from Shopping Cart'),
          ),
        );
      } else {
        // Handle error response
        throw Exception('Failed to update shopping cart');
      }
    } catch (error) {
      // Handle other errors
      throw Exception('Failed to update shopping cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the book image
            Image.network(
              widget.book.imageUrl,
              height: 600,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Display the book details
            Text(
              'Author: ${widget.book.author}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${widget.book.description}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: \$${widget.book.price}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Add to shopping cart button
            FutureBuilder<bool>(
              future: isInShoppingCart,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loading indicator if the future is still loading
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Return an error message if there's an error
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Return the appropriate icon based on the shopping cart status
                  return TextButton.icon(
                    onPressed: () => updateShoppingCart(!snapshot.data!),
                    icon: Icon(snapshot.data!
                        ? Icons.remove_shopping_cart
                        : Icons.add_shopping_cart),
                    label: Text(
                        snapshot.data! ? 'Remove from Cart' : 'Add to Cart'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
