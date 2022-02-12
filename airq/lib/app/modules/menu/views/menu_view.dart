import 'dart:ui';

import 'package:airq/app/constants/colors.dart';
import 'package:airq/app/modules/menu/components/menu_item.dart';
import 'package:airq/app/widgets/pcard.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:glass_kit/glass_kit.dart';

import '../controllers/menu_controller.dart';

class MenuView extends GetView<MenuController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pColorScaffold,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: pColorPrimary,
        alignment: Alignment.center,
        child: Container(
          height: 600,
          width: 1250,
          child: PCard(
            color: pColorScaffold,
            child: Container(
              child: Row(
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Select one dataset',
                      style: TextStyle(
                        fontSize: 36,
                        color: pColorPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'DatasetName',
                                      style: TextStyle(
                                        color: pTextColorSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Pollutants',
                                      style: TextStyle(
                                        color: pTextColorSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Nro of stations',
                                      style: TextStyle(
                                        color: pTextColorSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Options',
                                      style: TextStyle(
                                        color: pTextColorSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(0),
                            itemCount: controller.datasets.length,
                            itemBuilder: (_, index) {
                              return MenuItem(
                                dataset: controller.datasets[index],
                              );
                            },
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('MenuView'),
    //     centerTitle: true,
    //   ),
    //   body: ListView.separated(
    //     itemBuilder: (_, index) {
    //       return MenuItem();

    //       return OutlinedButton(
    //         onPressed: () {
    //           controller.openDataset(controller.datasets[index]);
    //         },
    //         child: Text(controller.datasets[index].name),
    //       );
    //     },
    //     separatorBuilder: (_, index) => const SizedBox(height: 10),
    //     itemCount: controller.datasets.length,
    //   ),
    // );
  }
}
