import 'package:day_planner_web/components/day_table.dart';
import 'package:flutter/material.dart';

class CurrentTimeLine extends StatelessWidget {

  final int distance;
  final String currentTime;

  const CurrentTimeLine({
    super.key,
    required this.distance,
    required this.currentTime
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: distance.toDouble(),
          left: 0,
          right: 0, //1350
          child: Container(
            height: 2,
            color: Colors.red,
          )
        ),
        Positioned(
          top: distance.toDouble(),
          left: 130,
          child: Text(currentTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
        ),
        const DayTable()
      ]
    );
  }
}