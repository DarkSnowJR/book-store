import 'package:flutter/material.dart';
import '../widgets/book_list.dart';
import '../models/book.dart';
import '../widgets/settings_drawer.dart';
import '../apis/book_api.dart';

// List<Book> books = [
//   Book(
//     'The Great Gatsby',
//     'F. Scott Fitzgerald',
//     'The Great Gatsby is a 1925 novel by American author F. Scott Fitzgerald.',
//     'https://cdn.domestika.org/c_fill,dpr_auto,f_auto,q_auto/v1650456307/content-items/011/139/582/Great%2520Gatsby-01-original.jpg?1650456307',
//     1,
//     10,
//   ),
//   Book(
//     'The Catcher in the Rye',
//     'J. D. Salinger',
//     'The Catcher in the Rye is a novel by J. D. Salinger.',
//     'https://betweenthecovers.cdn.bibliopolis.com/pictures/439966.jpg?auto=webp&v=1574435806',
//     2,
//     30,
//   ),
//   Book(
//     'Pride and Prejudice',
//     'Jane Austen',
//     'Pride and Prejudice is a novel by Jane Austen.',
//     'https://images.thalia.media/00/-/0efedf75af6e41f7b22b011b7a7eab8d/pride-and-prejudice-gebundene-ausgabe-englisch.jpeg',
//     3,
//     40,
//   ),
//   Book(
//     'The Midnight Library',
//     'Matt Haig',
//     'The Midnight Library is a novel by Matt Haig.',
//     'https://savethecat.com/wp-content/uploads/2021/06/81YzHKeWq7L-1016x1536.jpg',
//     4,
//     50,
//   ),
//   Book(
//     'The Hunger Games',
//     'Suzanne Collins',
//     'The Hunger Games is a novel by Suzanne Collins.',
//     'https://images.thalia.media/00/-/60c88eca72084c76b3883f3b66bce949/hunger-games-epub-suzanne-collins.jpeg',
//     5,
//     60,
//   ),
//   Book(
//     'The Lord of the Rings',
//     'J. R. R. Tolkien',
//     'The Lord of the Rings is a novel by J. R. R. Tolkien.',
//     'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1566425108i/33.jpg',
//     6,
//     70,
//   ),
//   Book(
//     'The Hobbit',
//     'J. R. R. Tolkien',
//     'The Hobbit is a novel by J. R. R. Tolkien.',
//     'https://images.thalia.media/00/-/cdcf3a2e269d45618d43a87914c939a0/the-hobbit-or-there-and-back-again-taschenbuch-j-r-r-tolkien-englisch.jpeg',
//     7,
//     80,
//   )
// ];

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
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
      drawer: const SettingsDrawer(),
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: fetchBooks(), // Call the function to fetch books
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Book> books = snapshot.data ?? [];
              return Center(
                child: BookList(
                    books: books), // Assuming you have a BookList widget
              );
            }
          },
        ),
      ),
    );
  }
}
