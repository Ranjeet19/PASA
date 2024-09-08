
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_assist/utils/colors.dart';
import 'package:my_assist/view/Notes/edit_page.dart';
import 'package:my_assist/view/notes.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.back)),
        foregroundColor: primaryColor,
        backgroundColor: mobileBackgroundColor,
        // title: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //       note.date,
        //       style: const TextStyle(fontSize: 14, color: Colors.white70),
        //     ),
        //     Text(
        //       note.title,
        //       style: const TextStyle(fontSize: 18, color: Colors.white),
        //     ),
        //   ],
        // ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'Edit') {
                // Navigate to EditNotePage with the current note
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNotePage(note: note),
                  ),
                );
              } else if (value == 'Delete') {
                final box = Hive.box<Note>('notes');
                await box.delete(note.key);
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'Delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(note.date,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            Text(note.title,
                style: const TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 10),
            Text(note.content,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
