import 'package:airq/app/ui_utils.dart';
import 'package:airq/app/widgets/iprojection/ipoint.dart';
import 'package:airq/app/widgets/iprojection/iprojection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class IProjectionPainter extends CustomPainter {
  late IProjectionController controller;
  IProjectionPainter({required this.isLocal}) {
    controller = Get.find(tag: isLocal ? 'local' : 'global');
  }
  final bool isLocal;

  late Canvas _canvas;
  late double _width;
  late double _height;
  // Paint selectedPaint = Paint()
  //   ..color = Colors.black
  //   ..style = PaintingStyle.fill;
  Paint nodePaint = Paint()
    ..color = Color.fromRGBO(120, 120, 120, 1)
    ..style = PaintingStyle.fill;
  Paint normalFillPaint = Paint()
    ..color = Color.fromRGBO(190, 190, 190, 1)
    ..style = PaintingStyle.fill;
  Paint normalBorderPaint = Paint()
    ..color = Color.fromRGBO(170, 170, 170, 1)
    ..style = PaintingStyle.stroke;
  Paint selectedBorderPaint = Paint()
    // ..color = Color.fromRGBO(220, 10, 10, 1)
    ..color = Colors.black
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // print("painting");
    _canvas = canvas;
    _height = size.height;
    _width = size.width;
    for (int i = 0; i < controller.points.length; i++) {
      plotPoint(controller.points[i], i);
    }
    // if (controller.showNjStructure && Get.find<HomeUiController>().njMode) {
    //   for (int i = 0; i < controller.nodes.length; i++) {
    //     plotNode(controller.nodes[i]);
    //   }
    // }
  }

  void plotPoint(IPoint point, int position) {
    // final Paint pointPaint = point.selected ? selectedPaint : normalPaint;
    late Paint fillPaint;
    Paint borderPaint;
    if (point.cluster != null) {
      // fillPaint = Paint()
      //   ..color = Get.find<SeriesController>()
      //       .clusters[point.cluster]
      //       .color
      //       .withOpacity(0.4)
      //   ..style = PaintingStyle.fill;
    } else {
      fillPaint = normalFillPaint;
    }
    borderPaint = normalBorderPaint;
    if (point.selected) {
      borderPaint = selectedBorderPaint;
    }

    // if (point.canvasCoordinates == null) {
    //   point.computeCanvasCoordinates(_width, _height);
    // }
    Offset canvasCoordinates = computeCanvasCoordinates(
        controller.currentCoordinates[position].dx,
        controller.currentCoordinates[position].dy,
        _width,
        _height);
    if (isLocal) {
      point.canvasLocalCoordinates = canvasCoordinates;
      // print(point.canvasLocalCoordinates);
    } else {
      point.canvasCoordinates = canvasCoordinates;
    }
    _canvas.drawCircle(
      isLocal ? point.canvasLocalCoordinates : point.canvasCoordinates,
      point.selected ? 5 : 3,
      fillPaint,
    );
    if (point.selected) {
      _canvas.drawCircle(
        // Offset(canvasCoordinates.dx, _height - canvasCoordinates.dy),
        isLocal ? point.canvasLocalCoordinates : point.canvasCoordinates,
        point.selected ? 5 : 3,
        borderPaint,
      );
    }
  }

  Offset computeCanvasCoordinates(
      double dx, double dy, double width, double height) {
    final double x =
        uiRangeConverter(dx, controller.minX, controller.maxX, 0, width);
    final double y =
        uiRangeConverter(dy, controller.minY, controller.maxY, 0, height);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
    return controller.shouldRepaint;
  }
}
