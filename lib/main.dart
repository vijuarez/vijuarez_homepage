import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final double heightLimit; // Limit on simulation's X value
  final double widthLimit; // Limit on simulation's Y value

  Map<Point, bool> state = {}; // Alive cells information
  double iteration = 0; // Iteration count
  static const int timeout = 3; // Time between updates

  GameOfLife(this.heightLimit, this.widthLimit);

  void calculateNextStep() {
    // Updates the state of the game
    Map<Point, bool> newState = {};
    for(var key in state.keys.where((k) => k.insideLimit(heightLimit, widthLimit))) {
      var counter = 0;
      for(var adj in key.adjacent) {
        if (state[adj] ?? false) {
          counter++;
          continue;
        }
        final neighbors = adj.adjacent.where((e) => state[e] ?? false).length;
        if (neighbors == 2 || neighbors == 3) {
          newState[adj] = true;
        }
      }
      if (counter == 2 || counter == 3) {
        newState[key] = true;
      }
    }
    state = newState;
    ++iteration;
  }

  void startCalculation() {
    // Begins the execution of the game
    Timer.periodic(const Duration(seconds: timeout), (_) {
      calculateNextStep();
    });
  }
}

void main() {
  runApp(const Homepage());
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vicente Juárez',
      home: NamePage()
    );
  }
}

class NamePage extends StatefulWidget {
  const NamePage({Key? key}) : super(key: key);

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
      CustomPaint(
        painter: GameOfLifeDisplay(),
        size: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      ),
      Scaffold(
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'VICENTE JUÁREZ',
              style: GoogleFonts.novaMono(
                  color: Colors.black,
                  fontSize: 48
              ),
            ),
            Text(
              'Software Development',
              style: GoogleFonts.novaMono(
                  color: Colors.black,
                  fontSize: 16
              ),
            )
          ],
        ),
        ),
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF6200EE),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          onTap: (value) {
          // Respond to item press.
          },
          items: const [
            BottomNavigationBarItem(
              label: 'Curriculum Vitae',
              icon: Icon(Icons.document_scanner),
            ),
            BottomNavigationBarItem(
              label: 'Email',
              icon: Icon(Icons.email),
            ),
            BottomNavigationBarItem(
              label: 'Github',
              icon: Icon(Icons.account_tree),
            ),
          ],
        ),
        ),
      ],
    );
  }
}

class GameOfLifeDisplay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const RadialGradient gradient = RadialGradient(
      center: Alignment(0.7, -0.6),
      radius: 0.2,
      colors: <Color>[Color(0xFFFFFF00), Color(0xFF0099FF)],
      stops: <double>[0.4, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      Rect rect = Offset.zero & size;
      final double width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(GameOfLifeDisplay oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(GameOfLifeDisplay oldDelegate) => false;
}
