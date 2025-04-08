SUBJECT TO CHANGE, PLEASE UPDATE IF ANY INFORMATION IS INCORRECT OR DOESNT MAKE SENSE

UI:
Tymur when you can, update this section


code organization general notes:
- all floorplans will be stored as both an image (of any size), and also an object (or other data type)
- database should have organization structure containing buildings, which contain floorplans
- floorplan objects/data should store:
  1. the length and width of the corresponding floorplan image
  2. A list of nodes, which should store:
    - an x and y coordinate within the bounds of the length and width of the floorplan
    - a list of corresponding rooms connected to the node
    - (maybe) a hashmap containing distances to any connected nodes for use in path finding algorithm
  2. a list of nodes, initially empty, which is initialized in a function to contain the nodes within the generated path
    - since a path may include routing to different floors/floorplans, the function that initializes the list of path nodes should be in a container class of some sort
- pathfinding algorithm
  1. really any algorithm can be selected
  2. even if the user starts on a floor that is not the same as the destination, in 99% of cases, only 2 floorplans will be required. Only edge case is if between the inital floor and the destination floor, there is no continuous staircase/elevator, and the user has to transfer to a different staircase/elevator on a middle floor
  3. algorithm will use full list of nodes for each used floor, and distances to find optimal path
  4. distances can either be found from a hashmap in each node, OR a distance formula function which calculates the distance between 2 nodes (each node has an x and y value)
- a class diagram would be nice for this

things to consider with code organization:
- how will different floor plans interact with eachother when a path runs through multiple floors of a building?
  1. should be simple in practice, a list of path nodes for a single floorplan should not have any inherant relation to the nodes in another floorplan which are a part of the same overarching path, other then the fact that they are connected by the same staircase or elevator

Common bug fixes:
error - Cannot create service of type BuildSessionActionExecutor using method LauncherServices$ToolingBuildSessionScopeServices.createActionExecutor() as there is a problem with parameter #21 of type FileSystemWatchingInformation.
solution - open terminal in android folder within project and run ./gradlew --stop

Task / git workflow:
- some version of a branch system with requested, reviewed, and accepted merges


USER STORY:
As a user, I can...
  - Enter the building where my class is
  - Enter where I am currently
  - Enter the class room that I am trying to get to
  - See a path to my room
  - Change floors to see a part of the path that's on a different floor
  - Enter a room near me to update the path if I get lost
  - Restart the process if I realized I was heading to the wrong class or misinputed my class room
  - Save my classes and their paths (?)
  - See first a google maps path to the building and then the floorplan path once I reach the building(?)
