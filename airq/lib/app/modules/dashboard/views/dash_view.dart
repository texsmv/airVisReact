import 'package:airq/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq/app/visualizations/multiChart/multi_chart.dart';
import 'package:airq/app/widgets/iprojection/iprojection.dart';
import 'package:airq/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq/app/widgets/pcard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

const double space = 30;

class DashView extends GetView<DashboardController> {
  const DashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return SizedBox();
    if (controller.globalPoints == null) {
      return Center(
        child: Text('Select windows'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: space, vertical: space),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: PCard(
                    child: Container(
                      child: GetBuilder<DashboardController>(
                        // tag: 'global',
                        builder: (_) => IProjection(
                          controller: controller.projectionController,
                          points: controller.globalPoints!,
                          onPointsSelected: controller.onPointsSelected,
                          isLocal: false,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: space),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: PCard(
                          child: Container(
                            child: GetBuilder<DashboardController>(
                              // tag: 'local',
                              builder: (_) => Column(
                                children: [
                                  _PollutantSelector(),
                                  Expanded(
                                    child: IProjection(
                                      controller:
                                          controller.localProjectionController,
                                      points: controller.globalPoints!,
                                      onPointsSelected:
                                          controller.onPointsSelected,
                                      isLocal: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: space),
                      Expanded(
                        child: PCard(
                          child: Container(
                            height: double.infinity,
                            child: GetBuilder<DashboardController>(
                              builder: (_) => MultiChart(
                                minValue: 0,
                                maxValue: 50,
                                models: controller.ipoints,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: space),
          Expanded(
            flex: 2,
            child: PCard(
              child: GetBuilder<DashboardController>(
                builder: (_) => Column(
                  children: [
                    _BarChart(
                      values: controller.dayCounts,
                    ),
                    _BarChart(
                      values: controller.monthCounts,
                    ),
                    _BarChart(
                      values: controller.yearCounts,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollutantSelector extends GetView<DashboardController> {
  const _PollutantSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint: Text(
          'Select Item',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: controller.selectedPollutants
            .map((item) => DropdownMenuItem<String>(
                  value: item.name,
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        value: controller.projectedPollutant.name,
        onChanged: (value) {
          controller.selectPollutant(value as String);
        },
        buttonHeight: 40,
        buttonWidth: 140,
        itemHeight: 40,
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;
  const _BarChart({
    Key? key,
    required this.values,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          // groupsSpace: 10,
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                    y: values[index].toDouble(),
                    width: 15,
                    colors: [Colors.amber]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
