import 'package:flutter/material.dart';
import 'package:my_assist/components/row_menu.dart';
import 'package:my_assist/utils/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("assets/rnzt.jpg")),
                  ),
                  SizedBox(width: 5,),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Afternoon...",
                          style: TextStyle(
                            fontFamily: 'cursive',
                            fontWeight: FontWeight.bold, // Bold weight
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          "Ranjeet Shrestha",
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold, // Bold weight
                            fontSize: 24,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const RowMenu(),// Row menue has been imported as component
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 220,
                  // color: const Color.fromARGB(255, 174, 21, 21),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 250,
                        width: 150,
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
                              SizedBox(width: 10,),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
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
