import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

Future<List<Book>> fetchBooks() async {
  final Uri uri = Uri.parse('http://localhost:8000/books/');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    List<Book> books = data.map((bookData) {
      return Book(
        bookData['title'],
        bookData['author'],
        bookData['description'],
        bookData['imageUrl'],
        bookData['id'],
        bookData['price'],
      );
    }).toList();

    return books;
  } else {
    throw Exception('Failed to load books');
  }
}
