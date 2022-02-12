import 'dart:math';

import 'package:airq/app/ui_utils.dart';
import 'package:airq/app/widgets/iprojection/ipoint.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:airq/models/pollutant_model.dart';
import 'package:airq/models/window_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiChartPainter extends CustomPainter {
  final double minValue;
  final double maxValue;
  final List<IPoint> models;
  MultiChartPainter({
    required this.models,
    required this.minValue,
    required this.maxValue,
  });

  late double _width;
  late double _height;
  late Canvas _canvas;
  late double _horizontalSpace;
  int get timeLen => models.first.data.values.values.toList().first.length;
  DatasetController datasetController = Get.find();
  PollutantModel get pollutant => datasetController.projectedPollutant;

  @override
  void paint(Canvas canvas, Size size) {
    print("PAINTING GRAPH");
    _canvas = canvas;
    _width = size.width;
    _height = size.height;
    _horizontalSpace = _width / (timeLen - 1);

    for (var i = 0; i < models.length; i++) {
      paintModelLine(models[i]);
    }
  }

  void paintModelLine(IPoint model) {
    Path path = Path();

    double value = min(model.data.values[pollutant.id]![0], maxValue);
    path.moveTo(0, value2Heigh(value));
    for (var i = 1; i < model.data.values[pollutant.id]!.length; i++) {
      // print(model.values[pollutant.id]![i]);
      double value = min(model.data.values[pollutant.id]![i], maxValue);
      value = max(value, minValue);
      path.lineTo(
        i * _horizontalSpace,
        value2Heigh(value),
      );
    }
    _canvas.drawPath(
      path,
      Paint()
        ..color = model.selected ? Colors.blue : Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  double value2Heigh(double value) {
    return _height - uiRangeConverter(value, minValue, maxValue, 0, _height);
    // return _height - (value / visSettings.datasetSettings.maxValue * _height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
