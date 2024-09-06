import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_assist/utils/colors.dart';

class RashifalScreen extends StatefulWidget {
  const RashifalScreen({super.key});

  @override
  RashifalScreenState createState() => RashifalScreenState();
}

class RashifalScreenState extends State<RashifalScreen> {
  List<dynamic>? horoscopes;
  bool isLoading = true;
  String selectedSign = "aries"; // Default sign
  String selectedType = "D"; // Default type (D for day)
  final List<String> zodiacSigns = [
    "aries",
    "taurus",
    "gemini",
    "cancer",
    "leo",
    "virgo",
    "libra",
    "scorpio",
    "sagittarius",
    "capricorn",
    "aquarius",
    "pisces",
  ];

  Map<String, String> zodiacSignsInNepali = {
  'Aries': 'मेष',
  'Taurus': 'वृष',
  'Gemini': 'मिथुन',
  'Cancer': 'कर्कट',
  'Leo': 'सिंह',
  'Virgo': 'कन्या',
  'Libra': 'तुला',
  'Scorpio': 'वृश्चिक',
  'Sagittarius': 'धनु',
  'Capricorn': 'मकर',
  'Aquarius': 'कुम्भ',
  'Pisces': 'मीन',
};

  final List<String> horoscopeTypes = [
    "D",
    "W",
    "M",
    "Y"
  ]; // Day, Week, Month, Year

  @override
  void initState() {
    super.initState();
    fetchRashifalData();
  }

  Future<void> fetchRashifalData() async {
    final url = Uri.parse(
        "https://nepalipatro.com.np/rashifal/getv5/type/$selectedType");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes)); // Decoding Unicode
        setState(() {
          horoscopes = data['np'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load rashifal data");
      }
    } catch (e) {
      // print("Error: $e");
      setState(() {
        isLoading = false;
      });

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        
        backgroundColor: mobileBackgroundColor,
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              CupertinoIcons.back,
              color: primaryColor,
            )),
        // title: const Text("Rashifal Selector"),
        // backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // Dropdown to select zodiac sign
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    color: mobileBackgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            alignment: Alignment.center,
                            dropdownColor: mobileBackgroundColor,
                            value: selectedSign,
                            items: zodiacSigns.map((String sign) {
                              return DropdownMenuItem<String>(
                                value: sign,
                                child: Text(
                                  sign[0].toUpperCase() + sign.substring(1),
                                  style: const TextStyle(
                                      fontSize: 18, color: primaryColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSign = newValue!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: DropdownButton<String>(
                            dropdownColor: mobileBackgroundColor,
                            value: selectedType,
                            items: horoscopeTypes.map((String type) {
                              String label = type == "D"
                                  ? "दैनिक"
                                  : type == "W"
                                      ? "साप्ताहिक"
                                      : type == "M"
                                          ? "मासिक"
                                          : "वार्षिक";
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                      fontSize: 18, color: primaryColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedType = newValue!;
                                isLoading = true;
                                fetchRashifalData(); // Fetch updated data when type changes
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Display selected horoscope,
                Expanded(
                  child: horoscopes != null && horoscopes!.isNotEmpty
                      ? HoroscopeCard(
                          horoscope: horoscopes!.first,
                          selectedSign: selectedSign,
                          selectedType: selectedType,
                        )
                      : const Center(child: Text("No horoscope available")),
                ),
              ],
            ),
    );
  }
}

class HoroscopeCard extends StatelessWidget {
  final dynamic horoscope;
  final String selectedSign;
  final String selectedType;

  HoroscopeCard(
      {super.key,
      required this.horoscope,
      required this.selectedSign,
      required this.selectedType});

  final List<Color> colors = [
    Colors.teal.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.cyan.shade100,
    Colors.amber.shade100,
    Colors.lime.shade100,
    Colors.red.shade100,
    Colors.indigo.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    // final List<String> zodiacSigns = [

    // 'मेष', // Aries
    // 'वृष', // Taurus
    // 'मिथुन', // Gemini
    // 'कर्कट', // Cancer
    // 'सिंह', // Leo
    // 'कन्या', // Virgo
    // 'तुला', // Libra
    // 'वृश्चिक', // Scorpio
    // 'धनु', // Sagittarius
    // 'मकर', // Capricorn
    // 'कुम्भ', // Aquarius
    // 'मीन', // Pisces




    //   // "aries",
    //   // "taurus",
    //   // "gemini",
    //   // "cancer",
    //   // "leo",
    //   // "virgo",
    //   // "libra",
    //   // "scorpio",
    //   // "sagittarius",
    //   // "capricorn",
    //   // "aquarius",
    //   // "pisces"
    // ];

    // final int colorIndex =
    //     zodiacSigns.indexOf(selectedSign.toLowerCase()) % colors.length;
    final String horoscopeText = horoscope[selectedSign];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          // margin: const EdgeInsets.all(100),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: primaryColor,
            ),
            color: mobileBackgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          // elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


             
                // Text(
                //   horoscope['title'],
                //   style: const TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black87,
                //   ),
                // ),
                // const SizedBox(height: 10),
                // Text(
                //   "Author: ${horoscope['author']}",
                //   style: const TextStyle(fontSize: 14, color: Colors.black54),
                // ),
                const SizedBox(height: 15),
                Text(
                  "${selectedSign[0].toUpperCase() + selectedSign.substring(1)} - ${getHoroscopeTypeLabel(selectedType)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  horoscopeText,
                  style: const TextStyle(
                      fontSize: 18, fontFamily: 'cursive', color: primaryColor),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getHoroscopeTypeLabel(String type) {
    switch (type) {
      case "D":
        return "Daily Horoscope";
      case "W":
        return "Weekly Horoscope";
      case "M":
        return "Monthly Horoscope";
      case "Y":
        return "Yearly Horoscope";
      default:
        return "";
    }
  }
}
