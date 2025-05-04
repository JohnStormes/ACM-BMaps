import 'package:flutter/material.dart';
import 'src/backend/graph.dart';
import 'src/backend/node.dart';

// This class is a widget containing the floor plan image,
// and the linepainter on top of the image.
// This class takes path_list as an argument, which is used to draw the path
class ImageWithLines extends StatelessWidget {
  final List<({int x, int y, Direction d})> path_list;
  String image;

  ImageWithLines({super.key, required this.path_list, required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          image,
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

// LinePainter paints the path line given to it in the parameter path_list
// the line is drawn using the visual variables defined below
class LinePainter extends CustomPainter {
  // line preference variables
  Color line_color = const Color.fromRGBO(230, 162, 242, 1);
  Color start_color = const Color.fromRGBO(162, 242, 170, 1);
  Color end_color = const Color.fromRGBO(242, 162, 162, 1);
  final double RADIUS = 5;

  // list of node locations in the path
  final List<({int x, int y, Direction d})> path_list;

  LinePainter(this.path_list);

  Path _getArrowPath(Direction d, double x, double y, double r) {
    Path res = Path();

    res.moveTo(x, y - r); // top head center
    res.lineTo(x + r, y); // bottom head right

    res.lineTo(x + r / 2.0, y); // top shaft right
    res.lineTo(x + r / 2.0, y + r); // bottom shaft right

    res.lineTo(x - r / 2.0, y + r); // bottom shaft left
    res.lineTo(x - r / 2.0, y); // top shaft left

    res.lineTo(x - r, y); // botton head left

    res.close();

    // if direction is down, flip the arrow
    if(d == Direction.down) {
      Matrix4 transformation = Matrix4.identity()
        ..translate(x, y)
        ..scale(1.0, -1.0)
        ..translate(-x, -y);

      res = res.transform(transformation.storage);
    }

    return res;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 3 paint colors, for the line, start circle, and end circle
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

    // guard clause: do nothing if empty, draw single green point if only 1 point
    if (path_list.isEmpty) return;
    if (path_list.length == 1) {
      final singlePoint = path_list[0];

      if(singlePoint.d == Direction.nd) {
        canvas.drawCircle(
          Offset(singlePoint.x.toDouble(), singlePoint.y.toDouble()),
          RADIUS,
          start_paint,
        );
      }
      else {
        Path p = Path();

        double r = RADIUS * 2;

        final Paint strokePaint = Paint()
          ..color = Colors.black
          ..strokeWidth = RADIUS * 0.125
          ..style = PaintingStyle.stroke;

        // up arrow
        p = _getArrowPath(singlePoint.d, singlePoint.x.toDouble(), singlePoint.y.toDouble(), r);

        // draw arrow
        canvas.drawPath(p, end_paint);

        // draw stroke
        canvas.drawPath(p, strokePaint);
      }

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
    var end = path_list[path_list.length - 1];

    double ex = end.x.toDouble();
    double ey = end.y.toDouble();

    if(end.d == Direction.nd) {
      canvas.drawCircle(
        Offset(ex, ey),
        RADIUS, 
        end_paint
      );
    }
    else { 
      Path p = Path();

      double r = RADIUS * 2;

      final Paint strokePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = RADIUS * 0.125
        ..style = PaintingStyle.stroke;

      // up arrow
      p = _getArrowPath(end.d, ex, ey, r);

      // draw arrow
      canvas.drawPath(p, end_paint);

      // draw stroke
      canvas.drawPath(p, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.path_list != path_list; // Return true if you need to repaint the line
  }
}