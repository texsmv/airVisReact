import 'dart:convert';

import 'package:airq/app/list_shape_extension.dart';
import 'package:http/http.dart';

import 'package:airq/api/api_config.dart';

Future<Map<String, dynamic>> repositoryDatasets() async {
  final response = await post(Uri.parse(hostUrl + "all_datasets"));
  dynamic data = await jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> repositoryDatasetData(int id) async {
  String datasetId = id.toString();
  final response =
      await post(Uri.parse(hostUrl + "windows" + '/' + datasetId + '/'));
  dynamic data = await jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> repositoryDatasetInfo(int id) async {
  String datasetId = id.toString();
  final response =
      await post(Uri.parse(hostUrl + "main" + '/' + datasetId + '/'));
  dynamic data = await jsonDecode(response.body);
  return data;
}

Future<List<List<double>>> repositoryGetProjection(
    List<List<double>> distanceMatrix,
    {bool oneDimension = false}) async {
  final response = await post(Uri.parse(hostUrl + "projection/"),
      body: jsonEncode(distanceMatrix));
  dynamic data = await jsonDecode(response.body);
  List<dynamic> dataList = jsonDecode(data['coordinates']);
  List<List<double>> coordinates = [];
  for (var i = 0; i < dataList.length; i++) {
    coordinates.add(List<double>.from(dataList[i]));
  }
  return coordinates;
}

Future<List<dynamic>> repositoryAnnualStationData(
    String datasetId,
    String stationId,
    String pollutantId,
    String beginDate,
    String endDate) async {
  final response = await post(
    Uri.parse(hostUrl +
        "stationAnnualWindows" +
        '/' +
        datasetId +
        '/' +
        stationId +
        '/' +
        pollutantId +
        '/' +
        beginDate +
        '/' +
        endDate +
        '/'),
  );
  dynamic data = await jsonDecode(response.body);
  return await jsonDecode(data['windows']);
}

Future<List<dynamic>> repositoryDailyStationData(
    String datasetId,
    String stationId,
    String pollutantId,
    String beginDate,
    String endDate) async {
  final response = await post(
    Uri.parse(hostUrl +
        "stationDailyWindows" +
        '/' +
        datasetId +
        '/' +
        stationId +
        '/' +
        pollutantId +
        '/' +
        beginDate +
        '/' +
        endDate +
        '/'),
  );
  dynamic data = await jsonDecode(response.body);
  return await jsonDecode(data['windows']);
}

Future<List<dynamic>> repositoryDistanceMatrixVec(
  List<dynamic> matrix,
) async {
  int height = matrix.shape[0];
  int width = matrix.shape[1];
  print('height: $height, width: $width');
  final response = await post(
    Uri.parse(
      hostUrl + "distanceMatrixVectors/",
    ),
    body: jsonEncode({
      'height': height,
      'width': width,
      'matrix': matrix.flatten(),
    }),
  );
  dynamic data = await jsonDecode(response.body);
  List<dynamic> distMatrix = jsonDecode(data['matrix']);
  distMatrix = distMatrix.reshape([height, height]);
  print(distMatrix);
  print(distMatrix.shape);
  return distMatrix;
}
