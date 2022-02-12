import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      DashboardController(),
    );
    Get.put(
      SummaryController(),
    );
  }
}
