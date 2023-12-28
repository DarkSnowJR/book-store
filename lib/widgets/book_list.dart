import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book_card.dart';

class BookList extends StatelessWidget {
  final List<Book> books;

  const BookList({required this.books, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookCard(book: books[index]);
      },
    );
  }
}
