import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

double uiRangeConverter(double oldValue, double oldMin, double oldMax,
    double newMin, double newMax) {
  return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) +
      newMin;
}

Future<void> uiDelayed(VoidCallback callback,
    {Duration delay = const Duration(milliseconds: 250)}) async {
  await Future.delayed(delay);
  callback();
}

double uiEuclideanDistance(List<double> vectorA, List<double> vectorB) {
  assert(vectorA.length == vectorB.length);
  double distance = 0.0;
  for (int i = 0; i < vectorA.length; i++) {
    distance += pow(vectorA[i] - vectorB[i], 2);
  }
  return sqrt(distance);
}

void uiShowLoader() {
  Get.dialog(Center(
    child: CircularProgressIndicator(),
  ));
}

void uiHideLoader() {
  Get.back();
}
