import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'building.dart';
import 'custom_search.dart';
import 'graph.dart';
import 'main_page.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

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

  bool elevatorsOnly = false;

  String start = "What is the nearest room?";
  String destination = "Where are you headed?";
  String destText = "";

  _RoomSelectionScreenState(String aTitle, List<Building> aBuildings, int aCurrentBuilding) {
    title = aTitle;
    buildings = aBuildings;
    currentBuilding = aCurrentBuilding;
    graph = buildings[currentBuilding].getGraph();
    destText = destination;
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

            // top search button
            Align(
              alignment: Alignment(0, -0.3),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  // top search button activates the code below onPressed here
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

            // bottom search button
            Align(
              alignment: Alignment(0, -0),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  // bottom search button activates the code below onPressed here
                  onPressed: () {
                    _openSearch(1);
                  },
                  label: Text(
                    destText,
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

            // check box
            Align(
              alignment: const Alignment(0, 0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white, // 👈 background color here
                  borderRadius: BorderRadius.circular(8), // optional: rounded corners
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: elevatorsOnly,
                      onChanged: (value) {
                        setState(() {
                          elevatorsOnly = value!;
                        });
                      },
                      checkColor: Colors.white,
                    ),
                    const Text(
                      'Use only elevators',
                      style: TextStyle(
                        color: BING_GREEN,
                        fontSize: 18,
                      ),
                    ),
                  ],
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
          destText = destination;
          if (destText == "NEAREST MENS BATHROOM" || destText == "NEAREST WOMENS BATHROOM") {
            destText = "Bathroom";
          }
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
        currentFloor: currentFloor,
        elevatorsOnly: elevatorsOnly
      )));
  }
}