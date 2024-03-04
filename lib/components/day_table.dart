import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class DayTable<T extends Object?> extends StatelessWidget {


  const DayTable({super.key});

  BoxDecoration getHourRowDecoration(int i) {
    if (i == 23) {
      return const BoxDecoration(
          border: Border(
            top: BorderSide(),
            bottom: BorderSide()
          )
      );
    }
    return const BoxDecoration(
        border: Border(
            top: BorderSide()
        )
    );
  }

  BoxDecoration getEventRowDecoration(int i) {
    if (i == 23) {
      return const BoxDecoration(
        border: Border(
            top: BorderSide(),
            left: BorderSide(),
            right: BorderSide(),
            bottom: BorderSide()
        )
      );
    }
    return const BoxDecoration(
      border: Border(
        top: BorderSide(),
        left: BorderSide(),
        right: BorderSide()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(0),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FixedColumnWidth(120),
            1: FlexColumnWidth()
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            for (int i=0; i < 24; i++)
              TableRow(
                key: ValueKey("Hour$i"),
                children: <Widget>[
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container( // Hours
                          height: 60,
                          width: 100,
                          decoration: getHourRowDecoration(i),
                          child: Text(showHours(i), textAlign: TextAlign.center)
                      )
                  ),
                  TableCell (
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Container( // Events
                        height: 60,
                        width: 900,
                        decoration: getEventRowDecoration(i)
                      )
                    ),
                ],
              )
          ],
        )
    );
  }

  static String showHours(int i) {
    return (i < 10) ? '0$i:00' : '$i:00';
  }

}


// class LiveTimeIndicator extends StatefulWidget {
//   /// Width of indicator
//   final double width;
//
//   /// Height of total display area indicator will be displayed
//   /// within this height.
//   final double height;
//
//   /// Width of time line use to calculate offset of indicator.
//   final double timeLineWidth;
//
//   /// settings for time line. Defines color, extra offset,
//   /// height of indicator and also allow to show time with custom format.
//   final LiveTimeIndicatorSettings liveTimeIndicatorSettings;
//
//   /// Defines height occupied by one minute.
//   final double heightPerMinute;
//
//   /// Widget to display tile line according to current time.
//   const LiveTimeIndicator(
//       {Key? key,
//         required this.width,
//         required this.height,
//         required this.timeLineWidth,
//         required this.liveTimeIndicatorSettings,
//         required this.heightPerMinute})
//       : super(key: key);
//
//   @override
//   _LiveTimeIndicatorState createState() => _LiveTimeIndicatorState();
// }
//
// class _LiveTimeIndicatorState extends State<LiveTimeIndicator> {
//   late Timer _timer;
//   late TimeOfDay _currentTime = TimeOfDay.now();
//
//   @override
//   void initState() {
//     super.initState();
//
//     _timer = Timer.periodic(Duration(seconds: 1), _onTick);
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
//
//   /// Creates an recursive call that runs every 1 seconds.
//   /// This will rebuild TimeLineIndicator every second. This will allow us
//   /// to indicate live time in Week and Day view.
//   void _onTick(Timer? timer) {
//     final time = TimeOfDay.now();
//     if (time != _currentTime && mounted) {
//       _currentTime = time;
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentHour = _currentTime.hourOfPeriod.appendLeadingZero();
//     final currentMinute = _currentTime.minute.appendLeadingZero();
//     final currentPeriod = _currentTime.period.name;
//     final timeString = widget.liveTimeIndicatorSettings.timeStringBuilder
//         ?.call(DateTime.now()) ??
//         '$currentHour:$currentMinute $currentPeriod';
//     return CustomPaint(
//       size: Size(widget.width, widget.height),
//       painter: CurrentTimeLinePainter(
//         color: red,
//         height: widget.liveTimeIndicatorSettings.height,
//         offset: Offset(
//           widget.timeLineWidth + widget.liveTimeIndicatorSettings.offset,
//           _currentTime.getTotalMinutes * widget.heightPerMinute,
//         ),
//         timeString: timeString,
//         showBullet: widget.liveTimeIndicatorSettings.showBullet,
//         showTime: widget.liveTimeIndicatorSettings.showTime,
//         showTimeBackgroundView:
//         widget.liveTimeIndicatorSettings.showTimeBackgroundView,
//         bulletRadius: widget.liveTimeIndicatorSettings.bulletRadius,
//         timeBackgroundViewWidth:
//         widget.liveTimeIndicatorSettings.timeBackgroundViewWidth,
//       ),
//     );
//   }
// }