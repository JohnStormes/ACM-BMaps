// graph class for floorplan node graphs
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'node.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:math';

enum Direction { nd, up, down }

class Graph {
  Map<({int floor, int index}), Node> _nodes = {};
  Set<String> rooms_list = {};
  Graph();

  // reads from JSON file
  // JSON file must be formatted in the following way:
  /*
    "nodes" : {
      "<floor>-<index>" : {
        "xPos" : 
        "yPos" : 
        "rooms" : 
        "connections" : 
      }
    }
  */
  Future<void> readJSON(List<String> filePaths) async {
    for (String file_path in filePaths) {
      if (file_path == "") {
        continue;
      }
      String input = await rootBundle.loadString(file_path);
      var file = jsonDecode(input);
      final int floor = file["floor"];
      Map map = file["nodes"];


      // create nodes from JSON file
      for (int i = 0; i < map.length; i++) {
        String node_key = floor.toString() + "-" + i.toString();
        var node = map[node_key];
        int xPos = node["xPos"];
        int yPos = node["yPos"];
        String rooms = node["rooms"];
        String connections = node["connections"];
        Node new_node = new Node(floor, i, xPos, yPos, rooms, connections);
        _nodes[(floor : floor, index : i)] = new_node;
        for (String room in new_node.getRooms()) {
          if (!rooms_list.contains(room)) {
            rooms_list.add(room);
          }
        }
      }
    }
  }

  int getDist(Node n1, Node n2){
    if (n1.getFloorAndIndex().floor != n2.getFloorAndIndex().floor) {
      return 0;
    }
    return (sqrt(pow(n1.getXPos() - n2.getXPos(), 2) + pow(n1.getYPos() - n2.getYPos(), 2))).toInt();
  }

  // get if a node is a stair or an elevator, and return null if neither
  String ?getConnectorID(Node node) {
    if (node.getRooms().isEmpty) {
      return null;
    }
    String room = node.getRooms().toList()[0];
    if (room.contains("STR") == false && room.contains("ELEV") == false) {
      return null;
    }
    return room;
  }

  // return if the given node contains a bathroom
  bool isBathroomNode(Node node, String dest) {
    Set<String> rooms = node.getRooms();
    String key = "not bathroom";
    if (rooms.isEmpty) {
      return false;
    }

    if (dest == "NEAREST MENS BATHROOM") {
      key = "MEN";
    } else if (dest == "NEAREST WOMENS BATHROOM") {
      key = "WOMEN";
    }

    if (rooms.contains("BATH") && rooms.contains(key)) {
      return true;
    }
    return false;
  }

  // finds the shortest path from source_room to dest_room in the given graph, and returns
  // the path as a map of Node - distance pairings. The distances are just there for later
  // use if needed, but for now the implementation of this function turns the map into a list
  // of x-y coordinates in Main.dart -> loadPath
  Map<Node, int> pathFinder(Graph graph, String source_room, String dest_room, bool elevatorsOnly){
    Node source = getNodeWithRoom(source_room);
    Node? destination;
    if (dest_room == "NEAREST MENS BATHROOM" || dest_room == "NEAREST WOMENS BATHROOM") {
      destination = null;
    } else {
      destination = getNodeWithRoom(dest_room);
    }
    final distances = <Node, int>{};
    final previous = <Node, Node?>{};
    final visited = <Node>{};

    // Determine floor direction: +1 = up, -1 = down, 0 = same floor
    int sourceFloor = source.getFloorAndIndex().floor;
    int destFloor = destination?.getFloorAndIndex().floor ?? sourceFloor;
    int floorDirection = (destFloor - sourceFloor).sign;

    Node? foundBathroom;

    // initialize the infinite distances and previous nodes
    for (var node in graph.getNodes().values) {
      distances[node] = 1 << 30;
      previous[node] = null;
    }
    distances[source] = 0;

    final pq = PriorityQueue<Node>((a, b) => distances[a]! - distances[b]!);
    pq.add(source);

    while(pq.isNotEmpty){
      Node current = pq.removeFirst();
      if(visited.contains(current)) continue;

      visited.add(current);

      if (destination == null && isBathroomNode(current, dest_room)) {
        foundBathroom = current;
        break;
      }

      // stop early if we reach the destination
      if (current == destination) break;

      for(({int floor, int index}) neighbor_key in current.getAdjacentNodes()){
        Node? neighbor = graph.getNode(neighbor_key.floor, neighbor_key.index);
        if (neighbor == null || visited.contains(neighbor)) continue;

        int currentFloor = current.getFloorAndIndex().floor;
        int neighborFloor = neighbor.getFloorAndIndex().floor;
        int floorDiff = neighborFloor - currentFloor;

        // disalow vertical movement against intended direction
        if (destination != null && floorDiff.sign != 0 && floorDiff.sign != floorDirection) {
          continue;
        }

        // disalow vertical movement if searching for any bathroom
        if ((dest_room == "NEAREST MENS BATHROOM" || dest_room == "NEAREST WOMENS BATHROOM") && floorDiff != 0) {
          continue;
        }

        // disalow vertical movement on stairs if elevatorsOnly is true
        if (elevatorsOnly && floorDiff != 0) {
          bool isElevatorNode = current.getRooms().length == 1 &&
                                current.getRooms().first.startsWith("ELEV");

          if (!isElevatorNode) {
            continue; // Not an elevator node; skip vertical move
          }
        }

        int baseDistance = graph.getDist(current, neighbor); // typically 0 if vertical
        int totalDistance = distances[current]! + baseDistance;

        if(distances[neighbor]! > totalDistance){
          distances[neighbor] = totalDistance;
          previous[neighbor] = current;
          pq.add(neighbor);
        }
      }
    }

    Node? end = destination ?? foundBathroom;

    // if there isn't a path, return an empty map
    if (end == null || previous[end] == null && source != end) {
      return {};
    }

    // reconstruct the path from destination to source
    Map<Node, int> shortest_path = {};
    Node? current = end;
    while (current != null) {
      shortest_path[current] = distances[current]!;
      current = previous[current];
    }
    return Map.fromEntries(shortest_path.entries.toList().reversed);
  }

  // get the node containing the given room
  // should NEVER be passed a nonexistent room
  // if passed nonexistent room, returns first room in the list of nodes for the graph
  Node getNodeWithRoom(String room) {
    var nodes_list = _nodes.entries.toList();
    Node ret = nodes_list[0].value;
    for (var entry in nodes_list) {
      if (entry.value.getRooms().contains(room))
        ret = entry.value;
    }
    return ret;
  }

  //accessors
  Map<({int floor, int index}), Node> getNodes() {
    return _nodes;
  }

  Node? getNode(int floor, int index) {
    return _nodes[(floor : floor, index : index)];
  }

  List<String> getRoomsList() {
    return rooms_list.toList();
  }
}