// graph class for floorplan node graphs
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'node.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:math';


class Graph {
  Map<({int floor, int index}), Node> _nodes = {};
  Map<Node, int> distances = {};
  int _nodes_length = 0;

  //this is a change

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
  Future<void> readJSON(String file_path) async {
    String input = await rootBundle.loadString(file_path);
    var file = jsonDecode(input);
    final int floor = file["floor"];
    var map = file["nodes"];
    _nodes_length = map.length;


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
      distances[new_node] = 1000000;
      //print(new_node.getRooms());
    }
  }

  int getDist(Node n1, Node n2){
    return (sqrt(pow(n1.getXPos() - n2.getXPos(), 2) + pow(n1.getYPos() - n2.getYPos(), 2))).toInt();
  }

  Map<Node, int> pathFinder(Graph graph, Node ?source){
    Set<Node> visited = {};
    if (source == null) {
      return distances;
    }
    distances[source] = 0;

    final pq = PriorityQueue<Node>((a, b) => distances[a]! - distances[b]!);
    pq.add(source);
    while(pq.isNotEmpty){
      Node current = pq.removeFirst();
      if(!visited.contains(current)){
        visited.add(current);
        for(({int floor, int index}) neighbor_key in current.getAdjacentNodes()){
          Node? neighbor = getNode(neighbor_key.floor, neighbor_key.index);
          if (neighbor == null) continue;
          int distance = distances[current]! + graph.getDist(current, neighbor);
          if(distances[neighbor]! > distance){
            distances[neighbor] = distance;
            pq.add(neighbor);
          }
        }
      }
    }
    return distances;
  }


  //accessors
  Map<({int floor, int index}), Node> getNodes() {
    return _nodes;
  }

  Node? getNode(int floor, int index) {
    return _nodes[(floor : floor, index : index)];
  }

  int getNodesLength() {
    return _nodes_length;
  }
}