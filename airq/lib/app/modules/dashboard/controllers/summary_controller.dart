import 'package:airq/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq/app/ui_utils.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:airq/models/pollutant_model.dart';
import 'package:airq/models/station_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

const double selectorSpaceLeft = 70;
const double selectorSpaceRight = 10;
const double selectorSpaceTop = 30;
const double selectorSpaceBottom = 50;

class SummaryController extends GetxController {
  List<StationModel> get stations => controller.stations;
  List<PollutantModel> get pollutants => controller.pollutants;
  List<StationModel> get selectedStations {
    List<StationModel> sstations = [];
    _selectedStations.forEach((key, value) {
      if (value.isSelected) {
        sstations.add(stations.firstWhere((element) => element.id == key));
      }
    });
    return sstations;
  }

  List<bool> get windowSelectedIndexes => granularity == Granularity.annual
      ? _annualSelectedIndexes!
      : _dailySelectedIndexes!;

  List<PollutantModel> get selectedPollutants {
    List<PollutantModel> spollutants = [];
    _selectedPollutants.forEach((key, value) {
      if (value) {
        spollutants.add(pollutants.firstWhere((element) => element.id == key));
      }
    });
    return spollutants;
  }

  int get numberYears =>
      controller.yearRange.last.year - controller.yearRange.first.year + 1;

  List<List<bool>> get intersectionMatrix => granularity == Granularity.annual
      ? _annualIntersectionMatrix!
      : _dailyIntersectionMatrix!;

  Granularity get granularity => controller.granularity;

  int get maxWindows => granularity == Granularity.daily
      ? _dailyApperanceMatrix.values.toList().first[0].length
      : _annualApperanceMatrix.values.toList().first[0].length;

  List<DateTime> get yearRange => controller.yearRange;
  List<DateTime> get dayRange => controller.dayRange;

  @override
  void onInit() {
    super.onInit();
    _initPollutantsOptions();
    _initStationsOptions();
    _annualDates = computeDates(Granularity.annual);
    print('annual dates: ${_annualDates!.length}');
    _dailyDates = computeDates(Granularity.daily);
    print('daily dates: ${_dailyDates!.length}');
    loadMatrix();
    computeIntersection();
  }

  void updateGranularity(Granularity granularity) {
    controller.updateGranularity(granularity);
    computeIntersection();
    update();
  }

  bool isPollutantSelected(int id) {
    return _selectedPollutants[id]!;
  }

  void toggleStation(int id) {
    _selectedStations[id]!.isSelected = !_selectedStations[id]!.isSelected;
    computeIntersection();
    update();
  }

  void togglePollutant(int id) {
    _selectedPollutants[id] = !_selectedPollutants[id]!;
    _dailyApperanceMatrix = {};
    _annualApperanceMatrix = {};
    loadMatrix();
    computeIntersection(notify: false);
    update();
  }

  bool isStationSelected(StationModel station) {
    return _selectedStations[station.id]!.isSelected;
  }

  void changeStationsOrder(OrderByType type, bool ascendent) {
    orderType = type;
    List<StationModel> stationsUpdates = List.from(stations);
    List<double> sortValues = List.generate(stations.length, (index) => 0);

    switch (type) {
      case OrderByType.byName:
        stationsUpdates.sort((item1, item2) {
          if (ascendent) {
            return item1.name.compareTo(item2.name);
          } else {
            return item2.name.compareTo(item1.name);
          }
        });
        controller.updateStations(stationsUpdates);
        break;
      case OrderByType.bySelected:
        List<StationOrderModel> stationOrders = [];
        for (var i = 0; i < stations.length; i++) {
          if (ascendent) {
            sortValues[i] = isStationSelected(stations[i]) ? 1.0 : 0.0;
          } else {
            sortValues[i] = isStationSelected(stations[i]) ? 0.0 : 1.0;
          }
        }
        for (int i = 0; i < stations.length; i++) {
          stationOrders.add(StationOrderModel(
              station: stations[i], orderValue: sortValues[i]));
        }

        stationOrders.sort((item1, item2) {
          return item2.orderValue.compareTo(item1.orderValue);
        });

        for (var i = 0; i < stationOrders.length; i++) {
          stationsUpdates[i] = stationOrders[i].station;
        }
        controller.updateStations(stationsUpdates);
        break;
      case OrderByType.byCompleteness:
        List<StationOrderModel> stationOrders = [];
        for (var i = 0; i < stations.length; i++) {
          List<List<bool>> matrix = getMissingMatrix(stations[i],
              daysMode: granularity == Granularity.daily);
          int missingCount = 0;
          int maxCount =
              matrix.length * (selectionEndIndex - selectionStartIndex);

          for (var i = 0; i < matrix.length; i++) {
            for (var j = selectionStartIndex; j < selectionEndIndex; j++) {
              if (!matrix[i][j]) {
                missingCount++;
              }
            }
          }

          if (ascendent) {
            sortValues[i] = missingCount.toDouble();
          } else {
            sortValues[i] = maxCount - missingCount.toDouble();
          }
        }

        for (int i = 0; i < stations.length; i++) {
          stationOrders.add(StationOrderModel(
              station: stations[i], orderValue: sortValues[i]));
        }

        stationOrders.sort((item1, item2) {
          return item2.orderValue.compareTo(item1.orderValue);
        });

        for (var i = 0; i < stationOrders.length; i++) {
          stationsUpdates[i] = stationOrders[i].station;
        }
        controller.updateStations(stationsUpdates);
        break;
      default:
    }

    update();
  }

