// Define the Note class
import 'package:hive/hive.dart';

class Note extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String content;

  @HiveField(3)
  late String date; // Field to store the creation date

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });
}

// Define the adapter
class NoteAdapter extends TypeAdapter<Note> {
  @override
  final typeId = 0;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      date: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.date);
  }
}
