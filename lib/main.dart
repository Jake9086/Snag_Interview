// Copyright (C) 2024, Snag Delivery, Inc. All Rights Reserved
// CONFIDENTIAL
// Please do not distribute without prior authorization from Snag Delivery, Inc.

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'goblin_controller.dart';

void main() {
  runApp(const GoblinChieftainApp());
}

class GoblinChieftainApp extends StatelessWidget {
  const GoblinChieftainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Goblin Chieftain Game',
      home: GoblinChieftainGame(),
    );
  }
}

class GoblinChieftainGame extends StatefulWidget {
  const GoblinChieftainGame({super.key});

  @override
  _GoblinChieftainGameState createState() => _GoblinChieftainGameState();
}

class _GoblinChieftainGameState extends State<GoblinChieftainGame> {
  late GoblinChieftain game;
  late GoblinController controller;
  bool isGameInitialized = false;
  bool isSimulating = false;
  int initialSeed = 12346;
  int movesToTimeOut = 100000;
  bool isManualMode = true;
  TextEditingController seedController = TextEditingController();
  TextEditingController simulationRunsController =
      TextEditingController(text: '10');
  Timer? gameLoopTimer;
  bool showInstructions = false;
  String simulationResult = '';

  @override
  void initState() {
    super.initState();
    controller = GoblinController();
    seedController = TextEditingController(text: initialSeed.toString());
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Goblin Chieftain Game - Seed: ${isGameInitialized ? game.seed : initialSeed}'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!isGameInitialized) _buildSeedInput(),
              if (isGameInitialized) ...[
                Expanded(child: _buildGameGrid()),
                const SizedBox(height: 8),
                _buildGameStats(),
                const SizedBox(height: 8),
                if (isManualMode)
                  _buildManualControls()
                else
                  _buildSimulationControls(),
              ]
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  showInstructions = true;
                });
              },
              onExit: (_) {
                setState(() {
                  showInstructions = false;
                });
              },
              child: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.info),
              ),
            ),
          ),
          if (showInstructions)
            Positioned(
              bottom: 80,
              right: 20,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Instructions:\n'
                  '- Move the goblin with goblin_controller or simulate button\n'
                  '- Collect resources (gold, chest, diamond)\n'
                  '- Avoid traps\n'
                  '- Return to the village to drop collected items',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          Positioned(
            bottom: 100,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  int seed = int.tryParse(seedController.text) ?? 12346;
                  game = GoblinChieftain(controller, seed: seed);
                  isGameInitialized = true;
                });
              },
              child: const Text('Reset Map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: seedController,
            decoration: const InputDecoration(
              labelText: "Enter Seed",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                int seed = int.tryParse(seedController.text) ?? 12346;
                game = GoblinChieftain(controller, seed: seed);
                isGameInitialized = true;
              });
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildManualControls() {
    return Column(
      children: [
        _buildControlPanel(),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isManualMode = false;
              isSimulating = true;
              _runSimulation();
            });
          },
          child: const Text('Start Simulation'),
        ),
      ],
    );
  }

  Widget _buildSimulationControls() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isSimulating = false;
              isManualMode = true;
              gameLoopTimer?.cancel();
            });
          },
          child: const Text('Stop Simulation'),
        ),
        const SizedBox(height: 8),
        _buildSimulationRunsInput(),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            _runMultipleSimulations();
          },
          child: const Text('Run Multiple Simulations'),
        ),
        if (simulationResult.isNotEmpty)
          Text(simulationResult, textScaler: const TextScaler.linear(0.8)),
      ],
    );
  }

  Widget _buildSimulationRunsInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: simulationRunsController,
            decoration: const InputDecoration(
              labelText: "Enter Number of Runs",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  void _runSimulation() {
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (game.gameState.contains('lost') || game.gameState.contains('won')) {
        timer.cancel();
        _showGameOverDialog();
      } else {
        setState(() {
          game.autoMove();
        });
      }
    });
  }

  void _runMultipleSimulations() {
    setState(() {
      simulationResult = '';
    });

    int runs = int.tryParse(simulationRunsController.text) ?? 10;
    bool trapHit = false;
    List<int> seedsUsed = [];
    List<int> movesPerRun = [];

    int currentSeed = int.tryParse(seedController.text) ?? initialSeed;

    for (int i = 0; i < runs; i++) {
      seedsUsed.add(currentSeed);
      game = GoblinChieftain(controller, seed: currentSeed);

      int currentRunMoves = 0;

      while (game.gameState.contains('ongoing') &&
          currentRunMoves < movesToTimeOut) {
        game.autoMove();
        currentRunMoves++;

        if (game.grid[game.goblinPosition['y']!][game.goblinPosition['x']!] ==
            'T') {
          trapHit = true;
          break;
        }
      }

      movesPerRun.add(currentRunMoves);

      if (trapHit) {
        setState(() {
          _showSimulationStatsDialog(movesPerRun, seedsUsed);
        });
        return;
      }

      currentSeed += 1;
    }

    setState(() {
      _showSimulationStatsDialog(movesPerRun, seedsUsed);
    });
  }

  void _showSimulationStatsDialog(List<int> movesPerRun, List<int> seedsUsed) {
    List<int> successfulMoves = [];
    int stuckCount = 0;

    for (int i = 0; i < movesPerRun.length; i++) {
      if (movesPerRun[i] < movesToTimeOut) {
        successfulMoves.add(movesPerRun[i]);
      } else {
        stuckCount++;
      }
    }

    double mean = successfulMoves.isNotEmpty
        ? successfulMoves.reduce((a, b) => a + b) / successfulMoves.length
        : 0;

    List<int> sortedMoves = List.from(successfulMoves)..sort();
    num median = sortedMoves.isNotEmpty
        ? (sortedMoves.length % 2 == 0)
            ? (sortedMoves[sortedMoves.length ~/ 2 - 1] +
                    sortedMoves[sortedMoves.length ~/ 2]) /
                2
            : sortedMoves[sortedMoves.length ~/ 2]
        : 0;

    double stuckPercentage = (stuckCount / movesPerRun.length) * 100;

    String formattedStats = '';
    for (int i = 0; i < seedsUsed.length; i++) {
      String stuckNote =
          movesPerRun[i] >= movesToTimeOut ? ' (Goblin stuck)' : '';
      formattedStats +=
          'Seed: ${seedsUsed[i]}, Moves: ${movesPerRun[i]}$stuckNote\n';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Simulation Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Runs: ${movesPerRun.length}'),
              Text('Mean moves (without stuck): ${mean.toStringAsFixed(2)}'),
              Text('Median moves (without stuck): $median'),
              Text(
                  'Stuck goblin percentage: ${stuckPercentage.toStringAsFixed(2)}%'),
              const SizedBox(height: 8),
              const Text('Seeds and Moves:'),
              SizedBox(
                height: 250,
                child: SingleChildScrollView(
                  child: Text(
                    formattedStats,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameGrid() {
    double gridSquareSize = min(
      (MediaQuery.of(context).size.width - 32) / game.gridSize,
      (MediaQuery.of(context).size.height - 300) / game.gridSize,
    );

    return Center(
      child: SizedBox(
        width: gridSquareSize * game.gridSize,
        height: gridSquareSize * game.gridSize,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: game.gridSize,
          ),
          itemCount: game.gridSize * game.gridSize,
          itemBuilder: (context, index) {
            int x = index % game.gridSize;
            int y = index ~/ game.gridSize;
            String terrain = game.grid[y][x];

            return Container(
              width: gridSquareSize,
              height: gridSquareSize,
              margin: const EdgeInsets.all(1),
              color: game.isTileVisible(x, y)
                  ? _getTerrainColor(terrain)
                  : Colors.black,
              child: game.isTileVisible(x, y)
                  ? (game.goblinPosition['x'] == x &&
                          game.goblinPosition['y'] == y
                      ? Image.asset('assets/goblin.gif')
                      : _getTerrainIcon(terrain))
                  : const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Inventory: ${game.inventory.length}/3'),
          Text('Moves Taken: ${game.movesTaken}'),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () => setState(() {
                game.move(0, -1);
              }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                game.move(-1, 0);
              }),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => setState(() {
                game.move(1, 0);
              }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () => setState(() {
                game.move(0, 1);
              }),
            ),
          ],
        ),
        if (['G', 'D', 'C'].contains(
            game.grid[game.goblinPosition['y']!][game.goblinPosition['x']!]))
          ElevatedButton(
            onPressed: () {
              setState(() {
                game.collectResource();
              });
            },
            child: const Text('Pick Up'),
          ),
        if (game.goblinPosition['x'] == game.gridSize ~/ 2 &&
            game.goblinPosition['y'] == game.gridSize ~/ 2 &&
            game.inventory.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              setState(() {
                game.dropResource();
              });
            },
            child: const Text('Drop'),
          ),
      ],
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(
            'Game Over! You ${game.gameState == 'won' ? 'won' : 'lost'} with a moves count of ${game.movesTaken}.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                int newSeed = Random().nextInt(100000);
                game = GoblinChieftain(controller, seed: newSeed);
                Navigator.of(context).pop();
              });
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  Color _getTerrainColor(String terrain) {
    switch (terrain) {
      case 'V':
        return Colors.green;
      case 'F':
        return Colors.green;
      case 'M':
        return Colors.grey;
      case 'R':
        return Colors.blue;
      case 'B':
        return Colors.brown;
      case 'T':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _getTerrainIcon(String terrain) {
    String assetPath;
    String backgroundTerrain;

    switch (terrain) {
      case 'G':
        assetPath = 'assets/gold.gif';
        backgroundTerrain = 'F';
        break;
      case 'D':
        assetPath = 'assets/diamond.gif';
        backgroundTerrain = 'M';
        break;
      case 'C':
        assetPath = 'assets/chest.png';
        backgroundTerrain = 'M';
        break;
      case 'T':
        assetPath = 'assets/trap.png';
        backgroundTerrain = 'F';
        break;
      case 'V':
        return Image.asset('assets/village.png');
      default:
        return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Container(color: _getTerrainColor(backgroundTerrain)),
        Image.asset(assetPath),
      ],
    );
  }
}

class GoblinChieftain {
  final int gridSize;
  final int goldCount;
  final int trapCount;
  final int diamondCount;
  final int goldCoinCount;
  final int seed;
  late Random random;
  late List<List<String>> grid;
  late Map<String, int> goblinPosition;
  late List<String> inventory;
  late int movesTaken;
  late String gameState;
  late int totalItemsCollected;
  GoblinController controller;

  GoblinChieftain(this.controller,
      {this.gridSize = 13,
      this.goldCount = 1,
      this.trapCount = 2,
      this.diamondCount = 2,
      this.goldCoinCount = 2,
      required this.seed}) {
    random = seededRandom(seed);
    initializeGame();
  }

  Random seededRandom(int seed) {
    return Random(seed);
  }

  void initializeGame() {
    grid = initializeGrid();
    goblinPosition = {
      'x': (gridSize / 2).floor(),
      'y': (gridSize / 2).floor(),
    };
    inventory = [];
    movesTaken = 0;
    gameState = 'ongoing';
    totalItemsCollected = 0;
  }

  List<List<String>> initializeGrid() {
    List<List<String>> grid =
        List.generate(gridSize, (_) => List.filled(gridSize, 'F'));
    List<Map<String, dynamic>> parallelRiverGroups = [];

    int center = (gridSize / 2).floor();
    grid[center][center] = 'V';

    Map<String, int> getRandomCoordinates(String terrainType) {
      int x, y;
      do {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      } while ((x == center && y == center) || grid[y][x] != terrainType);
      return {'x': x, 'y': y};
    }

    void addItemsToGrid(String itemType, int count, String terrainType) {
      for (int i = 0; i < count; i++) {
        final coords = getRandomCoordinates(terrainType);
        final int x = coords['x']!;
        final int y = coords['y']!;
        grid[y][x] = itemType;
      }
    }

    void addRiver() {
      bool isHorizontal = random.nextBool();
      int fixedCoord = random.nextInt(gridSize - 4) + 2;
      List<Map<String, int>> riverGroup = [];

      for (int i = 2; i < gridSize - 2; i++) {
        int x = isHorizontal ? i : fixedCoord;
        int y = isHorizontal ? fixedCoord : i;

        if (x != center || y != center) {
          grid[y][x] = 'R';
          riverGroup.add({'x': x, 'y': y});
        }
      }

      parallelRiverGroups.add({
        'isHorizontal': isHorizontal,
        'fixedCoord': fixedCoord,
        'group': riverGroup
      });
    }

    addRiver();
    addRiver();

    void addBridges() {
      for (var group in parallelRiverGroups) {
        int randomIndex = random.nextInt(group['group'].length);
        int x = group['group'][randomIndex]['x'];
        int y = group['group'][randomIndex]['y'];
        grid[y][x] = 'B';
      }
    }

    addBridges();

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if ((x <= 1 || x >= gridSize - 2 || y <= 1 || y >= gridSize - 2)) {
          grid[y][x] = 'M';
        }
      }
    }

    addItemsToGrid('G', goldCoinCount, 'F');
    addItemsToGrid('D', diamondCount, 'M');
    addItemsToGrid('C', goldCount, 'M');
    addItemsToGrid('T', trapCount ~/ 2, 'F');
    addItemsToGrid('T', trapCount ~/ 2, 'M');

    return grid;
  }

  bool isTileVisible(int x, int y) {
    int distance =
        max((goblinPosition['x']! - x).abs(), (goblinPosition['y']! - y).abs());
    return distance <= 1;
  }

  Map<String, dynamic> autoMove() {
    Map<String, dynamic> surroundings = {
      'left':
          getSurroundingTile(goblinPosition['x']! - 1, goblinPosition['y']!),
      'right':
          getSurroundingTile(goblinPosition['x']! + 1, goblinPosition['y']!),
      'up': getSurroundingTile(goblinPosition['x']!, goblinPosition['y']! - 1),
      'down':
          getSurroundingTile(goblinPosition['x']!, goblinPosition['y']! + 1),
    };

    Map<String, dynamic> currentCell = {
      'terrain': grid[goblinPosition['y']!][goblinPosition['x']!]
    };

    String action = controller.turn(currentCell, surroundings, goblinPosition, grid);

    int dx = 0, dy = 0;
    switch (action) {
      case 'left':
        dx = -1;
        break;
      case 'right':
        dx = 1;
        break;
      case 'up':
        dy = -1;
        break;
      case 'down':
        dy = 1;
        break;
      case 'collect':
        collectResource();
        break;
      case 'drop':
        dropResource();
        break;
    }
    return move(dx, dy);
  }

  Map<String, dynamic> move(int dx, int dy) {
    int newX = goblinPosition['x']! + dx;
    int newY = goblinPosition['y']! + dy;

    if (newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize) {
      if (grid[newY][newX] != 'R' || grid[newY][newX] == 'B') {
        goblinPosition['x'] = newX;
        goblinPosition['y'] = newY;
        if (grid[newY][newX] == 'M') {
          movesTaken += 2;
        } else {
          movesTaken += 1;
        }
        if (totalItemsCollected == goldCoinCount + diamondCount + goldCount) {
          gameState = 'won';
          return returnGameState('won');
        }
        if (grid[newY][newX] == 'T') {
          gameState = 'lost';
          return returnGameState('lost');
        }
      }
    }

    return returnGameState('ongoing');
  }

  void collectResource() {
    String terrain = grid[goblinPosition['y']!][goblinPosition['x']!];
    if (['G', 'D', 'C'].contains(terrain) && inventory.length < 3) {
      inventory.add(terrain);
      if (terrain == 'G' || terrain == 'C' || terrain == 'D') {
        if (terrain == 'D' || terrain == 'C') {
          grid[goblinPosition['y']!][goblinPosition['x']!] = 'M';
        } else {
          grid[goblinPosition['y']!][goblinPosition['x']!] = 'F';
        }
      }
    }
  }

  void dropResource() {
    if (goblinPosition['x'] == gridSize ~/ 2 &&
        goblinPosition['y'] == gridSize ~/ 2 &&
        inventory.isNotEmpty) {
      totalItemsCollected += inventory.length;
      inventory.clear();
    }
  }

  Map<String, dynamic> getSurroundingTile(int x, int y) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) {
      return {'terrain': 'outOfBounds'};
    }
    return {'terrain': grid[y][x]};
  }

  Map<String, dynamic> returnGameState(String gameState) {
    List<Map<String, dynamic>> surroundingTiles =
        getSurroundingTiles(goblinPosition['x']!, goblinPosition['y']!);
    return {
      'goblinPosition': goblinPosition,
      'inventory': inventory,
      'movesTaken': movesTaken,
      'gameOver': gameState,
      'surroundingTiles': surroundingTiles
    };
  }

  List<Map<String, dynamic>> getSurroundingTiles(int x, int y) {
    List<Map<String, dynamic>> tiles = [];
    List<int> offsets = [-1, 0, 1];
    for (int dx in offsets) {
      for (int dy in offsets) {
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize) {
          tiles.add({
            'x': nx,
            'y': ny,
            'terrain': grid[ny][nx],
          });
        }
      }
    }
    return tiles;
  }
}