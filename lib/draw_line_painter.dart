// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  List<DrawingPoint>? drawingPointList;
  Size? drawSize;
  DrawingPainter({
    this.drawingPointList,
    this.drawSize,
  });

  void addPoint(DrawingPoint point) {
    drawingPointList ??= [];
    drawingPointList!.add(point);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print("drawingPointList.length ${drawingPointList.length}");
    print("panit draw ");
    if (drawingPointList == null) return;

    Paint fontPaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height),
            const Radius.circular(3)),
        fontPaint);

    for (var i = 0; i < drawingPointList!.length; i++) {
      // print(drawingPointList![i]);

      if (drawingPointList![i].offset != null && drawingPointList![i] != drawingPointList!.last) {
        if (drawingPointList![i + 1].offset != null) {
          canvas.drawLine(drawingPointList![i].offset!, drawingPointList![i + 1].offset!, drawingPointList![i].paint!);
        } else if (drawingPointList![i + 1].offset == null) {
          canvas.drawPoints(PointMode.points, [drawingPointList![i].offset!], drawingPointList![i].paint!);
        }
      }
      if (drawingPointList![i].offset != null && drawingPointList![i] == drawingPointList!.last) {
        canvas.drawPoints(PointMode.points, [drawingPointList![i].offset!], drawingPointList![i].paint!);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    print("oldDelegate drawingPointList ${oldDelegate.drawingPointList?.length}");
    print("drawingPointList ${drawingPointList?.length}");
    return true;
    //return oldDelegate.drawingPointList?.length != drawingPointList?.length;
  }
}

class DrawingPoint {
  Offset? offset;
  Paint? paint;
  DrawingPoint({
    this.offset,
    this.paint,
  });

  @override
  String toString() => '$offset';
}
