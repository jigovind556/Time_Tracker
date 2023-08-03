import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VennDiagram extends StatelessWidget {
  final String subject;
  final int attendance;
  final int classTillDate;

  VennDiagram({
    required this.subject,
    required this.attendance,
    required this.classTillDate,
  });

  @override
  Widget build(BuildContext context) {
    double attendancePercentage = (attendance * 100) / classTillDate;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ListTile(
                title: Text(
                  subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: (classTillDate!=0)?Text('${attendancePercentage.toStringAsFixed(2)}%') :Text("No Class"),
              ),
            ),
            Expanded(
              flex: 1,
              child: (classTillDate!=0)?Container(
                height: 80,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 20,
                    sections: [
                      PieChartSectionData(
                        value: attendancePercentage,
                        color: Theme.of(context).primaryColorLight,
                      ),
                      PieChartSectionData(
                        value: 100 - attendancePercentage,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ):Container(),
            ),
          ],
        ),
      ),
    );
  }
}