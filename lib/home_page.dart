import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_assist/view/rashifal.dart';
import 'package:my_assist/view/row_menu.dart';
import 'package:my_assist/view/staggerd_view.dart';
import 'package:my_assist/view/task_listtile.dart';
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
                                      child: const Icon(CupertinoIcons.multiply, color: Colors.red,),
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
           const StaggerdView(),
              const SizedBox(
                height: 20,
              ),

              // This call is for Rahsifal part
              // Container(
              //   color: Colors.red,
              //   height: 800,
              //   width: double.infinity,
              //   child:  RashifalScreen(),
              // ),

              //
              
              const TaskListTile(),
          ],
          ),
        ),
      ),
    );
  }
}
