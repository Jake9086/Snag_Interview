// Copyright (C) 2024, Snag Delivery, Inc. All Rights Reserved
// CONFIDENTIAL
// Please do not distribute without prior authorization from Snag Delivery, Inc.

class GoblinController {
  bool only1Tracker = true;
  int inventory = 0;
  var target = <String, int>{}; // Target position (resource or village)
  List<Map<String, int>> resourceList = []; 
  String turn(
    Map<String, dynamic> currentCell, Map<String, dynamic> surroundings, Map<String,int> goblinPosition,  List<List<String>> grid) {
    resourceList = findResources(grid);
    // Get the terrain of the current cell
    String terrain = grid[goblinPosition['y']!][goblinPosition['x']!];

    // Step 1: Check if we have a target resource or if we should be heading to the village
    if (target.isEmpty) {
      // If there's no target, find the nearest resource or decide to return to the village
      target = findNearestResource(goblinPosition,resourceList);
    }

    // Step 2: Find the best direction to move towards the target (using pathfinding)

  List<Map<String, int>> path = findPath(goblinPosition, target);
   
   if (inventory == 3) {
    target['x'] = 6;
    target['y'] = 6; 
     path = findPath(goblinPosition, target);
      }
   if((goblinPosition['x'] == target['x']) && (goblinPosition['y'] == target['y']) && (inventory < 3)) { 
      resourceList.removeWhere((position) =>
      position['x'] == target['x'] && position['y'] == target['y']);
     if(resourceList.isEmpty && only1Tracker ){
      target['x'] = 6;
    target['y'] = 6; 
     path = findPath(goblinPosition, target);
     only1Tracker = false;
     return 'collect';
     } if(resourceList.isNotEmpty){
     target = findNearestResource(goblinPosition,resourceList);
     findPath(goblinPosition, target);
     inventory++;
      return 'collect';
   }
      }
    if(((goblinPosition['x'] == 6) && (goblinPosition['y'] == 6) && (inventory == 3)) || resourceList.length <= 1) { 
      target = findNearestResource(goblinPosition,resourceList);
      inventory = 0;
      return 'drop';
      }
    
    // If we have a path to follow, return the first step in the path
    if (path.isNotEmpty) {
      Map<String, int> nextStep = path[0]; // The next step to take (first step after the current position)
      
      // Return the direction based on the target's position relative to the goblin's current position
      if (nextStep['x']! < goblinPosition['x']!) return 'left';
      if (nextStep['x']! > goblinPosition['x']!) return 'right';
      if (nextStep['y']! < goblinPosition['y']!) return 'up';
      if (nextStep['y']! > goblinPosition['y']!) return 'down';
    }
    // Step 3: If there are no valid moves from the pathfinding, avoid traps or move randomly
    // Check if there is a trap in the surrounding tiles
    for (var direction in surroundings.values) {
      String surroundingTerrain = direction['terrain'];
    
      if (surroundingTerrain == 'T') {
        if(currentCell['x'] == false || currentCell['y'] == null){
            return 'right';
        }
        // Avoid the trap by moving away from it
        if (direction['x'] < currentCell['x']) return 'right';
        if (direction['x'] > currentCell['x']) return 'left';
        if (direction['y'] < currentCell['y']) return 'down';
        if (direction['y'] > currentCell['y']) return 'up';
      }

      if(surroundingTerrain == 'G' ||surroundingTerrain == 'D' || surroundingTerrain =='C'){
        if(currentCell['x'] == false || currentCell['y'] == null){
            return 'right';
        }
      if (direction['x']! < goblinPosition['x']!) return 'left';
      if (direction['x']! > goblinPosition['x']!) return 'right';
      if (direction['y']! < goblinPosition['y']!) return 'up';
      if (direction['y']! > goblinPosition['y']!) return 'down';
      }
    }

    // If there are no traps, move randomly (or explore more)
    List<String> possibleDirections = ['left', 'right', 'up', 'down'];
    return possibleDirections[DateTime.now().millisecond % 4];  // Random direction for fallback
  }

  // Find the nearest resource (or village if no resources are available)
  Map<String, int> findNearestResource(Map<String, int> goblinPosition, List<Map<String, int>> resourceList) {
  Map<String, int> closestResource = {} ;
  int shortestDistance = 9999999999;  // Start with a very large number for comparison
  
  // Loop through all the resources and find the closest one to the goblin position
  for (var resource in resourceList) {
    int distance = calculateDistance(goblinPosition, resource);
    
    if (distance < shortestDistance) {
      shortestDistance = distance;
      closestResource = resource;
    }
  }
  
  return closestResource;
}

 List<Map<String, int>> findPath(Map<String, int> goblinPosition, Map<String, int> target) {
  List<Map<String, int>> path = [];

  if (target.isEmpty) {
    resourceList.removeWhere((position) =>
      position['x'] == target['x'] && position['y'] == target['y']);
     target = findNearestResource(goblinPosition,resourceList);
     findPath(goblinPosition, target);
    } // Take it out of the list so we can find the next one.

  // Directly move toward the target by calculating the difference
  int dx = target['x']! - goblinPosition['x']!;
  int dy = target['y']! - goblinPosition['y']!;

  // Add the current position to the path
  path.add(Map.from(goblinPosition));

  // Calculate steps in both x and y directions
  int steps = (dx.abs() > dy.abs()) ? dx.abs() : dy.abs();

  for (int i = 0; i < steps; i++) {
    if (dx != 0) {
      goblinPosition['x'] = goblinPosition['x']! + (dx > 0 ? 1 : -1);
      dx -= (dx > 0 ? 1 : -1);
    }
    if (dy != 0) {
      goblinPosition['y'] = goblinPosition['y']! + (dy > 0 ? 1 : -1);
      dy -= (dy > 0 ? 1 : -1);
    }
    path.add(Map.from(goblinPosition)); // Add the new position to the path
  }

  return path;
}


int calculateDistance(Map<String, int> start, Map<String, int> end) {
  return (start['x']! - end['x']!).abs() + (start['y']! - end['y']!).abs();
}

List<Map<String, int>> findResources(List<List<String>> grid) {
  List<Map<String, int>> resourceList = [];

  for (int y = 0; y < 13; y++) {
    for (int x = 0; x < 13; x++) {
      if (grid[y][x] == 'G' || grid[y][x] == 'D' || grid[y][x] == 'C') {
        resourceList.add({'x': x, 'y': y});
      }
    }
  }

  return resourceList;
}
}

