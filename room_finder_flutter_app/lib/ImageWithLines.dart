import 'package:flutter/material.dart';
import 'src/backend/graph.dart';
import 'src/backend/node.dart';

Graph graph = Graph();
Map<Node, int> path = Map();
Map<({int floor, int index}), Node> graph_map = Map();

class ImageWithLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/library_tower_floor_6.png',
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: LinePainter(),
          ),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round; // Optional: Round the line ends

    // draw direction lines
    // CURRENTLY DRAWS DOUBLE LINES
    var indexed_list = path.entries.toList();
    var drawn_edges = <String>{};

    for (int i = 0; i < indexed_list.length; i++) {
      var key = indexed_list[i].key;
      Set adjacencies = key.getAdjacentNodes();

      // iterate through the adjacent nodes, and draw the edge line if it has not already been drawn
      for (var adjacentKey in adjacencies) {
        // continue if the adjacent node is not a part of the path
        var adjacent_node = graph_map[adjacentKey];
        if (adjacent_node == null || !path.containsKey(adjacent_node)) continue;

        // create a unique key for the current edge
        var key_hash = key.hashCode;
        var connection_hash = adjacentKey.hashCode;
        var edgeKey = key_hash < connection_hash ? "$key_hash-$connection_hash" : "$connection_hash-$key_hash";

        if (!drawn_edges.contains(edgeKey)) {
          // if the set does not yet contain this edge, add it to the set
          drawn_edges.add(edgeKey);

          canvas.drawLine(
            Offset(key.getXPos().toDouble(), key.getYPos().toDouble()),
            Offset(graph_map[adjacentKey]!.getXPos().toDouble(), graph_map[adjacentKey]!.getYPos().toDouble()),
            paint
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // Return true if you need to repaint the line
  }
}

Future<void> LoadGraph() async {
  // load a JSON file
  await graph.readJSON("assets/data/library_tower_floor_6.json");
  graph_map = graph.getNodes();
  path = graph.pathFinder(graph, graph_map[(floor : 6, index : 0)], graph_map[(floor : 6, index : 21)]);
  //path = graph.dijkstraShortestPath(graph.getNodes(), (floor : 6, index : 0), (floor : 6, index : 5));

  // get path6
  //path = graph.pathFinder(graph, nodes[(floor : 6, index : 0)]);
  //graph_map = graph.getNodes();
}