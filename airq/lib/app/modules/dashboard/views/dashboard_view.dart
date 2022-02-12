import 'package:airq/app/constants/colors.dart';
import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
import 'package:airq/app/modules/dashboard/views/dash_view.dart';
import 'package:airq/app/modules/dashboard/views/summary_view.dart';
import 'package:airq/app/widgets/side_bar.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            GetBuilder<DashboardController>(
              builder: (_) => SideBar(
                tabs: [
                  ViewTab(
                    icon: Icons.ac_unit_outlined,
                    onTap: () {
                      controller.pageIndex = 0;
                    },
                    text: controller.dataset.name,
                    // text: 'DatasetName',
                    options: dashOptions(),
                  ),
                  ViewTab(
                    icon: Icons.sd_card,
                    onTap: () {
                      controller.pageIndex = 1;
                    },
                    text: "Summary",
                    options: summaryOptions(),
                  ),
                ],
                selectedTab: controller.pageIndex,
              ),
            ),
            Expanded(
              child: Container(
                color: pColorScaffold,
                child: Obx(
                  () => IndexedStack(
                    index: controller.pageIndex,
                    children: [
                      GetBuilder<DatasetController>(builder: (_) {
                        return DashView();
                      }),
                      SummaryView(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> dashOptions() {
    SummaryController summaryController = Get.find<SummaryController>();
    DatasetController datasetController = Get.find<DatasetController>();
    return [
      Column(
        children: [
          Text(
            'Ratio (magnitude-shape)',
            style: TextStyle(fontSize: 15),
          ),
          FlutterSlider(
            values: [datasetController.ratio * 100.0],
            max: 100,
            min: 0,
            onDragging: (handlerIndex, lowerValue, upperValue) {},
            onDragCompleted: (handlerIndex, lowerValue, upperValue) {
              datasetController.changeRatio(lowerValue / 100.0).then((value) {
                controller.update();
              });
            },
          )
        ],
      ),
      Container(
        width: 200,
        height: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.selectedPollutants.length,
          itemBuilder: (_, index) {
            return Container(
              height: 30,
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      controller.selectedPollutants[index].name,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: FlutterSlider(
                      values: [
                        datasetController.alphas[
                                controller.selectedPollutants[index].id]! *
                            100.0
                      ],
                      max: 100,
                      min: 0,
                      onDragging: (handlerIndex, lowerValue, upperValue) {},
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        datasetController
                            .changeAlpha(
                                controller.selectedPollutants[index].id,
                                lowerValue / 100.0)
                            .then((value) {
                          controller.update();
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> summaryOptions() {
    SummaryController summaryController = Get.find<SummaryController>();
    DatasetController datasetController = Get.find<DatasetController>();
    return [
      GetBuilder<DatasetController>(
        builder: (_) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Granularity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: pColorPrimary,
              ),
            ),
            Text(
              datasetController.granularity == Granularity.annual
                  ? 'Annual'
                  : 'Daily',
            ),
          ],
        ),
      ),
      GetBuilder<DatasetController>(
        builder: (_) => Switch(
          value: datasetController.granularity == Granularity.annual,
          onChanged: (value) {
            if (value) {
              summaryController.updateGranularity(Granularity.annual);
              summaryController.computeIntersection();
            } else {
              summaryController.updateGranularity(Granularity.daily);
              summaryController.computeIntersection();
            }
          },
        ),
      ),
      ...List.generate(
        summaryController.pollutants.length,
        (index) => GetBuilder<SummaryController>(
          builder: (_) => RawMaterialButton(
            fillColor: summaryController
                    .isPollutantSelected(summaryController.pollutants[index].id)
                ? pColorAccent
                : const Color.fromRGBO(240, 240, 240, 1),
            onPressed: () => summaryController
                .togglePollutant(summaryController.pollutants[index].id),
            child: Text(
              summaryController.pollutants[index].name,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      OutlinedButton(
        onPressed: () => summaryController.getWindows(),
        child: const Text('Get windows'),
      ),
    ];
  }
}
