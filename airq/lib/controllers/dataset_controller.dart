import 'dart:collection';
import 'dart:convert';

import 'package:airq/api/app_repository.dart';
import 'package:airq/app/constants/colors.dart';
import 'package:airq/app/list_shape_extension.dart';
import 'package:airq/app/ui_utils.dart';
import 'package:airq/app/widgets/iprojection/ipoint.dart';
import 'package:airq/models/dataset_model.dart';
import 'package:airq/models/pollutant_model.dart';
import 'package:airq/models/station_model.dart';
import 'package:airq/models/window_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class DatasetController extends GetxController {
  List<DatasetModel> get datasets => _datasets;
  List<IPoint>? get globalPoints => _points;
  List<StationModel> get stations => _stations;
  List<PollutantModel> get pollutants => _pollutants;
  List<DateTime> get yearRange => [_minYear!, _maxYear!];
  List<DateTime> get dayRange => [_minDay!, _maxDay!];
  Granularity get granularity => _granularity;
  PollutantModel get projectedPollutant => _projectedPollutant;
  List<PollutantModel> get selectedPollutants => _selectedPollutants;
  List<WindowModel> get allWindows => _allWindows;
  double get ratio => _ratio;
  Map<int, double> get alphas => _alphas;
  List<int> get years {
    int n = (_endDate.difference(_beginDate).inDays / 365).ceil();
    return List.generate(
        n, (i) => _beginDate.add(Duration(days: 366 * i)).year);
  }

  DatasetModel get dataset => _dataset!;

  Future<void> loadDatasets() async {
    Map<String, dynamic> data = await repositoryDatasets();
    List<dynamic> items = jsonDecode(data['data']);
    _datasets = List.generate(
        items.length, (index) => DatasetModel.fromJson(items[index]));
  }

  Future<void> selectDailyWindows(
    List<StationModel> selectedStations,
    List<PollutantModel> selectedPollutans,
    DateTime beginDate,
    DateTime endDate,
    List<DateTime> dates,
    List<bool> datesIndexes,
  ) async {
    _selectedPollutants = selectedPollutans;
    _selectedStations = selectedStations;

    _projectedPollutant = _selectedPollutants[1];

    for (var i = 0; i < _selectedPollutants.length; i++) {
      _alphas[_selectedPollutants[i].id] = 1.0;
    }

    _datesPosition = HashMap<String, int>();
    _allWindows = [];
    _windows = {};

    for (var i = 0; i < dates.length; i++) {
      _datesPosition['${dates[i].year}/${dates[i].month}/${dates[i].day}'] = i;
    }
    for (var k = 0; k < selectedStations.length; k++) {
      // EasyLoading.show(
      //     status: 'Loading station ${selectedStations[k].name} data');
      for (var j = 0; j < selectedPollutans.length; j++) {
        List<dynamic> stationData = await repositoryDailyStationData(
          dataset.id.toString(),
          selectedStations[k].id.toString(),
          selectedPollutans[j].id.toString(),
          beginDate.toIso8601String(),
          endDate.toIso8601String(),
        );
        int id = selectedStations[k].id;

        if (_windows[id] == null) {
          _windows[id] =
              List.generate(dates.length, (index) => WindowModel(id: id));
        }
        List<WindowModel> stationWindows = _windows[id]!;
        for (var i = 0; i < stationData.length; i++) {
          DateTime date =
              DateTime.parse(stationData[i]['fields']['begin_date']);
          int pos = dateToPosition(date);
          dynamic data = stationData[i]['fields'];

          WindowModel window = stationWindows[pos];

          window.beginDate = date;
          List<String> valuesStr =
              List<String>.from(jsonDecode(data['values']));
          window.values[selectedPollutans[j].id] = List.generate(
              valuesStr.length, (index) => double.parse(valuesStr[index]));

          valuesStr = List<String>.from(jsonDecode(data['smoothedValues']));
          window.smoothedValues[selectedPollutans[j].id] = List.generate(
              valuesStr.length, (index) => double.parse(valuesStr[index]));

          valuesStr = List<String>.from(jsonDecode(data['features']));
          window.features[selectedPollutans[j].id] = List.generate(
              valuesStr.length, (index) => double.parse(valuesStr[index]));

          window.magnitude[selectedPollutans[j].id] = data['magnitud'];
        }
      }
    }
    _windows.forEach((key, windows) {
      for (var i = 0; i < windows.length; i++) {
        if (windows[i].features.length == selectedPollutans.length) {
          _allWindows.add(windows[i]);
        }
      }
    });
    print('AllWindows length: ${_allWindows.length}');

    await _computeMainProjection(showLoading: false);
    // await EasyLoading.dismiss();
    update();
  }

  Future<void> changeRatio(double newRatio) async {
    _ratio = newRatio;
    await updateProjection();
  }

  Future<void> changeAlpha(int pollutantId, double alpha) async {
    _alphas[pollutantId] = alpha;
    await updateProjection();
  }

  Future<void> updateProjection() async {
    int n = allWindows.length;
    distm = List.generate(n, (index) {
      return List.generate(n, (index2) => 0.0);
    });
    for (var k = 0; k < selectedPollutants.length; k++) {
      int pollId = selectedPollutants[k].id;
      for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
          distm[i][j] += _ratio *
                  (_alphas[pollId]! * distmShape[pollId]![i][j]) +
              (1 - _ratio) * (_alphas[pollId]! * distmMagnitud[pollId]![i][j]);
        }
      }
    }
    List<List<double>> mainProjection = await repositoryGetProjection(distm);

    for (var i = 0; i < _allWindows.length; i++) {
      _allWindows[i].globalCoor = mainProjection[i];
    }
    _createPoints();
  }

  Future<void> selectAnnualWindows(
    List<StationModel> selectedStations,
    List<PollutantModel> selectedPollutans,
    DateTime beginDate,
    DateTime endDate,
    List<DateTime> dates,
    List<bool> datesIndexes,
  ) async {
    _selectedPollutants = selectedPollutans;
    _selectedStations = selectedStations;
    _projectedPollutant = _selectedPollutants[0];

    for (var i = 0; i < _selectedPollutants.length; i++) {
      _alphas[_selectedPollutants[i].id] = 1.0;
    }

    _datesPosition = HashMap<String, int>();
    _allWindows = [];
    _windows = {};

    for (var i = 0; i < dates.length; i++) {
      _datesPosition['${dates[i].year}/${dates[i].month}/${dates[i].day}'] = i;
    }

    for (var k = 0; k < selectedStations.length; k++) {
      // EasyLoading.show(
      //     status: 'Loading station ${selectedStations[k].name} data');
      for (var j = 0; j < selectedPollutans.length; j++) {
        List<dynamic> stationData = await repositoryAnnualStationData(
          dataset.id.toString(),
          selectedStations[k].id.toString(),
          selectedPollutans[j].id.toString(),
          beginDate.toIso8601String(),
          endDate.toIso8601String(),
        );
        // int id = stationData[0]['pk'];
        int id = selectedStations[k].id;

        if (_windows[id] == null) {
          _windows[id] =
              List.generate(dates.length, (index) => WindowModel(id: id));
        }
        List<WindowModel> stationWindows = _windows[id]!;
        for (var i = 0; i < stationData.length; i++) {
          DateTime date =
              DateTime.parse(stationData[i]['fields']['begin_date']);
          int pos = dateToPosition(date);
          dynamic data = stationData[i]['fields'];

          WindowModel window = stationWindows[pos];
          List<String> valuesStr =
              List<String>.from(jsonDecode(data['values']));
          window.values[selectedPollutans[j].id] = List.generate(
              valuesStr.length, (index) => double.parse(valuesStr[index]));

          valuesStr = List<String>.from(jsonDecode(data['smoothedValues']));
          window.smoothedValues[selectedPollutans[j].id] = List.generate(
              valuesStr.length, (index) => double.parse(valuesStr[index]));

          valuesStr = List<String>.from(jsonDecode(data['features']));
          window.features[selectedPollutans[j].id] = List.generate(
              valuesStr.length, (index) => double.parse(valuesStr[index]));

          window.magnitude[selectedPollutans[j].id] = data['magnitud'];
        }
      }
    }
    _windows.forEach((key, windows) {
      for (var i = 0; i < windows.length; i++) {
        if (windows[i].features.length == selectedPollutans.length) {
          _allWindows.add(windows[i]);
        }
      }
    });
    print('AllWindows length: ${_allWindows.length}');
    await _computeMainProjection(showLoading: true);
    print('Here?');
    // EasyLoading.dismiss(animation: false);
    update();
  }

  void updateStations(List<StationModel> newStations) {
    _stations = newStations;
  }

  Future<void> loadDatasetInfo(int datasetId) async {
    _dataset = _datasets.firstWhere((element) => element.id == datasetId);
    Map<String, dynamic> data = await repositoryDatasetInfo(datasetId);
    // _years = List<int>.from(jsonDecode(data['years']));

    Map<String, dynamic> annualDates = jsonDecode(data['annualDates']);
    Map<String, dynamic> dailyDates = jsonDecode(data['dailyDates']);

    List<dynamic> pollutantsItems = jsonDecode(data['pollutants']);
    List<dynamic> stationsItems = jsonDecode(data['stations']);

    _pollutants = List.generate(
      pollutantsItems.length,
      (index) => PollutantModel.fromJson(
        pollutantsItems[index],
        pColorDark.withOpacity(0.7 + index * (0.3 / pollutantsItems.length)),
      ),
    );

    _stations = List.generate(
      stationsItems.length,
      (index) => StationModel.fromJson(
        stationsItems[index],
        annualDates[stationsItems[index]['fields']['name']],
        dailyDates[stationsItems[index]['fields']['name']],
      ),
    );
    List<StationModel> temp = [];
    for (var i = 0; i < _stations.length; i++) {
      if (_stations[i].daysRange.isNotEmpty &&
          _stations[i].yearsRange.isNotEmpty) {
        temp.add(_stations[i]);
      }
    }
    _stations = temp;
    _initDatasetSettings();
  }

  void updateGranularity(Granularity granularity) {
    _granularity = granularity;
    switch (granularity) {
      case Granularity.annual:
        _beginDate = _minYear!;
        _endDate = _maxYear!;
        break;
      case Granularity.daily:
        _beginDate = _minDay!;
        _endDate = _maxDay!;
        break;
      default:
    }
    update();
  }

  void _initDatasetSettings() {
    _setDatesRange();
    _granularity = Granularity.annual;
  }

  int dateToPosition(DateTime date) {
    if (_datesPosition['${date.year}/${date.month}/${date.day}'] == null) {
      print('${date.year}/${date.month}/${date.day}');
    }
    return _datesPosition['${date.year}/${date.month}/${date.day}']!;
  }

  void _createPoints() {
    print('----------------------------------');
    print('Creating points for ${_projectedPollutant.name}');
    print(
      _allWindows[0].localCoor[_projectedPollutant.id]![0],
    );
    _points = List.generate(_allWindows.length, (index) {
      return IPoint(
        data: _allWindows[index],
        coordinates: Offset(
          _allWindows[index].globalCoor[0],
          _allWindows[index].globalCoor[1],
        ),
        localCoordinates: Offset(
          _allWindows[index].localCoor[_projectedPollutant.id]![0],
          _allWindows[index].localCoor[_projectedPollutant.id]![1],
        ),
      );
    });
  }

  Future<void> _computeMainProjection({bool showLoading = false}) async {
    DistanceMatrixParams params = DistanceMatrixParams(
      alphas: _alphas,
      allWindows: _allWindows,
      selectedPollutants: _selectedPollutants,
      ratio: _ratio,
    );
    print('Computing');

    // await repositoryDistanceMatrixVec([
    //   [1, 2, 3],
    //   [2, 3, 4],
    //   [3, 4, 5]
    // ]);

    DistanceMatrixResults res = await compute(computeDistanceMatrix, params);
    distm = res.distm;
    distmMagnitud = res.distmMagnitud;
    distmShape = res.distmShape;
    print('Compute done');

    // distmShape = {};
    // distmMagnitud = {};
    // for (var i = 0; i < _selectedPollutants.length; i++) {
    //   distmShape[_selectedPollutants[i].id] =
    //       List.generate(_allWindows.length, (index) {
    //     return List.generate(_allWindows.length, (index2) => 0.0);
    //   });

    //   distmMagnitud[_selectedPollutants[i].id] =
    //       List.generate(_allWindows.length, (index) {
    //     return List.generate(_allWindows.length, (index2) => 0.0);
    //   });
    // }
    // distm = List.generate(_allWindows.length, (index) {
    //   return List.generate(_allWindows.length, (index2) => 0.0);
    // });

    // for (var k = 0; k < _selectedPollutants.length; k++) {
    //   if (showLoading) {
    //     EasyLoading.show(
    //         status: 'Computing distances for ${_selectedPollutants[k].name}');
    //   }
    //   int pollId = _selectedPollutants[k].id;
    //   int n = _allWindows.length;
    //   for (var i = 0; i < n; i++) {
    //     for (var j = 0; j < n; j++) {
    //       distmShape[pollId]![i][j] = uiEuclideanDistance(
    //         _allWindows[i].features[pollId]!,
    //         _allWindows[j].features[pollId]!,
    //       );
    //       distmMagnitud[pollId]![i][j] = uiEuclideanDistance(
    //         [_allWindows[i].magnitude[pollId]!],
    //         [_allWindows[j].magnitude[pollId]!],
    //       );
    //       distm[i][j] = _ratio *
    //               (_alphas[pollId]! * distmShape[pollId]![i][j]) +
    //           (1 - _ratio) * (_alphas[pollId]! * distmMagnitud[pollId]![i][j]);
    //     }
    //   }
    // }

    List<List<double>> mainProjection = await repositoryGetProjection(distm);
    pollutantProjections = {};
    for (var i = 0; i < _selectedPollutants.length; i++) {
      if (showLoading) {
        // EasyLoading.show(
        //     status: 'Getting projections for ${_selectedPollutants[i].name}');
      }
      pollutantProjections[_selectedPollutants[i].id] =
          await repositoryGetProjection(
        distmShape[_selectedPollutants[i].id]!,
        oneDimension: true,
      );
    }

    if (showLoading) {
      // EasyLoading.show(status: 'Saving windows coordinates');
    }

    // Setting the coordinates
    for (var i = 0; i < _allWindows.length; i++) {
      _allWindows[i].globalCoor = mainProjection[i];
      for (var j = 0; j < _selectedPollutants.length; j++) {
        int pollId = _selectedPollutants[j].id;
        _allWindows[i].localCoor[pollId] = [
          pollutantProjections[pollId]![i][0],
          _allWindows[i].magnitude[pollId]!
        ];
      }
    }

    if (showLoading) {
      // EasyLoading.show(status: 'Creating points');
    }
    _createPoints();
    if (showLoading) {
      // EasyLoading.show(status: 'Done');
    }

    print('DONE');
  }

  void selectPollutant(PollutantModel pollutantModel) {
    _projectedPollutant = pollutantModel;
    // for (var i = 0; i < _allWindows.length; i++) {
    //   int pollId = _projectedPollutant.id;
    //   print(pollId);
    //   _allWindows[i].localCoor[pollId] = [
    //     pollutantProjections[pollId]![i][0],
    //     _allWindows[i].magnitude[pollId]!
    //   ];
    // }
    _createPoints();
    print('DoNE?');
  }

  void _setDatesRange() {
    final List<DateTime> minYearDates = [];
    final List<DateTime> maxYearDates = [];
    final List<DateTime> minDates = [];
    final List<DateTime> maxDates = [];
    for (var i = 0; i < _stations.length; i++) {
      var yearsTuple = _stations[i].yearsRange;
      minYearDates.add(yearsTuple.first);
      maxYearDates.add(yearsTuple.last);

      var daysTuple = _stations[i].yearsRange;
      minDates.add(daysTuple.first);
      maxDates.add(daysTuple.last);
    }
    minYearDates.sort();
    maxYearDates.sort();
    minDates.sort();
    maxDates.sort();

    _minYear = minYearDates.first;
    _maxYear = maxYearDates.last;
    _minDay = minDates.first;
    _maxDay = maxDates.last;
    print('Years range: $_minYear - $_maxYear');
    print('Days range: $_minDay - $_maxDay');
  }

  DateTime? _minYear;
  DateTime? _maxYear;
  DateTime? _minDay;
  DateTime? _maxDay;
  DatasetModel? _dataset;
  late List<DatasetModel> _datasets;
