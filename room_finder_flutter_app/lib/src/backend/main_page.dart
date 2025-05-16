import 'package:flutter/material.dart';
import 'building.dart';
import 'custom_search.dart';
import 'graph.dart';
import 'node.dart';
import 'draw.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

// widget created in after home page, which creates the _MyMainPageState custom state
class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key, required this.start, required this.destination, required this.graph, required this.title
                    , required this.buildings, required this.currentBuilding, required this.currentFloor, required this.elevatorsOnly});

  final Graph graph;
  final String title;
  // passed in from MyApp when homepage is created
  final List<Building> buildings;
  final int currentBuilding;
  final int currentFloor;
  final String start;
  final String destination;
  final bool elevatorsOnly;

  @override _MyMainPageState createState() => _MyMainPageState(start, destination, graph, buildings, currentBuilding, currentFloor, elevatorsOnly);
}

// PRIMARY HOME PAGE CLASS
// contains most home page widgets and functionality
class _MyMainPageState extends State<MyMainPage> {
  // these strings change as rooms are selected
  String start = "Start"; 
  late Node floorStart;
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

  bool elevatorsOnly = false;

  // list of values for the current path
  List<({int x, int y, Direction d})> path_list = [];

  // controls where the starting point of the image is
  TransformationController _controller = TransformationController();
  final double zoom = 1.5;

  // pass in aCurrentBuilding and aCurrentFloor when initializing app
  _MyMainPageState(String aStart, String aDestination, Graph aGraph, List<Building> aBuildings, int aCurrentBuilding, int aCurrentFloor, bool aElevatorsOnly) {
    start = aStart;
    destination = aDestination;
    buildings = aBuildings;
    currentBuilding = aCurrentBuilding;
    building = buildings[currentBuilding].getTitle();
    graph = aGraph;
    floorPlansPNGs = buildings[currentBuilding].getImages();
    elevatorsOnly = aElevatorsOnly;
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
      Node startNodeTemp = floorStart;
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
                        for (int i = 0; i < _dropDownItems.length; i++) {
                          if (_dropDownItems[i] == _dropDownValue) {
                            _floorValue = i;
                          }
                        }
                      });

                      if (start != "Start" && destination != "Destination") {
                        final list = await loadPath(graph, start, destination, _floorValue);
                        setState(() {
                          path_list = list;
                          _resetImagePosition();
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
    path = graph.pathFinder(graph, start_room, end_room, elevatorsOnly);
    // get the nodes in the path map as a list
    var indexed_list = path.entries.toList();

    // save the nodes in the path as a list of x and y coordinates
    for (int i = 0; i < indexed_list.length; i++) {
      Node n = indexed_list[i].key;

      if (n.getFloorAndIndex().floor == floor) {
        if (new_path_list.isEmpty) {
          floorStart = n;
        }
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
}