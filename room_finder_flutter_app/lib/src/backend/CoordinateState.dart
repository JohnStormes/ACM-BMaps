import 'package:a_star/a_star.dart';
import 'node.dart';

class CoordinateState extends AStarState<CoordinateState>{
  late Node goal;
  late Node currNode;
  late int x;
  late int y;
  CoordinateState(Node n1, Node n2, {required super.depth}){
    this.x = n1.getXPos();
    this.y = n2.getYPos();
    goal = n2;
    currNode = n1;
  }

  static List<Node> aStarShortestPath(Node startPoint, Node endPoint) {
    List<CoordinateState> path = [];
    List<Node> nodePath = [];
    CoordinateState start = CoordinateState(startPoint, endPoint, depth: 1);
    final result = aStar(start);
    if (result != null){
      path = result.reconstructPath().toList(growable: true);
    }
    for(CoordinateState sp in path){
      nodePath.add(sp.getNode());
    }
    return nodePath;
  }

  @override
  Iterable<CoordinateState> expand(){
    List<CoordinateState> list = [];
    for(Node n in currNode.getAdjacentNodes()){
      list.add(CoordinateState(n, goal, depth: depth + 1));
    }
    return list;
  }


  @override
  String hash() => "($x, $y)";

  @override
  double heuristic() => ((goal.getXPos()-currNode.getXPos()).abs() + (goal.getYPos()-currNode.getYPos()).abs()).toDouble();

  @override
  bool isGoal() => currNode.equals(goal);


  Node getNode(){
    return currNode;
  }
}