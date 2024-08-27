import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_assist/components/row_menu.dart';
import 'package:my_assist/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String greeting = "";

  @override
  void initState() {
    super.initState();

    _updateGreeting();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateGreeting();
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour >= 5 && hour < 12) {
        greeting = 'Good Morning...';
      } else if (hour >= 12 && hour < 17) {
        greeting = " Good Afternoon...";
      } else if (hour >= 17 && hour < 21) {
        greeting = "Good Evening...";
      } else {
        greeting = "Good Night...";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: InkWell(
                            onTap: () {},
                            child: Image.asset(
                              'assets/menu.png',
                              color: primaryColor,
                            ))),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.search,
                          color: primaryColor,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          size: 30,
                          Icons.notifications_on_outlined,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("assets/rnzt.jpg")),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontFamily: 'cursive',
                          fontWeight: FontWeight.bold, // Bold weight
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      const Text(
                        "Ranjeet Shrestha",
                        style: TextStyle(
                          color: primaryColor,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold, // Bold weight
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    height: 80,
                    width: 80,
                    child: InkWell(
                      onTap: () {
                        // print("hello dokiee");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Hello$greeting',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        child: const Icon(CupertinoIcons.multiply),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Lottie.network(
                          "https://lottie.host/aba94f25-d547-41e1-8e62-a34d042fd100/7WjtTT027G.json",
                          alignment: Alignment.center),
                    ),
                  )
                ],
              ),
              const RowMenu(), // Row menue has been imported as component
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 220,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: primaryColor,
                          ),
                          color: mobileBackgroundColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Lottie.network(
                                "https://lottie.host/aba94f25-d547-41e1-8e62-a34d042fd100/7WjtTT027G.json",
                                alignment: Alignment.center),
                            const Text(
                              "HEllo all",
                              style: TextStyle(
                                color: primaryColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Container(
                            height: 105,
                            width: 180,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: primaryColor,
                              ),
                              color: mobileBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 105,
                                width: 85,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: primaryColor,
                                  ),
                                  color: mobileBackgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 105,
                                width: 85,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: primaryColor,
                                  ),
                                  color: mobileBackgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Task To Complete...",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
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
                            child: const ListTile(
                              leading: Icon(
                                Icons.sports_cricket_rounded,
                                color: primaryColor,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle: Text(
                                'john.doe@example.com',
                                style: TextStyle(color: primaryColor),
                              ),
                              trailing: Icon(
                                Icons.navigate_next,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
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
                            child: const ListTile(
                              leading: Icon(
                                Icons.email,
                                color: primaryColor,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle: Text(
                                'john.doe@example.com',
                                style: TextStyle(color: primaryColor),
                              ),
                              trailing: Icon(
                                Icons.navigate_next,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
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
                            child: const ListTile(
                              leading: Icon(
                                Icons.email,
                                color: primaryColor,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle: Text(
                                'john.doe@example.com',
                                style: TextStyle(color: primaryColor),
                              ),
                              trailing: Icon(
                                Icons.navigate_next,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
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
                            child: const ListTile(
                              leading: Icon(
                                Icons.email,
                                color: primaryColor,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle: Text(
                                'john.doe@example.com',
                                style: TextStyle(color: primaryColor),
                              ),
                              trailing: Icon(
                                Icons.navigate_next,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
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
                            child: const ListTile(
                              leading: Icon(
                                Icons.email,
                                color: primaryColor,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle: Text(
                                'john.doe@example.com',
                                style: TextStyle(color: primaryColor),
                              ),
                              trailing: Icon(
                                Icons.navigate_next,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
