import 'dart:developer';

import 'package:airq/api/app_repository.dart';
import 'package:airq/app/routes/app_pages.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:airq/models/dataset_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  List<DatasetModel> get datasets => datasetController.datasets;

  Future<void> openDataset(DatasetModel dataset) async {
    EasyLoading.show(status: 'Loading...');
    await datasetController.loadDatasetInfo(dataset.id);
    // await datasetController.loadDataset(dataset.id);
    EasyLoading.dismiss();
    Get.toNamed(Routes.DASHBOARD);
  }

  final DatasetController datasetController = Get.find();
}
