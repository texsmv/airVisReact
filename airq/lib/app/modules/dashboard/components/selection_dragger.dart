import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double minWidth = 10;

class SelectionDragger extends StatefulWidget {
  const SelectionDragger({Key? key}) : super(key: key);

  @override
  _SelectionDraggerState createState() => _SelectionDraggerState();
}

class _SelectionDraggerState extends State<SelectionDragger> {
  late BoxConstraints _constraints;
  double _selectionWidth = 200;
  double _selectionStart = 0;
  double get height => _constraints.maxHeight;
  SummaryController summaryController = Get.find();
  DatasetController datasetController = Get.find();

  void updateSelectionDates() {
    summaryController.selectionStartIndex =
        (_selectionStart / _constraints.maxWidth * summaryController.maxWindows)
            .toInt();
    summaryController.selectionEndIndex = ((_selectionStart + _selectionWidth) /
                _constraints.maxWidth *
                summaryController.maxWindows +
            1)
        .toInt();
    DateTime beginDate, endDate;
    if (summaryController.granularity == Granularity.annual) {
      summaryController.beginDate = datasetController.yearRange.first.add(
        Duration(
          days: summaryController.selectionStartIndex * 365,
        ),
      );
      summaryController.endDate = datasetController.yearRange.first.add(
        Duration(
          days: summaryController.selectionEndIndex * 365,
        ),
      );
    } else {
      summaryController.beginDate = datasetController.dayRange.first.add(
        Duration(
          days: summaryController.selectionStartIndex,
        ),
      );
      summaryController.endDate = datasetController.dayRange.first.add(
        Duration(
          days: summaryController.selectionEndIndex,
        ),
      );
    }
    // summaryController.computeDates();
    // * For debbuging
    if (false) {
      print('maxWindows: ${summaryController.maxWindows}');
      print(
          'startWindow: $summaryController.selectionStartIndex endWindow: $summaryController.selectionEndIndex');
      print(
          'startYear: ${summaryController.beginDate} endYear: ${summaryController.endDate}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: selectorSpaceLeft),
        Expanded(
          child: LayoutBuilder(builder: (_, constraints) {
            _constraints = constraints;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                setState(() {
                  _selectionStart = details.localPosition.dx;
                });
              },
              onHorizontalDragEnd: (details) {
                summaryController.computeIntersection(notify: true);
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  double tempWidth = details.localPosition.dx - _selectionStart;
                  if (tempWidth > minWidth) {
                    _selectionWidth = tempWidth;
                    updateSelectionDates();
                  }
                });
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      left: _selectionStart,
                      top: 0,
                      child: Container(
                        height: height,
                        width: _selectionWidth,
                        color: Colors.black.withOpacity(0.25),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: selectorSpaceRight),
      ],
    );
  }
}
