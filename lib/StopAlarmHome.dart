import 'package:flutter/material.dart';

class StopAlarmHome extends StatefulWidget {
  StopAlarmHome();

  @override
  _StopAlarmHomeState createState() => new _StopAlarmHomeState();
}

class _StopAlarmHomeState extends State<StopAlarmHome> {
  var _mode = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      _mode = "wakeUp";
    });
  }

  changeMode(mode) {
    switch (mode) {
      case "wakeUp":
        setState(() {
          _mode = "standUp";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
      _mode == "wakeUp" ?
      RaisedButton(
        child: Text("Stop Alarm!\nGo to Stretch"),
        onPressed: () => changeMode(_mode),
      ):
      Text("This is standUp mode page."),
    );
  }
}