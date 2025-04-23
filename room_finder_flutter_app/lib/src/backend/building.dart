// Johnathan Stormes
import 'graph.dart';
import 'node.dart';
import 'dart:math';

class Building{
  Graph _master_graph = new Graph();

  Building(List<String> floor_plan_files) {
    for (int i = 0; i < floor_plan_files.length; i++) {
      //_master_graph.readJSON(floor_plan_files[i]);
    }
  }

  /*
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
  */
}