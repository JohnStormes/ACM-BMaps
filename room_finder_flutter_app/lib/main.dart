 import 'package:flutter/material.dart';
import 'package:room_finder_flutter_app/src/backend/node.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/backend/graph.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));

  // testing
  Graph test = Graph();
  // ALWAYS await when loading data such that app waits for data to be loaded before proceeding
  await test.readJSON("assets/data/library_tower_floor_6.json");
  var nodes = test.getNodes();
  int nodes_length = test.getNodesLength();

  Map<Node, int> list = test.pathFinder(test, nodes[(floor : 6, index : 0)]);
  list.forEach((key, value) { print(key.getFloorAndIndex().toString() + ' + ' + value.toString()); } );

  print("\nrooms list:");

  for (int i = 0; i < nodes_length; i++) {
    print(nodes[(floor : 6, index : i)]?.getRooms());
  }
}
