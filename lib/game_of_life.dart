import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';

/// Represents a point in (X, Y) space.
class Point {
  num x;
  num y;

  Point(this.x, this.y);

  /// Get 8 adjacent points
  List<Point> get adjacent {
    final List<Point> adjacent = [];
    for (final dx in [-1, 0, 1]) {
      for (final dy in [-1, 0, 1]) {
        if (dx == 0 && dy == 0) {
          continue;
        }
        adjacent.add(Point(x + dx, y + dy));
      }
    }
    return adjacent;
  }

  /// Check if the point is inside the limits
  bool insideLimit(num height, num width) {
    return (!y.isNegative && y < height) && (!x.isNegative && x < width);
  }

  /// Calculates the offset of the point in a space of [size] units
  Offset offset(Size size) {
    return Offset(x * size.width, y * size.height);
  }

  /// Point hash using Cantor's enumeration of pairs
  @override
  get hashCode {
    return ((x + y) * (x + y + 1) ~/ 2 + y).toInt() ;
  }

  @override
  bool operator ==(Object other) {
    return other is Point && x == other.x && y == other.y;
  }

  @override
  String toString() {
    return 'Point($x, $y)';
  }
}

/// Represents an instance of Conway's Game of Life
class GameOfLife {
  /// Indicate that the display requires a rerender
  bool markedForRedraw = true;

  /// Limit on simulation's X value
  num heightLimit = 0;

  /// Limit on simulation's Y value
  num widthLimit = 0;

  /// Alive cells information
  Set<Point> state = {};

  /// Iteration count, allows for external notification
  ValueNotifier<int> iteration = ValueNotifier<int>(0);

  /// Keeps track of last calculated iteration
  int? lastIteration;

  /// Time between updates
  static const int timeout = 1;

  /// Chance of starting cell being alive or not
  static const spawnChance = 0.3;

  GameOfLife() {
    // Begins async calculation of the next state
    _startCalculation();
  }

  /// Changes the limits of the cell space to [newX] and [newHeight], if
  /// provided.
  /// Cells outside of the range will die on the next update.
  void resize({num? newWidth, num? newHeight}) {
    final oldHeight = heightLimit;
    final oldWidth = widthLimit;
    widthLimit = newWidth ?? widthLimit;
    heightLimit = newHeight ?? heightLimit;
    populate(oldHeight, oldWidth);
    markedForRedraw = true;
  }

  /// Adds a new cell to the specified position. If it returns `true`, then
  /// there was already a cell there. If not, the cell is new.
  bool addCell(num posX, num posY) {
    final newPoint = Point(posX, posY);
    final isThere = state.contains(newPoint);
    if (!isThere) {
      state.add(newPoint);
      markedForRedraw = true;
      iteration.value++;
    }
    return isThere;
  }

  /// Assigns a random starting position to the cells in the game, iterating
  /// through the [oldHeight] <= y < [heightLimit] and [oldWidth]<= y
  /// < [widthLimit] space and setting cells to live with a p of [spawnChance].
  ///
  /// If working with non-integer space, you can pass [unit] as the iteration
  /// step for the population. By default, it's 1.
  void populate(num? oldHeight, num? oldWidth, {unit = 1}) {
    final rng = Random();

    // Travels through cell space and assigns starting positions
    for (num i = oldHeight ?? 0; i < heightLimit; i += unit) {
      for (num j = oldWidth ?? 0; j < widthLimit; j += unit) {
        if (rng.nextInt(100) < 100 * spawnChance) {
          state.add(Point(i, j));
        }
      }
    }
  }

  /// Calculates the next state of the game asynchronously, by checking every
  /// cell alive and calculating both it's next state and which neighbors
  /// might spring to life. It receives an [oldState], which is expected to be
  /// a copy of the state as the calculation is fired. This is to avoid
  /// potential race conditions if the state changes mid calculation.
  ///
  /// It leverages Dart's Streams to separate the task into one atomic task
  /// per alive cell. As Isolate is not available in Web, this is the best
  /// solution for smooth calculation without interrupting the main loop.
  Future<Set<Point>> _calculateNextStep(Set<Point> oldState) {
    Set<Point> newState = {};

    // Filter out relevant keys, inside the game's limit
    final relevantKeys =
        oldState.where((k) => k.insideLimit(heightLimit, widthLimit));

    return Stream.fromIterable(relevantKeys).fold(newState,
        (Set<Point> newState, Point key) {
      // Stream each point calculation in order to give breathing room to the main thread
      var counter = 0;
      for (var adj in key.adjacent) {
        // Skip "springs to life" step if already alive
        if (oldState.contains(adj)) {
          counter++;
          continue;
        }
        // Skip "springs to life" step if other cells set it as alive already
        if (!newState.contains(adj)) {
          final neighbors =
              adj.adjacent.where((e) => oldState.contains(e)).length;
          if (neighbors == 3) {
            // Cell revives when there are 3 neighbors.
            newState.add(adj);
          }
        }
      }
      if (counter == 2 || counter == 3) {
        // Cell survives when there are 2 or 3 neighbors.
        newState.add(key);
      }
      return newState;
    });
  }

  /// Begins execution of the game, calculating the next step every [timeout]
  /// seconds and updating the current state of the game when done.
  void _startCalculation() {
    // Fires a new task every $timeout seconds
    Timer.periodic(const Duration(seconds: timeout), (_) {
      if (lastIteration == iteration.value) {
        // If last task didn't finish, skip this execution
        return;
      }

      lastIteration = iteration.value;
      // Calculate next step with a copy of the current state
      _calculateNextStep({...state}).then((value) {
        if (markedForRedraw) {
          // Early exit if something modified the state while calculating
          // Probably won't happen often, since exec time is <1s
          return;
        }
        state = value;
        iteration.value++;
        markedForRedraw = true;
      });
    });
  }
}
