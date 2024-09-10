import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_assist/view/drawer.dart';
import 'package:my_assist/view/profile.dart';
import 'package:my_assist/view/row_menu.dart';
import 'package:my_assist/view/staggerd_view.dart';
import 'package:my_assist/view/task_listtile.dart';
import 'package:my_assist/utils/colors.dart';

class HomePage extends StatefulWidget {
  // HoroscopeCard horo;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showLotieAnimation = true;

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

  bool _isExpanded = false;
  double _expandedHeight = 0.0; // initial height when not expanded

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _expandedHeight =
          _isExpanded ? 300.0 : 0.0; // Height to expand or collapse to
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Draw()));
                            },
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfileView()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: primaryColor, width: 3),
                                borderRadius: BorderRadius.circular(100)),
                            child: const CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage("assets/rnzt.jpg")),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: const TextStyle(
                              fontFamily: 'cursive',
                              fontWeight: FontWeight.bold, // Bold weight
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                          const Text(
                            "Ranjeet Shrestha",
                            style: TextStyle(
                              color: primaryColor,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold, // Bold weight
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    // color: Colors.red,
                    height: 80,
                    width: 80,
                    child: Stack(
                      // alignment: Alignment.center,
                      children: [
                        // Positioned(
                        //   right: 80,
                        //   top: 10,
                        //   child: Container(
                        //       // color: const Color.fromRGBO(76, 175, 80, 1),
                        //       height: 40,
                        //       width: 40,
                        //       decoration: const BoxDecoration(
                        //         image: DecorationImage(
                        //             fit: BoxFit.cover,
                        //             image: AssetImage(
                        //               "assets/icon/calendar.png",
                        //             )),
                        //       ),
                        //       child: const Padding(
                        //         padding: EdgeInsets.only(
                        //           top: 12,
                        //         ),
                        //         child: Center(
                        //             child: Text(
                        //           "22",
                        //           style: TextStyle(
                        //               color: mobileBackgroundColor,
                        //               fontSize: 20,
                        //               fontWeight: FontWeight.bold),
                        //         )),
                        //       )),
                        // ),

                        Container(
                          // color: Colors.amber,
                          alignment: Alignment.topRight,
                          height: 80,
                          width: 80,
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showLotieAnimation = false;
                                });

                                Future.delayed(const Duration(seconds: 4), () {
                                  setState(() {
                                    _showLotieAnimation = true;
                                  });
                                });
                              },
                              child: _showLotieAnimation
                                  ? Lottie.asset("assets/lottie/bot1.json",
                                      width: 200,
                                      height: 200,
                                      alignment: Alignment.bottomRight)
                                  : Lottie.asset(
                                      "assets/lottie/bot2.json",
                                      alignment: Alignment.bottomRight,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.fill,
                                    )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const RowMenu(), // Row menue has been imported as component
              const SizedBox(
                height: 10,
              ),

              /////////////
              ///
              ///
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Main GridView (4 containers initially)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StaggerdView(),
                    ),

                    // Curtain Animation Container
                    ClipRect(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height:
                            _expandedHeight, // Animated height to simulate curtain opening/closing
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 12, // Number of additional containers
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: mobileBackgroundColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color:primaryColor),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons
                                        .access_alarm,color: Colors.white,), // Change icon accordingly
                                    const SizedBox(height: 8),
                                    Text(
                                        'Label ${index + 40}', style: TextStyle(color: Colors.white),), // Adjust for index
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Down/Up Arrow to Toggle,

                    InkWell(
                      onTap:_toggleExpanded ,
                      child: Container(
                        height: 30,
                        width: 30,
                        child: _isExpanded? Image.asset('../assets/icon/up-arrows.png',color: primaryColor,):Image.asset('../assets/icon/down-arrow.png', color: primaryColor,),
                      ),
                    ),
                    
                    // IconButton(
                      
                    //   icon: Icon(
                    //     _isExpanded
                    //         ? CupertinoIcons.arrow_down
                    //         : CupertinoIcons.arrow_up,
                    //     color: primaryColor,
                    //     size: 30,
                    //   ),
                    //   onPressed: _toggleExpanded,
                    // ),
                  ],
                ),
              ),

              /////////////////////////////////////////////////////////
              const SizedBox(
                height: 10,
              ),

              const TaskListTile(),
            ],
          ),
        ),
      ),
    );
  }
}
