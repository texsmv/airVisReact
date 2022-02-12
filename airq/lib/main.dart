import 'package:airq/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';

import 'api/app_repository.dart';
import 'app/routes/app_pages.dart';

void main() {
  repositoryDatasets();
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
      onInit: () {
        Get.put(DatasetController(), permanent: true);
      },
    ),
  );
}
