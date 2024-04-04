
import 'dart:async';

import 'package:flutter/material.dart';

class DayTimeLine extends StatefulWidget {

  late List<Widget> elements = [];

  @override
  State createState() => _DayTimeLineState();
}

class _DayTimeLineState extends State<DayTimeLine> {

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int distance = 0;

  @override
  void initState() {
    super.initState();

    widget.elements = [];
    widget.elements.add(
        Positioned(
            top: distance.toDouble(),
            right: 5,
            child: Text(displayTime, style: TextStyle(
                foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white,
                fontWeight: FontWeight.bold
            ))
        )
    );
    widget.elements.add(
        Positioned(
            top: distance.toDouble(),
            right: 5,
            child: Text(displayTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
        )
    );
    widget.elements.add(
        Positioned(
            top: distance.toDouble(),
            left: 0,
            right: 0, //1350
            child: Container(
              height: 2,
              color: Colors.red,
            )
        )
    );

    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      currentTime = DateTime.now();

      var currentHour = currentTime.hour < 10 ? "0${currentTime.hour}" :currentTime.hour;
      var currentMinute = currentTime.minute < 10 ? "0${currentTime.minute}" : currentTime.minute;
      displayTime = "$currentHour:$currentMinute";

      distance = currentTime.hour * 60 + currentTime.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text("");
  }

}