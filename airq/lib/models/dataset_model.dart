class DatasetModel {
  DatasetModel({required this.name, required this.id});
  late String name;
  late int
   id;

  DatasetModel.fromJson(dynamic data) {
    id = data['pk'];
    name = data['fields']['name'];
  }
}
