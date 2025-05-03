import 'package:flutter/material.dart';
import 'package:room_finder_flutter_app/src/backend/node.dart';
import 'Draw.dart';

import 'src/backend/graph.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.graph,
    required this.floorPlansPNGs
  });

  // passed in from main when app is started
  final Graph graph;
  final List<String> floorPlansPNGs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BMaps",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(
        title: "BMaps",
        graph: graph,
        floorPlansPNGs: floorPlansPNGs
      ),
    );
  }
}

// widget created in MyApp, which creates the _MyHomePageState custom state
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.graph, required this.floorPlansPNGs});

  final String title;
  // passed in from MyApp when homepage is created
  final Graph graph;
  final List<String> floorPlansPNGs;

  @override _MyHomePageState createState() => _MyHomePageState(graph, floorPlansPNGs);
}

// PRIMARY HOME PAGE CLASS
// contains most home page widgets and functionality
class _MyHomePageState extends State<MyHomePage> {
  // these strings change as rooms are selected
  String start = "Start"; 
  String destination = "Destination";
  String building = "Building";
  // curren graph
  Graph graph = Graph();
  List<String> floorPlansPNGs = [];

  String _dropDownValue = "Floor 6";
  int _floorValue = 6;
  final List<String> _dropDownItems = ["Floor 6", "Floor 7", "Floor 8"];

  // list of values for the current path
  List<({int x, int y})> path_list = [];

  _MyHomePageState(Graph a_graph, List<String> a_floorPlansPNGs) {
    graph = a_graph;
    floorPlansPNGs = a_floorPlansPNGs;
  }

  // opens a search menu, gets result, and updates the start and destination string variables
  // finally, it updates the path with loadPath, and reloads the home page
  void _openSearch(int index) async {
    final result = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(index, graph),
    );

    if (result != null && (index == 0 || index == 1)) {
      setState(() {
        if (index == 0) {
          start = result;
        } else if (index == 1) {
          destination = result;
        }
      });
      final list = await loadPath(graph, start, destination, _floorValue);
      // reload home page
      setState(() {
        path_list = list;
      });
    } else if (result != null && (index == 2)) {
      setState(() {
        building = result;
      });
      // make the list with the current building's graph
    }
  }

  @override
  // home page front end
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
        leading: Image.asset('assets/images/Bing-logo.png'),
        backgroundColor: BING_GREEN,
        actions: [
          ElevatedButton.icon(
            // right search button activates the code below onPressed here
            onPressed: () {
              _openSearch(1);
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
        ]
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
              // creates the image widget from the Draw.dart file
              child: ImageWithLines.new(path_list: path_list, image: floorPlansPNGs[_floorValue])
            ),
          ),

          // buttons

          // left search button
          Positioned(
            bottom: 20,
            left: 20,
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton.icon(
                // left search button activates the code below onPressed here
                onPressed: () {
                  _openSearch(0);
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

          // right search button
          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton.icon(
                // right search button activates the code below onPressed here
                onPressed: () {
                  _openSearch(1);
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

          // drop down menu
          Positioned(
            bottom: 80,
            left: 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: BING_GREEN,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true, // ensures full width
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    borderRadius: BorderRadius.circular(25),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    dropdownColor: BING_GREEN,
                    items: _dropDownItems.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: _dropDownValue,
                    onChanged: (String? newValue) async {
                      setState(() {
                        _dropDownValue = newValue!;
                        _floorValue = int.parse(_dropDownValue.split(' ')[1]);
                      });

                      if (start != "Start" && destination != "Destination") {
                        final list = await loadPath(graph, start, destination, _floorValue);
                        setState(() {
                          path_list = list;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Properties for the search window, takes in which button we are using (start or destination),
// and the graph so that it can get a list of all the rooms in the graph
class CustomSearchDelegate extends SearchDelegate {
  // this classes instance of the current graph
  Graph graph = Graph();

  int button_index = 0;
  List<String> search_terms = [];
  CustomSearchDelegate(int aButton_index, Graph a_graph) {
    button_index = aButton_index;
    graph = a_graph;
    search_terms = graph.getRoomsList();
  }

  @override
  // button to clear the search list
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
  // button to exit the search page
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      }
    );
  }

  @override
  // shows all rooms in search list (same code as buildSuggestions)
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var rooms in search_terms) {
      if (rooms.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(rooms);
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
  // shows suggested rooms in search list (same code as buildResults)
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var rooms in search_terms) {
      if (rooms.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(rooms);
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

// loads a graph from a file and passes it back to the caller
Future<Graph> loadGraph(Graph graph, List<String> filePaths) async {
  // load a JSON file
  await graph.readJSON(filePaths);
  return graph;
}

Future<List<({int x, int y})>> loadPath(Graph graph, String start_room, String end_room, int floor) async {
  List<({int x, int y})> new_path_list = [];
  Map<Node, int> path = Map();
  // if either or one of the rooms isn't set, handle it for the canvas drawer
  int end_room_floor = graph.getNodeWithRoom(end_room).getFloorAndIndex().floor;
  int start_room_floor = graph.getNodeWithRoom(start_room).getFloorAndIndex().floor;
  if ((start_room == "Start" && end_room == "Destination") 
      || (start_room == "Start" && end_room_floor != floor) 
      || (end_room == "Destination" && start_room_floor != floor)) {
    return new_path_list;
  } else if (start_room == "Start") {
    new_path_list.add((x : graph.getNodeWithRoom(end_room).getXPos(), y : graph.getNodeWithRoom(end_room).getYPos()));
    return new_path_list;
  } else if (end_room == "Destination") {
    new_path_list.add((x : graph.getNodeWithRoom(start_room).getXPos(), y : graph.getNodeWithRoom(start_room).getYPos()));
    return new_path_list;
  }

  // finds path from first to second room
  path = graph.pathFinder(graph, start_room, end_room);
  // get the nodes in the path map as a list
  var indexed_list = path.entries.toList();

  // save the nodes in the path as a list of x and y coordinates
  for (var entry in indexed_list) {
    if (entry.key.getFloorAndIndex().floor == floor) {
      new_path_list.add((x : entry.key.getXPos(), y : entry.key.getYPos()));
    }
  }
  return new_path_list;
}

void main() async {
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  // NATIVE GRAPH INSTANCE
  Graph core_graph = Graph();

  // floorplan json files
  String floor6JSON = "assets/data/library_tower_floor_6_data.json";
  String floor7JSON = "assets/data/library_tower_floor_7_data.json";
  String floor8JSON = "assets/data/library_tower_floor_8_data.json";
  List<String> floorPlansJSONs = [floor6JSON, floor7JSON, floor8JSON];

  // floorplan image files
  String floor6PNG = "assets/images/library_tower_floor_6.png";
  String floor7PNG = "assets/images/library_tower_floor_7.png";
  String floor8PNG = "assets/images/library_tower_floor_8.png";
  List<String> floorPlansPNGs = ["", "", "", "", "", "", floor6PNG, floor7PNG, floor8PNG];

  // ensure the core_graph is initialized before starting the app!
  WidgetsFlutterBinding.ensureInitialized();
  core_graph = await loadGraph(core_graph, floorPlansJSONs);
  runApp(MyApp(graph: core_graph, floorPlansPNGs: floorPlansPNGs));
}
