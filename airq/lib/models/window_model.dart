import 'dart:convert';

class WindowModel {
  late int id;
  late DateTime beginDate;
  late Map<int, double> local_x;
  late Map<int, double> local_y;
  late double global_x;
  late double global_y;
  List<double> globalCoor = [];
  Map<int, List<double>> localCoor = {};
  Map<int, List<double>> features = {};
  Map<int, List<double>> values = {};
  Map<int, List<double>> smoothedValues = {};
  Map<int, double> magnitude = {};
  WindowModel({
    required this.id,
  });

  void addPollutant(
    int polutantId,
    List<double> polValues,
    List<double> polSmoothValues,
    List<double> features,
  ) {
    values[polutantId] = polValues;
    smoothedValues[polutantId] = polSmoothValues;
  }

  // WindowModel.fromJson(data) {
  //   id = data['pk'];
  //   // local_x = data['fields']['p_x'];
  //   // local_y = data['fields']['p_y'];
  //   // global_x = data['fields']['g_x'];
  //   // global_y = data['fields']['g_y'];
  //   List<String> valuesStr =
  //       List<String>.from(jsonDecode(data['fields']['values']));
  //   values = List.generate(
  //       valuesStr.length, (index) => double.parse(valuesStr[index]));
  //   // smoothedValues = data['fields']['smoothed_values'];
  //   magnitude = data['fields']['magnitud'];
  // }
}
