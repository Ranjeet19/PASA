import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

class RowMenu extends StatelessWidget {
  const RowMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return     Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              )),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text(
                              "To Do List",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              )),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text(
                              "Important Date",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,

                              ),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              )),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text(
                              "Health ",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,

                              ),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              )),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text(
                              "To Do",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,

                              ),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              )),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text(
                              "Shrestha",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,

                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            );
           
  }
}