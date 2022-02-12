class StationModel {
  late int id;
  late int datasetId;
  late String name;

  late Map<String, List<DateTime>> annualDates;
  late Map<String, List<DateTime>> dailyDates;

  StationModel({
    required this.id,
    required this.datasetId,
    required this.name,
  });
  StationModel.fromJson(data, Map annualDatesJson, Map dailyDatesJson) {
    id = data['pk'];
    datasetId = data['fields']['dataset'];
    name = data['fields']['name'];

    List<String> keys = List<String>.from(annualDatesJson.keys.toList());
    annualDates = {};
    for (var i = 0; i < keys.length; i++) {
      annualDates[keys[i]] =
          List.generate(annualDatesJson[keys[i]].length, (index) {
        return DateTime.parse(annualDatesJson[keys[i]][index]);
      });
    }

    List<String> dkeys = List<String>.from(dailyDatesJson.keys.toList());
    dailyDates = {};
    for (var i = 0; i < dkeys.length; i++) {
      dailyDates[keys[i]] =
          List.generate(dailyDatesJson[keys[i]].length, (index) {
        return DateTime.parse(dailyDatesJson[keys[i]][index]);
      });
    }
  }

  List<DateTime> get yearsRange {
    List<String> keys = List<String>.from(annualDates.keys.toList());
    List<DateTime> datetimes = [];
    // print(annualDates);
    for (var i = 0; i < keys.length; i++) {
      datetimes.addAll(annualDates[keys[i]]!);
    }
    datetimes.sort();
    // print(datetimes);
    // print(name);
    if (datetimes.isEmpty) {
      return [];
    }
    return [datetimes.first, datetimes.last];
  }

  List<DateTime> get daysRange {
    List<String> keys = List<String>.from(dailyDates.keys.toList());
    List<DateTime> datetimes = [];
    for (var i = 0; i < keys.length; i++) {
      datetimes.addAll(dailyDates[keys[i]]!);
    }
    datetimes.sort();
    if (datetimes.isEmpty) {
      return [];
    }
    return [datetimes.first, datetimes.last];
  }
}
