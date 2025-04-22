import 'package:flutter/material.dart';
import 'package:room_finder_flutter_app/src/backend/node.dart';
import 'Draw.dart';

import 'src/backend/graph.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BMaps",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(
        title: "BMaps"
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String start = "Start";
  String destination = "Destination";
  List<({int x, int y})> path_list = [];

  Future<void> _loadInitialPath() async {
    final list = await loadPath(start, destination);
    setState(() {
      path_list = list;
    });
  }

  void _openSearch(int index) async {
    final result = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(index),
    );

    if (result != null) {
      setState(() {
        if (index == 0) {
          start = result;
        } else if (index == 1) {
          destination = result;
        }
      });
      final list = await loadPath(start, destination);
      setState(() {
        path_list = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: BING_GREEN,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // centered interactive viewer
          Center(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: EdgeInsets.all(200.0),
              minScale: 0.1,
              maxScale: 7,
              scaleFactor: 1,
              child: ImageWithLines.new(path_list: path_list)
            ),
          ),

          // buttons
          Positioned(
            bottom: 20,
            left: 20,
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openSearch(0);
                  loadPath(start, destination);
                },
                label: Text(
                  start,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(
                  Icons.search, 
                  color: Colors.white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BING_GREEN
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openSearch(1);
                  loadPath(start, destination);
                },
                label: Text(
                  destination,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(
                  Icons.search, 
                  color: Colors.white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BING_GREEN
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  int button_index = 0;
  List<String> search_terms = graph.getRoomsList();
  CustomSearchDelegate(int aButton_index) {
    button_index = aButton_index;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in search_terms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result  = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          }
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in search_terms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result  = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          }
        );
      },
    );
  }
}


void main() async {
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  WidgetsFlutterBinding.ensureInitialized();
  await loadGraph();
  runApp(MyApp());
}
