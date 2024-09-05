import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Countdown App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];

  void _addTask(String title, String description, DateTime date) {
    setState(() {
      tasks.add({
        'title': title,
        'description': description,
        'date': date,
      });
    });
  }

  void _editTask(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          task: tasks[index],
          onSave: (title, description, date) {
            setState(() {
              tasks[index] = {
                'title': title,
                'description': description,
                'date': date,
              };
            });
          },
        ),
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Countdown'),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No Event yet, add some!', style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return CountdownTile(
                  task: tasks[index],
                  onEdit: () => _editTask(index),
                  onDelete: () => _deleteTask(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          onSave: (title, description, date) {
            _addTask(title, description, date);
          },
        ),
      ),
    );
    if (result != null) {
      _addTask(result['title'], result['description'], result['date']);
    }
  }
}

class CountdownTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CountdownTile({super.key, 
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  CountdownTileState createState() => CountdownTileState();
}

class CountdownTileState extends State<CountdownTile> {
  late Timer _timer;
  late DateTime _taskDate;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _taskDate = widget.task['date'];
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final difference = _taskDate.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    setState(() {
      if (difference.isNegative) {
        _countdown = 'Expired';
      } else {
        _countdown = '$days days, $hours hours, $minutes minutes, $seconds seconds';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edit/Delete buttons in top right corner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Countdown Timer in large font
                Expanded(
                  child: Text(
                    _countdown,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
            // Task Title in bold font
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                widget.task['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
            // Task Description in normal font
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                widget.task['description'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;
  final Function(String, String, DateTime) onSave;

  const AddTaskScreen({super.key, this.task, required this.onSave});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskTitle = '';
  String _taskDescription = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskTitle = widget.task!['title'];
      _taskDescription = widget.task!['description'];
      _selectedDate = widget.task!['date'];
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_taskTitle, _taskDescription, _selectedDate);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _taskTitle,
                decoration: const InputDecoration(labelText: 'Task Title'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a task title';
                  return null;
                },
                onChanged: (value) {
                  _taskTitle = value;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _taskDescription,
                decoration: const InputDecoration(labelText: 'Task Description'),
                onChanged: (value) {
                  _taskDescription = value;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  'Select Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.task == null ? 'Save Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
