import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
              Container(
                    width: double.infinity,
                    height: 145,
                    color: Colors.red,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit:BoxFit.cover,
                          image: AssetImage("../assets/background.jpg",)),
                      ),
                    ),

                  ),
              
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    width: 100,
                    height: 100,

                    child: const CircleAvatar(
                      radius: 2,
                      backgroundImage: AssetImage('../assets/rnzt.jpg') ,
                      
                    ),
                  ),
                ),

                Positioned(
                  left: 115,
                  bottom: 15,
                  child: Text("Ranjeet Shrestha", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: primaryColor),)),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