  Future<void> getWindows() async {
    uiShowLoader();
    if (granularity == Granularity.daily) {
      await controller.selectDailyWindows(
        selectedStations,
        selectedPollutants,
        beginDate,
        endDate,
        _dailyDates!,
        _dailySelectedIndexes!,
      );
    } else {
      await controller.selectAnnualWindows(
        selectedStations,
        selectedPollutants,
        beginDate,
        endDate,
        _annualDates!,
        _annualSelectedIndexes!,
      );
    }
    uiHideLoader();

    dashboardController.pageIndex = 0;
    print(dashboardController.pageIndex);
    print('Ahora si done?');
  }

  void computeIntersection({bool notify = false}) {
    if (granularity == Granularity.daily) {
      _dailyIntersectionMatrix = List.generate(
        selectedPollutants.length,
        (index) => List.generate(
            _dailyApperanceMatrix.values.first.first.length, (index2) => true),
      );
      _dailySelectedIndexes =
          List.generate(intersectionMatrix.first.length, (index) => false);
      print('first length: ${intersectionMatrix.first.length}');
    } else {
      _annualIntersectionMatrix = List.generate(
        selectedPollutants.length,
        (index) => List.generate(
            _annualApperanceMatrix.values.first.first.length, (index2) => true),
      );
      _annualSelectedIndexes =
          List.generate(intersectionMatrix.first.length, (index) => false);
    }

    List<StationData> selectedStations = [];
    _selectedStations.forEach((key, value) {
      if (value.isSelected) {
        selectedStations.add(value);
      }
    });

    // print('n stations: ${selectedStations.length}');
    for (var k = 0; k < selectedStations.length; k++) {
      // List<List<bool>> matrix = granularity == Granularity.daily
      //     ? _dailyApperanceMatrix[selectedStations[k].station.id]!
      //     : _annualApperanceMatrix[selectedStations[k].station.id]!;
      List<List<bool>> matrix = getMissingMatrix(selectedStations[k].station,
          daysMode: granularity == Granularity.daily);

      for (var i = 0; i < matrix.length; i++) {
        for (var j = 0; j < matrix.first.length; j++) {
          if (granularity == Granularity.daily) {
            if (matrix[i][j]) {
              // print('true');
            }
            _dailyIntersectionMatrix![i][j] =
                _dailyIntersectionMatrix![i][j] && matrix[i][j];
          } else {
            if (matrix[i][j]) {
              // print('true');
            }
            _annualIntersectionMatrix![i][j] =
                _annualIntersectionMatrix![i][j] && matrix[i][j];
          }
        }
      }
    }

    for (var j = selectionStartIndex; j < selectionEndIndex; j++) {
      bool colVal = true;
      for (var i = 0; i < intersectionMatrix.length; i++) {
        colVal = intersectionMatrix[i][j] && colVal;
      }
      if (granularity == Granularity.daily) {
        _dailySelectedIndexes![j] = colVal;
      } else {
        _annualSelectedIndexes![j] = colVal;
      }
    }
    // print(intersectionMatrix.length);
    // print(intersectionMatrix.first.length);
    // print(windowSelectedIndexes);
    // print(_dailyIntersectionMatrix);
    if (notify) {
      update();
    }
  }

  void _initPollutantsOptions() {
    _selectedPollutants = {};
    for (var element in pollutants) {
      _selectedPollutants[element.id] = true;
    }
  }

  void _initStationsOptions() {
    _selectedStations = {};
    for (var i = 0; i < controller.stations.length; i++) {
      _selectedStations[controller.stations[i].id] = StationData(
        controller.stations[i],
        false,
      );
    }
  }

