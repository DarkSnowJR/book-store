import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:hive/hive.dart';

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
    var box = await Hive.openBox<Book>('shopping_cart');
    var isInCart = box.values.any((cartBook) => cartBook.id == widget.book.id);
    return isInCart;
  }

  void addToShoppingCart() async {
    var box = await Hive.openBox<Book>('shopping_cart');
    box.add(widget.book);
    setState(() {
      isInShoppingCart = Future.value(true);
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 500),
        content: Text('Added to Shopping Cart'),
      ),
    );
  }

  void removeFromShoppingCart() async {
    var box = await Hive.openBox<Book>('shopping_cart');
    box.deleteAt(box.values
        .toList()
        .indexWhere((cartBook) => cartBook.id == widget.book.id));
    setState(() {
      isInShoppingCart = Future.value(false);
    });
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
          )),
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
                    onPressed: snapshot.data!
                        ? removeFromShoppingCart
                        : addToShoppingCart,
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
