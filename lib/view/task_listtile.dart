// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';
import 'package:my_assist/view/news.dart';
import 'package:my_assist/view/rashifal.dart';
import 'package:my_assist/view/todo.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Column(
            children: [
              // --------------------------------------------------
              // HOROSCOPE
              // --------------------------------------------------

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: primaryColor,
                    ),
                    color: mobileBackgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RashifalScreen(),
                        ),
                      );
                    },
                    child: const ListTile(
                      leading: Icon(
                        CupertinoIcons.circle_grid_hex_fill,
                        color: primaryColor,
                      ),
                      title: Text(
                        'Horoscope',
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Read Your Horoscope Here!!',
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------
              // TASK TITLE
              // --------------------------------------------------

              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Text(
                    "Task To Complete!!",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------
              // TO-DO
              // --------------------------------------------------

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TodoListScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: primaryColor,
                      ),
                      color: mobileBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const ListTile(
                      leading: Icon(
                        Icons.checklist,
                        color: primaryColor,
                      ),
                      title: Text(
                        'To-Do',
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Track tasks you need to finish',
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------
              // NEWS
              // --------------------------------------------------

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NewsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: primaryColor,
                      ),
                      color: mobileBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const ListTile(
                      leading: Icon(
                        Icons.newspaper,
                        color: primaryColor,
                      ),
                      title: Text(
                        'News',
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Catch up on the latest headlines',
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}