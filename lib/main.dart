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
