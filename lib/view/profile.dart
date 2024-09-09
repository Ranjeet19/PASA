import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const iconStyle = TextStyle(
      color: primaryColor,
      fontSize: 14,
    );
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 145,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            "assets/background.jpg",
                          )),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: mobileBackgroundColor, width: 4),
                        borderRadius: BorderRadius.circular(100)),
                    width: 100,
                    height: 100,
                    child: const CircleAvatar(
                      radius: 2,
                      backgroundImage: AssetImage('assets/rnzt.jpg'),
                    ),
                  ),
                ),
                const Positioned(
                    left: 120,
                    bottom: 15,
                    child: Text(
                      "Ranjeet Shrestha", 
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              height: 20,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "assets/icon/facebook.png",
                    color: primaryColor,
                  ),
                  Image.asset(
                    "assets/icon/instagram.png",
                    color: primaryColor,
                  ),
                  Image.asset(
                    "assets/icon/youtube.png",
                    color: primaryColor,
                  ),
                  Image.asset(
                    "assets/icon/tik-tok.png",
                    color: primaryColor,
                  ),
                  Image.asset(
                    "assets/icon/snapchat.png",
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ), 
          Divider(),
        ],
      ),
    ));
  }
}
