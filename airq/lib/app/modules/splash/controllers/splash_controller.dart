import 'package:airq/app/routes/app_pages.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    _initSettings();
    super.onInit();
  }

  Future<void> _initSettings() async {
    await datasetController.loadDatasets();
    route();
  }

  void route() {
    Get.toNamed(Routes.MENU);
  }

  final DatasetController datasetController = Get.find();
}
