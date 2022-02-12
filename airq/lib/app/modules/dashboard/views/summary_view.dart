import 'package:airq/app/constants/colors.dart';
import 'package:airq/app/modules/dashboard/components/filters.dart';
import 'package:airq/app/modules/dashboard/components/legend.dart';
import 'package:airq/app/modules/dashboard/components/selection_dragger.dart';
import 'package:airq/app/modules/dashboard/components/window_selector.dart';
import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class SummaryView extends GetView<SummaryController> {
  const SummaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: const [
          SizedBox(height: 30),
          SelectionsFilters(),
          SizedBox(height: 20),
          Legend(),
          SizedBox(height: 20),
          Expanded(
            child: WindowSelector(),
          ),
        ],
      ),
    );
  }
}
