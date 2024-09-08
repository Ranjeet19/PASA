import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_assist/utils/colors.dart';
import 'package:my_assist/view/Notes/detail_page.dart';
import 'package:my_assist/view/Notes/edit_page.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// Define the Note class
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

class MyApps extends StatelessWidget {
  const MyApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: mobileBackgroundColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Button background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Circular border
              side: const BorderSide(color: primaryColor),
            ),
          ),
        ),
      ),
      home: const NoteListPage(),
    );
  }
}

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Notes',
          style: TextStyle(color: primaryColor),
        ),
        backgroundColor: mobileBackgroundColor,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Height of the Divider
          child: Divider(
            thickness: 2.0, // Thickness of the Divider (Border)
            color: primaryColor, // Color of the Divider (Border)
            height: 1.0, // Space above the Divider
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5, left: 5,right: 5),
        child: ValueListenableBuilder(
          
          valueListenable: Hive.box<Note>('notes').listenable(),
          builder: (context, Box<Note> box, _) {
            if (box.values.isEmpty) {
              return const Center(
                  child: Text(
                'No notes found.',
                style: TextStyle(color: primaryColor),
              ));
            }
            return ListView.builder(
              
              itemCount: box.length,
              itemBuilder: (context, index) {
                final note = box.getAt(index)!;
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryColor
                      ),
                    ),
                    child: ListTile(
                      
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.date,
                            style: const TextStyle(fontSize: 12, color: primaryColor),
                          ),
                          Text(
                            note.title,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: primaryColor),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        note.content,
                        style: const TextStyle(color: primaryColor),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(note: note),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 5),
        child: FloatingActionButton(
          backgroundColor: mobileBackgroundColor,
          foregroundColor: primaryColor,
          shape: const StadiumBorder(
            side: BorderSide(
              color: primaryColor, // White border around the button
              width: 3.0, // Border width
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNotePage()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
