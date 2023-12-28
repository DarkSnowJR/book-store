import '../models/book.dart';
import 'package:hive/hive.dart';

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0; // Unique identifier for the Book class

  @override
  Book read(BinaryReader reader) {
    // Deserialize the Book object from binary
    final title = reader.readString();
    final author = reader.readString();
    final description = reader.readString();
    final imageUrl = reader.readString();
    final id = reader.readInt();
    final price = reader.readInt();

    return Book(title, author, description, imageUrl, id, price);
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    // Serialize the Book object to binary
    writer.writeString(obj.title);
    writer.writeString(obj.author);
    writer.writeString(obj.description);
    writer.writeString(obj.imageUrl);
    writer.writeInt(obj.id);
    writer.writeInt(obj.price);
  }
}
