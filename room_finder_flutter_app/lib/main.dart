import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:room_finder_flutter_app/src/backend/node.dart';
import 'Draw.dart';
import 'src/backend/Building.dart';

import 'src/backend/graph.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    //required this.graph,
    //required this.floorPlansPNGs
    required this.buildings
  });

  // passed in from main when app is started
  //final Graph graph;
  //final List<String> floorPlansPNGs;
  final List<Building> buildings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BMaps",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(
        title: "BMaps",
        buildings: buildings,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.buildings});

  final String title;
  // passed in from MyApp when homepage is created
  final List<Building> buildings;

  @override _HomeScreenState createState() => _HomeScreenState(title, buildings);
}

// widget created for room selection page in home page
class _HomeScreenState extends State<HomeScreen> {
  
  String title = "";
  // passed in from MyApp when homepage is created
  List<Building> buildings = [];
  int currentBuilding = 0;
  String building = "Select a building";

  _HomeScreenState(String aTitle, List<Building> aBuildings) {
    title = aTitle;
    buildings = aBuildings;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/IntroPage.jpg'),
          fit: BoxFit.cover
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "BMaps",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          leading: Image.asset('assets/images/Bing-logo.png'),
          backgroundColor: BING_GREEN,
          centerTitle: true
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [

            // welcome to BMaps text
            Align(
              alignment: Alignment(0, -0.7), // x and y: -1 to 1
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white, // your desired color
                  borderRadius: BorderRadius.circular(20), // rounded corners
                ),
                child: Text(
                  "Welcome to BMaps!\nTo begin, select a building",
                  style: TextStyle(
                    color: BING_GREEN,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center
                ),
              ),
            ),

            // go! button
            Align(
              alignment: Alignment(0, 0.9),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (building != "Select a building") {
                      _switchToSelectionScreen(context);
                    }
                  },
                  label: Text(
                    "Continue to room selection",
                    style: const TextStyle(
                      color: BING_GREEN,
                      fontSize: 24
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                ),
              ),
            ),

            // select building button
            Align(
              alignment: Alignment(0, 0),
              child: SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openSearch();
                  },
                  label: Text(
                    building,
                    style: const TextStyle(
                      color: BING_GREEN,
                      fontSize: 24
                    ),
                  ),
                  icon: const Icon(
                    Icons.search, 
                    color: BING_GREEN,
                    size: 30
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  // opens a search menu, gets result, and updates the start and destination string variables
  // finally, it updates the path with loadPath, and reloads the home page
  void _openSearch() async {
    final result = await showSearch(
      context: context,
      delegate: CustomSearchDelegate.fromBuildings(buildings),
    );
    if (building != result && result != null) {
      setState(() {
        building = result;
        for (int i = 0; i < buildings.length; i++) {
          if (buildings[i].getTitle() == building) {
            currentBuilding = i;
          }
        }
      });
    }
  }

  void _switchToSelectionScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoomSelectionScreen(
        title: title,
        buildings: buildings,
        currentBuilding: currentBuilding,
      )));
  }
}

class RoomSelectionScreen extends StatefulWidget {
  const RoomSelectionScreen({super.key, required this.title, required this.buildings, required this.currentBuilding});

  final String title;
  // passed in from MyApp when homepage is created
  final List<Building> buildings;
  final int currentBuilding;

  @override _RoomSelectionScreenState createState() => _RoomSelectionScreenState(title, buildings, currentBuilding);
}

// widget created for room selection page in home page
class _RoomSelectionScreenState extends State<RoomSelectionScreen> {

  String title = "";
  // passed in from MyApp when homepage is created
  List<Building> buildings = [];
  Graph graph = Graph();
  int currentBuilding = 0;
  int currentFloor = 0;

  String start = "What is the nearest room?";
  String destination = "Where are you headed?";

