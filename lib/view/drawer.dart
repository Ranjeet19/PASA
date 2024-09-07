import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

class Draw extends StatelessWidget {
  const Draw({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        color: primaryColor,
        fontFamily: 'sans serif',
        fontSize: 16,
        fontWeight: FontWeight.w600);
    return Scaffold(
      body: ListView(
        children: [
          IconButton(
              alignment: Alignment.topLeft,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
              )),
          Container(
            decoration: const BoxDecoration(
              color: mobileBackgroundColor,
            ),
            child: const Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage("assets/logo/logo.png"),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Assist ME",
                      style: TextStyle(
                          fontFamily: 'cursive',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '- Aiming to Helping Every body',
                      style: TextStyle(
                          fontFamily: 'cursive',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w100),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Column(
            children: [
              ListTile(
                onTap: () {
                  // Get.to(()=>AboutPage());
                },
                leading: const Icon(
                  CupertinoIcons.person,
                  color: primaryColor,
                ),
                title: const Text(
                  "About",
                  style: style,
                ),
                trailing: const Icon(
                  CupertinoIcons.forward,
                  color: primaryColor,
                ),
              ),
              const Divider(),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  CupertinoIcons.heart,
                  color: primaryColor,
                ),
                title: const Text(
                  "Favourite",
                  style: style,
                ),
                trailing: const Icon(
                  CupertinoIcons.forward,
                  color: primaryColor,
                ),
              ),
              const Divider(),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  CupertinoIcons.radiowaves_left,
                  color: primaryColor,
                ),
                title: const Text(
                  "Podcast",
                  style: style,
                ),
                trailing: const Icon(
                  CupertinoIcons.forward,
                  color: primaryColor,
                ),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  // Get.to(()=>FeedbackForm());
                },
                leading: const Icon(
                  CupertinoIcons.keyboard_chevron_compact_down,
                  color: primaryColor,
                ),
                title: const Text(
                  "FeedBack",
                  style: style,
                ),
                trailing: const Icon(
                  CupertinoIcons.forward,
                  color: primaryColor,
                ),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  //  Share.share('Check out this awesome app!');
                },
                leading: const Icon(
                  CupertinoIcons.share,
                  color: primaryColor,
                ),
                title: const Text(
                  "Share",
                  style: style,
                ),
                trailing: const Icon(
                  CupertinoIcons.forward,
                  color: primaryColor,
                ),
              ),
              const Divider(),
            ],
          ),
        ],
      ),
    );
  }
}
