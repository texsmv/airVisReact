import 'package:airq/app/ui_utils.dart';
import 'package:flutter/rendering.dart';

class IPoint {
  dynamic data;
  Offset coordinates;
  Offset localCoordinates;
  late Offset canvasCoordinates;
  late Offset canvasLocalCoordinates;
  IPoint({
    required this.data,
    required this.coordinates,
    required this.localCoordinates,
  });

  // void computeCanvasCoordinates(double width, double height, bool isLocal) {
  //   final double x = uiRangeConverter(coordinates.dx, -1, 1, 0, width);
  //   final double y = uiRangeConverter(coordinates.dy, -1, 1, 0, height);
  //   if (isLocal) {
  //     canvasLocalCoordinates = Offset(x, y);
  //   } else {
  //     canvasCoordinates = Offset(x, y);
  //   }
  // }

  /// cluster id
  ///
  /// -1 means it's an outlier
  String? cluster;

  bool selected = false;
}