  _RoomSelectionScreenState(String aTitle, List<Building> aBuildings, int aCurrentBuilding) {
    title = aTitle;
    buildings = aBuildings;
    currentBuilding = aCurrentBuilding;
    graph = buildings[currentBuilding].getGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/HomePage.jpg'),
          fit: BoxFit.cover
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "BMaps",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          leading: Image.asset('assets/images/Bing-logo.png'),
          backgroundColor: BING_GREEN,
          centerTitle: true
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [

            // go! button
            Align(
              alignment: Alignment(0, 0.9),
              child: SizedBox(
                //width: 140,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (start != "What is the nearest room?" && destination != "Where are you headed?") {
                      _switchToMainPage(context);
                    }
                  },
                  label: Text(
                    "Go!",
                    style: const TextStyle(
                      color: BING_GREEN,
                      fontSize: 24
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                ),
              ),
            ),

            // left search button
            Align(
              alignment: Alignment(0, -0.3),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  // left search button activates the code below onPressed here
                  onPressed: () {
                    _openSearch(0);
                  },
                  label: Text(
                    start,
                    style: const TextStyle(
                      color: BING_GREEN,
                      fontSize: 24
                    ),
                  ),
                  icon: const Icon(
                    Icons.search, 
                    color: BING_GREEN,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                ),
              ),
            ),

            // right search button
            Align(
              alignment: Alignment(0, -0),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  // right search button activates the code below onPressed here
                  onPressed: () {
                    _openSearch(1);
                  },
                  label: Text(
                    destination,
                    style: const TextStyle(
                      color: BING_GREEN,
                      fontSize: 24
                    ),
                  ),
                  icon: const Icon(
                    Icons.search, 
                    color: BING_GREEN
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  void _openSearch(int index) async {
    final result = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(index, graph, buildings),
    );

    if (result != null && (index == 0 || index == 1)) {
      setState(() {
        if (index == 0) {
          start = result;
          currentFloor = buildings[currentBuilding].getGraph().getNodeWithRoom(start).getFloorAndIndex().floor;
        } else if (index == 1) {
          destination = result;
        }
      });
    }
  }

  void _switchToMainPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyMainPage(
        start: start,
        destination: destination,
        graph: graph,
        title: title,
        buildings: buildings,
        currentBuilding: currentBuilding,
        currentFloor: currentFloor
      )));
  }
}


// widget created in after home page, which creates the _MyMainPageState custom state
class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key, required this.start, required this.destination, required this.graph, required this.title
                    , required this.buildings, required this.currentBuilding, required this.currentFloor});

  final Graph graph;
  final String title;
  // passed in from MyApp when homepage is created
  final List<Building> buildings;
  final int currentBuilding;
  final int currentFloor;
  final String start;
  final String destination;

  @override _MyMainPageState createState() => _MyMainPageState(start, destination, graph, buildings, currentBuilding, currentFloor);
}

// PRIMARY HOME PAGE CLASS
// contains most home page widgets and functionality
class _MyMainPageState extends State<MyMainPage> {
  // these strings change as rooms are selected
  String start = "Start"; 
  String destination = "Destination";
  String building = "Building";
  // current building
  List<Building> buildings = [];
  int currentBuilding = 0;
  Graph graph = Graph();
  List<String> floorPlansPNGs = [];

  String _dropDownValue = "";
  int _floorValue = 0;
  List<String> _dropDownItems = [];

  // list of values for the current path
  List<({int x, int y, Direction d})> path_list = [];

  // controls where the starting point of the image is
  TransformationController _controller = TransformationController();
  final double zoom = 1.5;

  // pass in aCurrentBuilding and aCurrentFloor when initializing app
  _MyMainPageState(String aStart, String aDestination, Graph aGraph, List<Building> aBuildings, int aCurrentBuilding, int aCurrentFloor) {
    start = aStart;
    destination = aDestination;
    buildings = aBuildings;
    currentBuilding = aCurrentBuilding;
    building = buildings[currentBuilding].getTitle();
    graph = aGraph;
    floorPlansPNGs = buildings[currentBuilding].getImages();
    _floorValue = aCurrentFloor;
    _dropDownItems = buildings[currentBuilding].getFloorNames();
    _dropDownValue = _dropDownItems[_floorValue];
    _initializePath();

    // set starting position of the image
    _resetImagePosition();
  }

