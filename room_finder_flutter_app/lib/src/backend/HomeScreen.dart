import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'building.dart';
import 'CustomSearch.dart';
import 'RommSelectionScreen.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

// first screen in application
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
      ))
    );
  }
}