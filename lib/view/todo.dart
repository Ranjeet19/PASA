// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_assist/utils/colors.dart';

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TodoListScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: mobileBackgroundColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class Todo {
  String title;
  String priority;
  DateTime dueDate;

  Todo({
    required this.title,
    required this.priority,
    required this.dueDate,
  });
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now();

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Todo(
          title: _taskController.text,
          priority: _selectedPriority,
          dueDate: _selectedDate,
        ));
      });
      _taskController.clear();
      _sortTasks();
    }
  }

  void _editTask(int index) {
    _taskController.text = _tasks[index].title;
    _selectedPriority = _tasks[index].priority;
    _selectedDate = _tasks[index].dueDate;

    _showTaskDialog(editMode: true, index: index);
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _updateTask(int index) {
    setState(() {
      _tasks[index].title = _taskController.text;
      _tasks[index].priority = _selectedPriority;
      _tasks[index].dueDate = _selectedDate;
    });
    _taskController.clear();
    _sortTasks();
  }

  void _sortTasks() {
    setState(() {
      _tasks.sort((a, b) {
        if (a.priority == b.priority) {
          return a.dueDate.compareTo(b.dueDate);
        }
        return _priorityValue(a.priority).compareTo(_priorityValue(b.priority));
      });
    });
  }

  int _priorityValue(String priority) {
    if (priority == 'High') return 0;
    if (priority == 'Medium') return 1;
    return 2;
  }

  void _showTaskDialog({bool editMode = false, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editMode ? 'Edit Task' : 'Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedPriority,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
              items: <String>['High', 'Medium', 'Low']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _selectDate,
              child: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (editMode) {
                _updateTask(index!);
              } else {
                _addTask();
              }
            },
            child: Text(editMode ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: InkWell(
        //   onTap: (){
        //     Navigator.pop(context);
        //   },
        //   child: const Icon(CupertinoIcons.chevron_back, color: primaryColor,)),
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: const Text(
          'To-Do',
          style: TextStyle(color: primaryColor),
        ),
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
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        _tasks[index].title,
                        style:
                            const TextStyle(color: primaryColor, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Priority: ${_tasks[index].priority} - Due: ${DateFormat('yyyy-MM-dd').format(_tasks[index].dueDate)}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTask(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 5),
        child: FloatingActionButton(
          backgroundColor: mobileBackgroundColor,
          foregroundColor: primaryColor,
          onPressed: () => _showTaskDialog(),
          shape: const StadiumBorder(
            side: BorderSide(
              color: Colors.white, // White border around the button
              width: 3.0, // Border width
            ),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
