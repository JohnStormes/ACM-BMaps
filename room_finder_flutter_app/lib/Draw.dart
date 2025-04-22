import 'package:flutter/material.dart';
import 'src/backend/graph.dart';
import 'src/backend/node.dart';

// GLOBAL VARS
Graph graph = Graph();
Map<Node, int> path = Map();

class ImageWithLines extends StatelessWidget {
  final List<({int x, int y})> path_list;

  ImageWithLines({super.key, required this.path_list});

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
            painter: LinePainter(path_list),
          ),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  Color line_color = const Color.fromRGBO(230, 162, 242, 1);
  Color start_color = const Color.fromRGBO(162, 242, 170, 1);
  Color end_color = const Color.fromRGBO(242, 162, 162, 1);
  final double RADIUS = 5;

  final List<({int x, int y})> path_list;

  LinePainter(this.path_list);

  @override
  void paint(Canvas canvas, Size size) {
    final line_paint = Paint()
      ..color = line_color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final start_paint = Paint()
      ..color = start_color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final end_paint = Paint()
      ..color = end_color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // ✅ Guard clause: do nothing if empty or has only 1 point
    if (path_list.isEmpty) return;
    if (path_list.length == 1) {
      final singlePoint = path_list[0];
      canvas.drawCircle(
        Offset(singlePoint.x.toDouble(), singlePoint.y.toDouble()),
        RADIUS,
        start_paint,
      );
      return;
    }

    // draw the line for the path using the saved x and y coordinates of the nodes
    for (int i = 1; i < path_list.length; i++) {
      // lines
      canvas.drawLine(
        Offset(path_list[i].x.toDouble(), path_list[i].y.toDouble()),
        Offset(path_list[i-1].x.toDouble(), path_list[i-1].y.toDouble()),
        line_paint
      );
    }
    // start circle
    canvas.drawCircle(
      Offset(path_list[0].x.toDouble(), path_list[0].y.toDouble()),
      RADIUS, 
      start_paint
    );
    // end circle
    canvas.drawCircle(
      Offset(path_list[path_list.length - 1].x.toDouble(), path_list[path_list.length - 1].y.toDouble()),
      RADIUS, 
      end_paint
    );
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.path_list != path_list; // Return true if you need to repaint the line
  }
}

Future<void> loadGraph() async {
  // load a JSON file
  await graph.readJSON("assets/data/library_tower_floor_6.json");
}

Future<List<({int x, int y})>> loadPath(String start_room, String end_room) async {
  List<({int x, int y})> new_path_list = [];
  // if either or one of the rooms isn't set, handle it for the canvas drawer
  if (start_room == "Start" && end_room == "Destination") {
    return new_path_list;
  } else if (start_room == "Start") {
    new_path_list.add((x : graph.getNodeWithRoom(end_room).getXPos(), y : graph.getNodeWithRoom(end_room).getYPos()));
    return new_path_list;
  } else if (end_room == "Destination") {
    new_path_list.add((x : graph.getNodeWithRoom(start_room).getXPos(), y : graph.getNodeWithRoom(start_room).getYPos()));
    return new_path_list;
  }
  // finds path from first to second room
  path = graph.pathFinder(graph, start_room, end_room);
  // get the nodes in the path hash map as a list
  var indexed_list = path.entries.toList();

  // save the nodes in the path as a list of x and y coordinates
  for (var entry in indexed_list) {
    new_path_list.add((x : entry.key.getXPos(), y : entry.key.getYPos()));
  }
  return new_path_list;
}