// late List<WindowModel> _annualWindows;
  late List<PollutantModel> _pollutants;
  late List<StationModel> _stations;
  List<IPoint>? _points;
  late DateTime _beginDate;
  late DateTime _endDate;
  late Granularity _granularity;
  List<PollutantModel> _selectedPollutants = [];
  List<StationModel> _selectedStations = [];
  late PollutantModel _projectedPollutant;
  HashMap<String, int> _datesPosition = HashMap<String, int>();
  Map<int, List<WindowModel>> _windows = {};
  List<WindowModel> _allWindows = [];
  Map<int, List<List<double>>> distmShape = {};
  Map<int, List<List<double>>> distmMagnitud = {};
  Map<int, List<List<double>>> pollutantProjections = {};
  List<List<double>> distm = [[]];
  Map<int, double> _alphas = {};
  double _ratio = 0.5;
}

enum Granularity {
  annual,
  daily,
}

Future<DistanceMatrixResults> computeDistanceMatrix(
    DistanceMatrixParams params) async {
  DistanceMatrixResults res = DistanceMatrixResults();
  res.distmShape = {};
  res.distmMagnitud = {};
  for (var i = 0; i < params.selectedPollutants.length; i++) {
    res.distmShape[params.selectedPollutants[i].id] =
        List.generate(params.allWindows.length, (index) {
      return List.generate(params.allWindows.length, (index2) => 0.0);
    });

    res.distmMagnitud[params.selectedPollutants[i].id] =
        List.generate(params.allWindows.length, (index) {
      return List.generate(params.allWindows.length, (index2) => 0.0);
    });
  }
  res.distm = List.generate(params.allWindows.length, (index) {
    return List.generate(params.allWindows.length, (index2) => 0.0);
  });
  for (var k = 0; k < params.selectedPollutants.length; k++) {
    int pollId = params.selectedPollutants[k].id;
    int n = params.allWindows.length;
    List<dynamic> features = List.generate(params.allWindows.length,
        (index) => params.allWindows[index].features[pollId]!);
    List<dynamic> magnitudes = List.generate(params.allWindows.length,
        (index) => [params.allWindows[index].magnitude[pollId]!]);
    List<dynamic> distS = await repositoryDistanceMatrixVec(features);
    List<dynamic> distM = await repositoryDistanceMatrixVec(magnitudes);
    // print(distM);
    // print(distM.shape);
    res.distmShape[pollId] = List.generate(distS.shape[0], (index) {
      return List<double>.from(distS[index]);
    });
    res.distmMagnitud[pollId] = List.generate(distM.shape[0], (index) {
      return List<double>.from(distM[index]);
    });
    // for (var i = 0; i < n; i++) {
    //   for (var j = 0; j < n; j++) {
    //     // res.distmShape[pollId]![i][j] = uiEuclideanDistance(
    //     //   params.allWindows[i].features[pollId]!,
    //     //   params.allWindows[j].features[pollId]!,
    //     // );
    //     // res.distmMagnitud[pollId]![i][j] = uiEuclideanDistance(
    //     //   [params.allWindows[i].magnitude[pollId]!],
    //     //   [params.allWindows[j].magnitude[pollId]!],
    //     // );
    //     // res.distm[i][j] = params.ratio *
    //     //         (params.alphas[pollId]! * res.distmShape[pollId]![i][j]) +
    //     //     (1 - params.ratio) *
    //     //         (params.alphas[pollId]! * res.distmMagnitud[pollId]![i][j]);
    //   }
    // }
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        res.distm[i][j] += params.ratio *
                (params.alphas[pollId]! * res.distmShape[pollId]![i][j]) +
            (1 - params.ratio) *
                (params.alphas[pollId]! * res.distmMagnitud[pollId]![i][j]);
      }
    }
  }
  return res;
}

class DistanceMatrixParams {
  List<WindowModel> allWindows;
  List<PollutantModel> selectedPollutants;
  Map<int, double> alphas;
  double ratio;
  DistanceMatrixParams({
    required this.allWindows,
    required this.alphas,
    required this.selectedPollutants,
    required this.ratio,
  });
}

class DistanceMatrixResults {
  Map<int, List<List<double>>> distmShape = {};
  Map<int, List<List<double>>> distmMagnitud = {};
  List<List<double>> distm = [[]];
}
