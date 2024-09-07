import 'package:flutter/material.dart';
import 'dart:convert'; // for decoding JSON
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> newsData = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  // Fetch news from the API
  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://nepalipatro.com.np/api/news')); // replace with your actual API endpoint

    if (response.statusCode == 200) {
      setState(() {
        newsData = json.decode(response.body); // Decoding JSON response
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest News'),
      ),
      body: newsData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsData.length,
              itemBuilder: (context, index) {
                var newsItem = newsData[index];
                return ListTile(
                  title: Text(newsItem['title']),
                  subtitle: Text(newsItem['summary']),
                );
              },
            ),
    );
  }
}
