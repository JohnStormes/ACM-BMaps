import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/backend/building.dart';
import 'src/backend/home_screen.dart';

const Color BING_GREEN =Color.fromRGBO(0, 93, 64, 1);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.buildings
  });

  // passed in from main when app is started
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
  List<Building> buildings = [];

  // ensure the core_graph is initialized before starting the app!
  WidgetsFlutterBinding.ensureInitialized();
  
  buildings = await loadBuildings("assets/data/buildings.json");
  
  runApp(MyApp(buildings: buildings));
}
