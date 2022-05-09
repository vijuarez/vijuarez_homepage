import 'dart:async';
import 'dart:math';
import 'dart:ui';

class Point {
  // Represents a point in (X, Y) space
  double x;
  double y;

  Point(this.x, this.y);

  List<Point> get adjacent {
    return [Point(x + 1, y), Point(x - 1, y), Point(x, y + 1), Point(x, y - 1)];
  }

  bool insideLimit(double height, double width) {
    return (x.abs() < height / 2) && (y.abs() < width / 2);
  }

  Offset offset(Size size) {
    return Offset(x * size.width, y * size.height);
  }

  @override
  get hashCode {
    // Point hash using Cantor's enumeration of pairs
    return ((x + y)*(x + y + 1)/2) + y as int;
  }

  @override
  bool operator ==(Object other) {
    return other is Point && x == other.x && y == other.y;
  }
}

class GameOfLife {
  // Represents an instance of Conway's Game of Life

  bool markedForRedraw = true; // Indicate that it requires a rerender

  double heightLimit; // Limit on simulation's X value
  double widthLimit; // Limit on simulation's Y value

  Set<Point> state = {}; // Alive cells information
  double iteration = 0; // Iteration count
  static const int timeout = 1; // Time between updates

  GameOfLife({required this.heightLimit, required this.widthLimit}) {
    final rng = Random();
    for(double i = 0; i < heightLimit; i++) {
      for(double j = 0; j < widthLimit; j++) {
        if (rng.nextBool() && rng.nextBool() && rng.nextBool()) {
          state.add(Point(i, j));
        }
      }
    }
    _startCalculation();
  }

  void resize(double newX, double newY) {
    widthLimit = newX;
    heightLimit = newY;
  }

  void calculateNextStep() {
    // Updates the state of the game
    var oldState = {...state};
    Set<Point> newState = {};
    for(var key in oldState.where((k) => k.insideLimit(heightLimit, widthLimit))) {
      var counter = 0;
      for(var adj in key.adjacent) {
        if (oldState.contains(adj)) {
          counter++;
          continue;
        }
        final neighbors = adj.adjacent.where((e) => oldState.contains(e)).length;
        if (neighbors == 2 || neighbors == 3) {
          newState.add(adj);
        }
      }
      if (counter == 2 || counter == 3) {
        newState.add(key);
      }
    }
    state = newState;
    ++iteration;
    markedForRedraw = true;
  }

  void _startCalculation() {
    // Begins the execution of the game
    Timer.periodic(const Duration(seconds: timeout), (_) {
      calculateNextStep();
    });
  }
}