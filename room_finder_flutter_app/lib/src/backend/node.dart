class Node
{
  // key of this node
  late final ({int floor, int index}) _key;

  // pixel coordinate of node
  // access with _position.x and _position.y
  late final ({int x, int y}) _position;

  // false if empty rooms list (used purely for pathing), true if there are any connected rooms
  late final bool _hasRooms;

  // parent node used for retracing path
  late List<Node> parentNodes;

  // rooms and connections lists
  Set<String> _rooms = {};
  Set<({int floor, int index})> _connections = {};

  Node(int f, int i, int xPos, int yPos, String rooms, String connections) //Adding rooms is optional
  {
    // initialize the index of this node
    _key = (floor : f, index : i);

    // initialize the coordinate position of the node
    _position = (x : xPos, y : yPos);

    // check if the node is connected to any rooms, and if so, initialize rooms list
    if (rooms != "") {
      _rooms = rooms.split(',').toSet();
      _hasRooms = true;
    } 
    else {
        _hasRooms = false;
    }

    // initialize node connections list as list of integers representing node keys
    List<String> connections_string = connections.split(',').toList();
    for (int i = 0; i < connections_string.length; i++) {
      int connection_floor = int.parse(connections_string[i].split('-').toList()[0]);
      int connection_index = int.parse(connections_string[i].split('-').toList()[1]);

      _connections.add((floor: connection_floor, index: connection_index));
    }
  }

  //Checks if two nodes are the same node
  bool equals(Node n2){
    return _key == n2._key;
  }

  void printNode(){
    print(_key);
  }

  //Adds a parent node to the list
  void addParentNode(Node n1){
    parentNodes.add(n1);
  }

  ({int floor, int index}) getFloorAndIndex(){
    return _key;
  }

  // accessors
  int getXPos()
  {
    return _position.x;
  }
  int getYPos()
  {
    return _position.y;
  }
  bool hasRooms()
  {
    return _hasRooms;
  }
  Set getRooms()
  {
    return _rooms;
  }

  Set getAdjacentNodes()
  {
    return _connections;
  }
}