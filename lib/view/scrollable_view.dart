import 'package:flutter/material.dart';
import 'package:my_assist/view/staggerd_view.dart';



class ScrollableView extends StatelessWidget {
  const ScrollableView({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
        body: HomeScreen(),
      
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isExpanded = false;
  double _expandedHeight = 0.0; // initial height when not expanded

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _expandedHeight = _isExpanded ? 300.0 : 0.0; // Height to expand or collapse to
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              height: _expandedHeight, // Animated height to simulate curtain opening/closing
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8, // Number of additional containers
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_alarm), // Change icon accordingly
                          const SizedBox(height: 8),
                          Text('Label ${index + 4}'), // Adjust for index
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Down/Up Arrow to Toggle
          IconButton(
            icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: _toggleExpanded,
          ),
        ],
      ),
    );
  }
}
