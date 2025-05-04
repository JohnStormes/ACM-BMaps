// Johnathan Stormes
import 'graph.dart';
import 'node.dart';
import 'dart:math';

class Building{
  String _title = "";
  Graph _graph = new Graph();
  int _defaultFloor = 0;
  List<String> _floorNames = [];
  List<String> _floorPlanJSONs = [];
  List<String> _floorPlanImages = [];

  Building(String aTitle, int aDefaultFloor) {
    _title = aTitle;
    _defaultFloor = aDefaultFloor;
  }

  // loads a graph from a file and passes it back to the caller
  Future<Graph> loadGraph(List<String> filePaths) async {
    // load a JSON file
    Graph graph = new Graph();
    await graph.readJSON(filePaths);
    _graph = graph;
    return graph;
  }

  // add floors in order for proper display and usage
  void addFloor(String floorName, String floorPlanJSON, String floorPlanImage) {
    _floorNames.add(floorName);
    _floorPlanJSONs.add(floorPlanJSON);
    _floorPlanImages.add(floorPlanImage);
  }

  String getTitle() {
    return _title;
  }
  Graph getGraph() {
    return _graph;
  }
  List<String> getJSONs() {
    return _floorPlanJSONs;
  }
  List<String> getImages() {
    return _floorPlanImages;
  }
  List<String> getFloorNames() {
    return _floorNames;
  }
  int getDefaultFloor() {
    return _defaultFloor;
  }
}