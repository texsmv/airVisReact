import 'dart:math';

import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
import 'package:airq/app/widgets/pcard.dart';
import 'package:airq/controllers/dataset_controller.dart';
import 'package:airq/models/station_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

double subtileHeight = 15;

class StationItem extends GetView<SummaryController> {
  final List<Color> colors;
  final List<List<bool>> sections;
  final List<List<bool>> intersection;
  final String name;
  final StationModel station;
  final bool selected;
  final int index;
  StationItem({
    Key? key,
    required this.colors,
    required this.sections,
    required this.name,
    required this.selected,
    required this.intersection,
    required this.station,
    required this.index,
  }) : super(key: key);

  List<bool>? _selectedIndexes;
  List<bool> get selectedIndexes {
    if (_selectedIndexes != null) return _selectedIndexes!;
    _selectedIndexes = List.generate(sections.first.length, (index) => false);

    for (var j = 0; j < sections.first.length; j++) {
      bool colVal = true;
      for (var i = 0; i < sections.length; i++) {
        colVal = sections[i][j] && colVal;
      }
      _selectedIndexes![j] = colVal;
    }
    return _selectedIndexes!;
  }

  List<String> get selectedPollutants => List.generate(
      controller.selectedPollutants.length,
      (index) => controller.selectedPollutants[index].name);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: subtileHeight * sections.length,
      child: Row(
        children: [
          Container(
            width: selectorSpaceLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${index.toString()}.-"),
                    Text("${station.name}"),
                  ],
                ),
                SizedBox(
                  height: 25,
                  child: IconButton(
                    onPressed: () {
                      controller.toggleStation(station.id);
                    },
                    icon: Icon(
                      selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              height: subtileHeight * sections.length,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SizedBox(
                      height: subtileHeight * sections.length,
                      child: CustomPaint(
                        painter: StationTilePainter(
                          isSelected: selected,
                          intersection: intersection,
                          colors: colors,
                          sections: sections,
                          selectedIndexes: selectedIndexes,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          sections.length,
                          (index) => Text(
                            selectedPollutants[index],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 0.3,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: selectorSpaceRight),
        ],
      ),
    );
  }
}

class StationTilePainter extends CustomPainter {
  final List<Color> colors;
  final List<List<bool>> sections;
  final List<List<bool>> intersection;
  final List<bool> selectedIndexes;
  final bool isSelected;

  StationTilePainter({
    Key? key,
    required this.colors,
    required this.sections,
    required this.intersection,
    required this.selectedIndexes,
    required this.isSelected,
  });

  late double width;
  late double height;
  late Canvas _canvas;
  late double _rowHeight;
  late double _itemWidth;
  int get _nDates => sections.first.length;

  SummaryController summaryController = Get.find();

  @override
  void paint(Canvas canvas, Size size) {
    width = size.width;
    height = size.height;
    _canvas = canvas;

    _rowHeight = height / sections.length;
    _itemWidth = width / _nDates;
    for (var i = 0; i < sections.length; i++) {
      _drawRow(i);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawRow(int pos) {
    Paint normalPaint = Paint()
      ..color = colors[pos]
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Paint intersectionPaint = Paint()
      ..color = Color.fromRGBO(
        min(255, colors[pos].red * 2.7).toInt(),
        min(255, colors[pos].green * 2.7).toInt(),
        min(255, colors[pos].blue * 2.7).toInt(),
        colors[pos].opacity,
      )
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Paint emptyPaint = Paint()
      ..color = const Color.fromRGBO(240, 190, 20, 1)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    for (var i = 0; i < _nDates; i++) {
      Paint paint;
      // if (sections[pos][i] && intersection[pos][i]) {
      if (isSelected &&
          selectedIndexes[i] &&
          summaryController.windowSelectedIndexes[i]) {
        paint = intersectionPaint;
      } else if (sections[pos][i]) {
        // } else if (selectedIndexes[i]) {
        paint = normalPaint;
      } else {
        paint = emptyPaint;
      }
      _canvas.drawRect(
        Rect.fromLTWH(
          i * _itemWidth,
          pos * _rowHeight,
          _itemWidth,
          _rowHeight,
        ),
        paint,
      );
    }
  }
}
