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


  Map<Node, int> pathFinder(Graph graph, Node ?source, Node ?destination){
    final distances = <Node, int>{};
    final previous = <Node, Node?>{};
    final visited = <Node>{};

    if (source == null || destination == null) {
      print("null node passed into dijkstras");
      return Map<Node, int>();
    }

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

      // stop early if we reach the destination
      if (current == destination) break;

      for(({int floor, int index}) neighbor_key in current.getAdjacentNodes()){
        Node? neighbor = graph.getNode(neighbor_key.floor, neighbor_key.index);
        if (neighbor == null || visited.contains(neighbor)) continue;

        int distance = distances[current]! + graph.getDist(current, neighbor);
        if(distances[neighbor]! > distance){
          distances[neighbor] = distance;
          previous[neighbor] = current;
          pq.add(neighbor);
        }
      }
    }

    // reconstruct the path from destination to source
    Map<Node, int> shortest_path = {};
    Node? current = destination;
    while (current != null) {
      shortest_path[current] = distances[current]!;
      current = previous[current];
    }
    return shortest_path;
  }

  /*
  Map<Node, int> dijkstraShortestPath(
    Map<({int floor, int index}), Node> graph,
    ({int floor, int index}) startKey,
    ({int floor, int index}) endKey
  ) {
    final distance = <({int floor, int index}), double>{};
    final previous = <({int floor, int index}), ({int floor, int index})?>{};
    final visited = <({int floor, int index})>{};

    // Priority queue (min-heap behavior using SplayTreeMap)
    final priorityQueue = SplayTreeMap<({int floor, int index}), double>(
      (a, b) {
        // compare based on distances
        return (distance[a] ?? double.infinity)
            .compareTo(distance[b] ?? double.infinity);
      },
    );

    // Initialize distances
    for (var key in graph.keys) {
      distance[key] = double.infinity;
      previous[key] = null;
    }

    distance[startKey] = 0;
    priorityQueue[startKey] = 0;

    while (priorityQueue.isNotEmpty) {
      var currentKey = priorityQueue.firstKey();
      priorityQueue.remove(currentKey);

      if (visited.contains(currentKey)) continue;
      visited.add(currentKey!);

      if (currentKey == endKey) break;

      var currentNode = graph[currentKey]!;
      for (var neighborKey in currentNode.getAdjacentNodes()) {
        if (!graph.containsKey(neighborKey)) continue;

        var neighborNode = graph[neighborKey]!;
        var weight = euclideanDistance(currentNode, neighborNode);
        var altDist = (distance[currentKey] ?? double.infinity) + weight;

        if (altDist < (distance[neighborKey] ?? double.infinity)) {
          distance[neighborKey] = altDist;
          previous[neighborKey] = currentKey;
          priorityQueue[neighborKey] = altDist;
        }
      }
    }

    // Reconstruct the path from endKey to startKey
    Map<Node, int> path = {};
    var step = 0;
    var current = endKey;
    if (previous[current] != null || current == startKey) {
      while (current != null && previous.containsKey(current)) {
        path[graph[current]!] = step++;
        if (current == startKey) break;
        current = previous[current]!;
      }
    }

    return Map.fromEntries(path.entries.toList().reversed);
  }

  double euclideanDistance(Node a, Node b) {
    double dx = (a.getXPos() - b.getXPos()).toDouble();
    double dy = (a.getYPos() - b.getYPos()).toDouble();
    return sqrt(dx * dx + dy * dy);
  }
  */


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