  void loadMatrix() async {
    for (var i = 0; i < stations.length; i++) {
      getMissingMatrix(stations[i], daysMode: true);
      getMissingMatrix(stations[i], daysMode: false);
    }
  }

  List<List<bool>> getMissingMatrix(StationModel station,
      {bool daysMode = true}) {
    List<List<bool>>? matrix;
    if (daysMode) {
      matrix = _dailyApperanceMatrix[station.id];
    } else {
      matrix = _annualApperanceMatrix[station.id];
    }
    if (matrix == null) {
      matrix = _appearanceMatrix(station, daysMode: daysMode);
      if (daysMode) {
        _dailyApperanceMatrix[station.id] = matrix;
      } else {
        _annualApperanceMatrix[station.id] = matrix;
      }
    }
    List<List<bool>> filteredMatrix = [];
    for (int i = 0; i < pollutants.length; i++) {
      PollutantModel pollutant = selectedPollutants.firstWhere(
        (PollutantModel element) => element.id == pollutants[i].id,
        orElse: () => PollutantModel(
          id: -1,
          datasetId: -1,
          name: '',
          color: Colors.black,
        ),
      );

      if (pollutant.id != -1) {
        filteredMatrix.add(matrix[i]);
      }
    }

    return filteredMatrix;
  }

  List<List<bool>> _appearanceMatrix(StationModel station,
      {bool daysMode = true}) {
    DateTime minDate, maxDate;
    int range;
    if (daysMode) {
      minDate = controller.dayRange.first;
      maxDate = controller.dayRange.last;
      range = _dailyDates!.length;
    } else {
      minDate = controller.yearRange.first;
      maxDate = controller.yearRange.last;
      range = _annualDates!.length;
      // range = maxDate.difference(minDate).inDays ~/ 365;
    }

    List<String> pollutantsL =
        List.generate(pollutants.length, (index) => pollutants[index].name);

    List<List<bool>> matrix = [];

    for (var i = 0; i < pollutants.length; i++) {
      List<DateTime> dates;
      List<int> differences;
      if (daysMode) {
        dates = station.dailyDates[pollutantsL[i]]!;

        differences = List.generate(dates.length, (index) {
          return dates[index].difference(minDate).inDays;
        });
      } else {
        dates = station.annualDates[pollutantsL[i]]!;
        differences = List.generate(dates.length, (index) {
          return dates[index].difference(minDate).inDays ~/ 365;
        });
      }

      differences.sort();
      // differencesMap[pollutants[i]] = differences;
      List<bool> appearArray = [];
      for (var i = 0; i < range; i++) {
        int val =
            differences.firstWhere((element) => element == i, orElse: () => -1);
        if (val != -1) {
          appearArray.add(true);
        } else {
          appearArray.add(false);
        }
      }
      matrix.add(appearArray);
    }

    return matrix;
  }

  List<DateTime> computeDates(Granularity granularity) {
    final int differenceInYears = controller.yearRange.last
            .difference(controller.yearRange.first)
            .inDays ~/
        365;
    List<DateTime> dates = [];
    if (granularity == Granularity.annual) {
      return List.generate(
        differenceInYears + 1,
        (index) => DateTime(controller.yearRange.first.year + index, 1, 1),
      );
    } else {
      dates = [];

      for (var i = 0; i < differenceInYears; i++) {
        dates.addAll(
          List.generate(
            365,
            (index) => DateTime(controller.yearRange.first.year + i, 1, 1).add(
              Duration(days: index),
            ),
          ),
        );
      }
      return dates;
    }
  }

  late Map<int, bool> _selectedPollutants;
  Map<int, List<List<bool>>> _dailyApperanceMatrix = {};
  Map<int, List<List<bool>>> _annualApperanceMatrix = {};
  late Map<int, StationData> _selectedStations;
  List<List<bool>>? _dailyIntersectionMatrix;
  List<List<bool>>? _annualIntersectionMatrix;
  List<bool>? _dailySelectedIndexes;
  List<bool>? _annualSelectedIndexes;
  List<DateTime>? _dailyDates;
  List<DateTime>? _annualDates;
  DatasetController controller = Get.find();
  ScrollController scrollController = ScrollController();
  int selectionStartIndex = 0;
  int selectionEndIndex = 2;
  late DateTime beginDate;
  late DateTime endDate;
  OrderByType orderType = OrderByType.byName;

  DashboardController get dashboardController => Get.find();
}

class StationData {
  final StationModel station;
  bool isSelected;
  StationData(this.station, this.isSelected);
}

enum OrderByType {
  byName,
  byCompleteness,
  bySelected,
}

class StationOrderModel {
  StationModel station;
  double orderValue;
  StationOrderModel({required this.station, required this.orderValue});
}