  // opens an alert box telling the user a path could not be found
  // index: 0 - are you lost? button
  // index: 1 - could not find path
  showAlertDialog(BuildContext context, int index) {
    String title = "";
    String content = "";

    if (index == 0) {
      title = "If you're lost:";
      content = "1. Find the nearest marked room\n2. Enter that room as your start location";
    } else if (index == 1) {
      title = "Could not find path";
      content = "There is no known path from your location to room $destination";
    }

    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(
          color: BING_GREEN
        )
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // resets the starting position of the image when the user selects a new starting point
  void _resetImagePosition() {
    // set starting position of the image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      Node startNodeTemp = graph.getNodeWithRoom(start);
      double xPos = size.width / 2 - startNodeTemp.getXPos().toDouble() * zoom;
      double yPos = size.height / 2 - startNodeTemp.getYPos().toDouble() * zoom;
      _controller.value = Matrix4.identity()
        ..scale(zoom)
        ..translate(xPos / zoom, yPos / zoom);
    });
  }

  // initializes the path with the current values
  void _initializePath() async {
    final list = await loadPath(graph, start, destination, _floorValue);
    setState(() {
      path_list = list;
    });
  }

  // opens a search menu, gets result, and updates the start and destination string variables
  // finally, it updates the path with loadPath, and reloads the home page
  void _openSearch(int index) async {
    final result = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(index, graph, buildings),
    );

    if (result != null && (index == 0 || index == 1)) {
      setState(() {
        if (index == 0) {
          start = result;
          if (graph.getNodeWithRoom(start).getFloorAndIndex().floor != _floorValue) {
            _floorValue = graph.getNodeWithRoom(start).getFloorAndIndex().floor;
            _dropDownValue = _dropDownItems[_floorValue];
          }
        } else if (index == 1) {
          destination = result;
        }
      });
      final list = await loadPath(graph, start, destination, _floorValue);
      // reload home page
      setState(() {
        path_list = list;
        if (index == 0) {
          _resetImagePosition();
        }
        if (path_list.isEmpty) {
          showAlertDialog(context, 1);
        }
      });
    } else if (result != null && (index == 2)) {
      print(result);
      if (building != result) {
        setState(() {
          building = result;
          start = "Start";
          destination = "Destination";
        });
        // make the list with the current building's graph
        for (int i = 0; i < buildings.length; i++) {
          if (buildings[i].getTitle() == result) {
            currentBuilding = i;
          }
        }
        _floorValue = buildings[currentBuilding].getDefaultFloor();
        _dropDownValue = _dropDownItems[_floorValue];
        final list = await loadPath(graph, start, destination, _floorValue);
        // reload home page
        setState(() {
          path_list = list;
        });
      }
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
          
          // building search button
          ElevatedButton.icon(
            onPressed: () {
              _openSearch(2);
            },
            label: Text(
              building,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20
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
              transformationController: _controller,
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

          // lost button
          Align(
            alignment: Alignment(-0.98, -0.98),
            child: SizedBox(
              height: 30,
              child: ElevatedButton.icon(
                onPressed: () {
                  showAlertDialog(context, 0);
                },
                label: Text(
                  "lost?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BING_GREEN
                ),
              ),
            ),
          ),

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
  CustomSearchDelegate(int aButtonIndex, Graph aGraph, List<Building> aBuildings) {
    button_index = aButtonIndex;
    graph = aGraph;
    if (button_index == 0 || button_index == 1) {
      search_terms = graph.getRoomsList();
    } else if (button_index == 2) {
      for (int i = 0; i < aBuildings.length; i++) {
        search_terms.add(aBuildings[i].getTitle());
      }
    }
  }

  CustomSearchDelegate.fromBuildings(List<Building> aBuildings) {
    for (int i = 0; i < aBuildings.length; i++) {
      search_terms.add(aBuildings[i].getTitle());
    }
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

Future<List<({int x, int y, Direction d})>> loadPath(Graph graph, String start_room, String end_room, int floor) async {
  List<({int x, int y, Direction d})> new_path_list = [];
  Map<Node, int> path = Map();
  // if either or one of the rooms isn't set, handle it for the canvas drawer
  int end_room_floor = graph.getNodeWithRoom(end_room).getFloorAndIndex().floor;
  int start_room_floor = graph.getNodeWithRoom(start_room).getFloorAndIndex().floor;
  if ((start_room == "Start" && end_room == "Destination") 
      || (start_room == "Start" && end_room_floor != floor) 
      || (end_room == "Destination" && start_room_floor != floor)) {
    return new_path_list;
  } else if (start_room == "Start") {
    Node n = graph.getNodeWithRoom(end_room);

    new_path_list.add((x : n.getXPos(), y : n.getYPos(), d : Direction.nd));
    return new_path_list;
  } else if (end_room == "Destination") {
    Node n = graph.getNodeWithRoom(start_room);

    new_path_list.add((x : n.getXPos(), y : n.getYPos(), d : Direction.nd));
    return new_path_list;
  }

  // finds path from first to second room
  path = graph.pathFinder(graph, start_room, end_room);
  // get the nodes in the path map as a list
  var indexed_list = path.entries.toList();

  // save the nodes in the path as a list of x and y coordinates
  for (int i = 0; i < indexed_list.length; i++) {
    Node n = indexed_list[i].key;

    if (n.getFloorAndIndex().floor == floor) {
      bool changeInFloor = false;

      for(String s in n.getRooms()) {
        if((s.length >= 3 && s.substring(0, 3) == "STR") || (s.length >= 4 && s.substring(0, 4) == "ELEV")) {
          changeInFloor = true;
          break;
        }
      }

      // if the node is a stair and it is not the last element of the path, set the direction
      if(changeInFloor && i + 1 < indexed_list.length) {
        Node next = indexed_list[i + 1].key;

        Direction d = n.getFloorAndIndex().floor < next.getFloorAndIndex().floor ? Direction.up : Direction.down;

        new_path_list.add((x : n.getXPos(), y : n.getYPos(), d : d));
      }
      // if the node is not a stair or is a stair at the end of the path, unset the direction
      else {
        new_path_list.add((x : n.getXPos(), y : n.getYPos(), d : Direction.nd));
      }
    }
  }

  return new_path_list;
}

Future<List<Building>> loadBuildings(String JSON) async {
  List<Building> out = [];

  String input = await rootBundle.loadString(JSON);
  var file = jsonDecode(input);

  Map buildingsMap = file["buildings"];
  List<String> buildingsKeys = List<String>.from(buildingsMap.keys.toList());

  // for each building, get its data, load it into a building object, load it's graph, save it in return list
  for (int i = 0; i < buildingsKeys.length; i++) {
    String title = buildingsKeys[i];
    Map buildingData = buildingsMap[title];
    int defaultFloor = buildingData["default floor"];
    // create new building with the data from buildingData in the JSON
    Building building = Building(title, defaultFloor);
    Map floorsData = buildingData["floors"];
    List<String> floors = List<String>.from(floorsData.keys.toList());
    // add each floor in the building class
    for (int x = 0; x < floors.length; x++) {
      Map individualFloorMap = floorsData[floors[x]];
      building.addFloor(floors[x], individualFloorMap["JSON"], individualFloorMap["PNG"]);
    }

    // load the graph for this building
    await building.loadGraph(building.getJSONs());
    out.add(building);
  }

  return out;
}

void main() async {
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  // NATIVE GRAPH INSTANCE
  List<Building> buildings = [];

  // ensure the core_graph is initialized before starting the app!
  WidgetsFlutterBinding.ensureInitialized();
  
  buildings = await loadBuildings("assets/data/buildings.json");
  
  //runApp(MyApp(graph: core_graph, floorPlansPNGs: buildings[0].getImages()));
  runApp(MyApp(buildings: buildings));
}
