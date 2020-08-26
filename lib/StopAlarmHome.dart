import 'package:flutter/material.dart';

class StopAlarmHome extends StatefulWidget {
  StopAlarmHome();

  @override
  _StopAlarmHomeState createState() => new _StopAlarmHomeState();
}

class _StopAlarmHomeState extends State<StopAlarmHome> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Good Morning!\nLet's stand & stretch!",
      ),
    );
  }
}