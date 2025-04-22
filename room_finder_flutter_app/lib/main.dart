import 'package:flutter/material.dart';
import 'package:room_finder_flutter_app/src/backend/node.dart';
import 'ImageWithLines.dart';

import 'src/backend/graph.dart';

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
        backgroundColor: Color.fromRGBO(0, 93, 64, 1),
      ),
      bottomNavigationBar: SizedBox(
        height: 100, 
        child: BottomNavigationBar(
          backgroundColor: Color.fromRGBO(0, 93, 64, 1),

          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SizedBox(),
              label: "Search Bar 1",
            ),
            BottomNavigationBarItem(
              icon: SizedBox(),
              label: "Search Bar 2",
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: EdgeInsets.all(200.0),
          minScale: 0.1,
          maxScale: 7,
          scaleFactor: 1,
          child: ImageWithLines.new()
        ),
      ),
    );
  }
}


void main() async {
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  WidgetsFlutterBinding.ensureInitialized();
  await LoadGraph();
  runApp(MyApp());

  // testing
  Graph test = Graph();
  // ALWAYS await when loading data such that app waits for data to be loaded before proceeding
  await test.readJSON("assets/data/library_tower_floor_6.json");
  var nodes = test.getNodes();
  int nodes_length = test.getNodesLength();

  Map<Node, int> list = test.pathFinder(test, test.getNodes()[(floor : 6, index : 0)], test.getNodes()[(floor : 6, index : 22)]);
  list.forEach((key, value) { print(key.getFloorAndIndex().toString() + ' + ' + value.toString()); } );

  print("\nrooms list:");

  for (int i = 0; i < nodes_length; i++) {
    print(nodes[(floor : 6, index : i)]?.getRooms());
  }
}
