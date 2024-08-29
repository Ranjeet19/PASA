import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_assist/utils/colors.dart';

class StaggerdView extends StatelessWidget {
  const StaggerdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
