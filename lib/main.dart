import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_of_life.dart';
import 'colors.dart';

void main() {
  runApp(const Homepage());
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Vicente Juárez', home: NamePage());
  }
}

class NamePage extends StatefulWidget {
  const NamePage({Key? key}) : super(key: key);

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _gameOfLifeState = GameOfLife();
  int pixelSize = 0;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    pixelSize = GameOfLifePainter.pixelSizeCal(dpr);
    _gameOfLifeState.resize(
      newHeight: (MediaQuery.of(context).size.height / pixelSize).ceil(),
      newWidth: (MediaQuery.of(context).size.width / pixelSize).ceil(),
    );
    return Listener(
        onPointerMove: _updatePointerSpawn,
        child: MouseRegion(
            onHover: _updatePointerSpawn,
            child: Stack(
              children: <Widget>[
                ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: ValueListenableBuilder(
                      valueListenable: _gameOfLifeState.iteration,
                      builder: (context, value, child) => CustomPaint(
                        painter: GameOfLifePainter(
                            dpr,
                            _gameOfLifeState),
                        size: Size(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height),
                        isComplex: true,
                      ),
                    )),
                Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'VICENTE JUÁREZ',
                          style: GoogleFonts.novaMono(
                              color: Colors.black, fontSize: 48),
                        ),
                        Text(
                          'Software Development',
                          style: GoogleFonts.novaMono(
                              color: Colors.black, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: materialYellow300,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.black,
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
            )));
  }

  _updatePointerSpawn(PointerEvent event) {
    final pointerX = event.localPosition.dx;
    final pointerY = event.localPosition.dy;
    _gameOfLifeState.addCell(pointerX ~/ pixelSize, pointerY ~/ pixelSize);
  }
}

class GameOfLifePainter extends CustomPainter {
  final GameOfLife gameState;
  final double dpr;
  late final int pixelSize;

  static const densityRatio = 32;

  GameOfLifePainter(this.dpr, this.gameState) {
    pixelSize = pixelSizeCal(dpr);
  }

  static int pixelSizeCal(double dpr) {
    return (dpr * densityRatio).round();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final currentState = {...gameState.state};
    gameState.markedForRedraw = false;

    final size = Size(pixelSize as double, pixelSize as double);
    final paint = Paint()..color = materialYellow50;

    for (var point in currentState) {
      final Rect rect = point.offset(size) & size;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(GameOfLifePainter oldDelegate) {
    return gameState.markedForRedraw;
  }
}
