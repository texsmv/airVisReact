import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
import 'package:airq/app/widgets/iprojection/ipoint.dart';
import 'package:airq/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:airq/models/dataset_model.dart';
import 'package:airq/models/pollutant_model.dart';
import 'package:airq/models/window_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  List<IPoint>? get globalPoints => datasetController.globalPoints;
  List<WindowModel> get windows => datasetController.allWindows;
  List<IPoint> get ipoints => datasetController.globalPoints!;
  PollutantModel get projectedPollutant => datasetController.projectedPollutant;
  List<PollutantModel> get selectedPollutants =>
      datasetController.selectedPollutants;

  int get pageIndex => _pageIndex.value;
  set pageIndex(value) {
    _pageIndex.value = value;
    update();
  }

  DatasetModel get dataset => _datasetController.dataset;

  final DatasetController _datasetController = Get.find();
  final RxInt _pageIndex = RxInt(0);
  IProjectionController projectionController =
      Get.put(IProjectionController(isLocal: false), tag: 'global');
  IProjectionController localProjectionController =
      Get.put(IProjectionController(isLocal: true), tag: 'local');

  @override
  void onReady() {
    pageIndex = 1;
    super.onReady();
  }

  void onPointsSelected(List<IPoint> selectedPoints) {
    fillDays(selectedPoints);
    fillMonths(selectedPoints);
    fillYears(selectedPoints);
    update();
  }

  void fillDays(List<IPoint> points) {
    dayCounts = List.generate(7, (index) => 0);
    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      dayCounts[window.beginDate.weekday - 1]++;
    }
    print('dayCounts: $dayCounts');
  }

  void fillMonths(List<IPoint> points) {
    monthCounts = List.generate(12, (index) => 0);
    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      monthCounts[window.beginDate.month - 1]++;
    }
    print('monthCounts: $monthCounts');
  }

  void fillYears(List<IPoint> points) {
    int firstYear = datasetController.years.first;
    yearCounts = List.generate(datasetController.years.length, (index) => 0);
    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      yearCounts[window.beginDate.year - firstYear]++;
    }
    print('yearCounts: $yearCounts');
  }

  void selectPollutant(String name) {
    PollutantModel pollutant =
        selectedPollutants.firstWhere((element) => element.name == name);
    datasetController.selectPollutant(pollutant);
    update();
  }

  SummaryController get summaryController => Get.find();
  DatasetController datasetController = Get.find();

  List<int> dayCounts = List.generate(7, (index) => 0);
  List<int> monthCounts = List.generate(12, (index) => 0);
  List<int> yearCounts = [];
}
