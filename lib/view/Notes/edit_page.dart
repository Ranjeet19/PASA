
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:my_assist/utils/colors.dart';
import 'package:my_assist/view/notes.dart';
import 'package:uuid/uuid.dart';

class EditNotePage extends StatefulWidget {
  final Note? note; // Make this optional to handle both new and edit

  const EditNotePage({super.key, this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // If editing a note, populate the text fields with the note's data
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'New Note',
          style: TextStyle(color: primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: primaryColor,
            ),
            onPressed: _saveNote,
          ),
        ],
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: primaryColor, )),
              style: const TextStyle(color: primaryColor),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content' , labelStyle: TextStyle(color: primaryColor, )),
              style: const TextStyle(color: primaryColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: mobileBackgroundColor, // White text color
                elevation: 5, // Shadow elevation
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  side: const BorderSide(
                    color: primaryColor, // Red border color
                    width: 2, // Border width
                  ),
                ),
              ),
              onPressed: _saveNote,
              child: const Text(
                'Save Note',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() async {
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (widget.note == null) {
      // Creating a new note
      final note = Note(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        date: currentDate,
      );

      final box = Hive.box<Note>('notes');
      await box.add(note);
    } else {
      // Editing an existing note
      widget.note!.title = _titleController.text;
      widget.note!.content = _contentController.text;
      widget.note!.save(); // Save changes to Hive
    }

    Navigator.pop(context);
  }
}
