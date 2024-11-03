import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sigo_converter/pdf_file_create.dart';
import 'package:sigo_converter/screens/pdf_list_screen.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<List<Offset>> points = [];
  GlobalKey _globalKey = GlobalKey(); // Key for RepaintBoundary

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing Board'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                points.clear(); // Clear the drawing when button is pressed
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          if (_isWithinBounds(details.localPosition, MediaQuery.of(context).size.width - 20)) {
            setState(() {
              points.add([details.localPosition]);
            });
          }
        },
        onPanUpdate: (details) {
          if (_isWithinBounds(details.localPosition, MediaQuery.of(context).size.width - 20)) {
            setState(() {
              if (points.isNotEmpty) {
                points.last.add(details.localPosition);
              }
            });
          }
        },
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      height: 300,
                      width: constraints.maxWidth,
                      color: Colors.white,
                      child: CustomPaint(
                        painter: DrawingPainter(points),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => PDFListScreen()));
                    },
                    child: Text('All List'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: points.isNotEmpty
          ? FloatingActionButton(
        onPressed: isSaving
            ? null
            : () async {
          // Get the RenderRepaintBoundary to capture the drawing
          RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

          // Create an image from the boundary
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(format: ImageByteFormat.png);
          final pngBytes = byteData!.buffer.asUint8List();

          // Create PDF and save it
          PDFCreator().createPDF(pngBytes);
          setState(() {
            points.clear();
            isSaving = false;
          });
        },
        child: isSaving
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        )
            : Icon(Icons.save),
      )
          : null,
    );
  }

  // Check if the touch is within the drawing area bounds
  bool _isWithinBounds(Offset position, double width) {
    return position.dx >= 0 && position.dx <= width && position.dy >= 0 && position.dy <= 300;
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (var segment in points) {
      if (segment.length < 2) continue;
      for (int i = 0; i < segment.length - 1; i++) {
        canvas.drawLine(segment[i], segment[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
