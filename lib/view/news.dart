import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_assist/utils/colors.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> newsData = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response =
          await http.get(Uri.parse('https://nepalipatro.com.np/api/news'));

      if (response.statusCode == 200) {
        setState(() {
          newsData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load news (status ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Could not reach news service. Check your connection.';
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
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: primaryColor),
        ),
        title: const Text('Latest News', style: TextStyle(color: primaryColor)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(thickness: 2.0, color: primaryColor, height: 1.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: primaryColor, size: 40),
              const SizedBox(height: 12),
              Text(error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: primaryColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mobileBackgroundColor,
                  side: const BorderSide(color: primaryColor),
                ),
                child: const Text('Retry', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ),
      );
    }
    if (newsData.isEmpty) {
      return const Center(
        child: Text('No news available.', style: TextStyle(color: primaryColor)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: newsData.length,
      itemBuilder: (context, index) {
        final newsItem = newsData[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                newsItem['title']?.toString() ?? 'Untitled',
                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                newsItem['summary']?.toString() ?? '',
                style: const TextStyle(color: secondaryColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
