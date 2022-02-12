import 'package:airq/app/constants/colors.dart';
import 'package:airq/app/modules/menu/controllers/menu_controller.dart';
import 'package:airq/app/routes/app_pages.dart';
import 'package:airq/models/dataset_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuItem extends GetView<MenuController> {
  final DatasetModel dataset;
  const MenuItem({Key? key, required this.dataset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'London',
                style: TextStyle(
                  color: pTextColorPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'CO, PM10, PM2.5',
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '15',
              ),
            ),
          ),
          Expanded(
            child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => controller.openDataset(dataset),
                      icon: Icon(
                        Icons.open_in_new,
                        color: Colors.blueAccent,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.openDataset(dataset),
                      icon: Icon(Icons.download),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
