import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'graph.dart';
import 'building.dart';

class CustomSearchDelegate extends SearchDelegate {
  // this classes instance of the current graph
  Graph graph = Graph();

  int button_index = 0;
  List<String> search_terms = [];
  CustomSearchDelegate(int aButtonIndex, Graph aGraph, List<Building> aBuildings) {
    button_index = aButtonIndex;
    graph = aGraph;
    if (button_index == 0 || button_index == 1) {
      search_terms = graph.getRoomsList();
    } else if (button_index == 2) {
      for (int i = 0; i < aBuildings.length; i++) {
        search_terms.add(aBuildings[i].getTitle());
      }
    }
  }

  CustomSearchDelegate.fromBuildings(List<Building> aBuildings) {
    for (int i = 0; i < aBuildings.length; i++) {
      search_terms.add(aBuildings[i].getTitle());
    }
  }

  @override
  // button to clear the search list
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  // button to exit the search page
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      }
    );
  }

  @override
  // shows all rooms in search list (same code as buildSuggestions)
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var rooms in search_terms) {
      if (rooms.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(rooms);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result  = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          }
        );
      },
    );
  }

  @override
  // shows suggested rooms in search list (same code as buildResults)
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var rooms in search_terms) {
      if (rooms.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(rooms);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result  = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          }
        );
      },
    );
  }
}