import 'dart:math';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class SetAlarmHome extends StatefulWidget {
  SetAlarmHome({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SetAlarmHomeState createState() => _SetAlarmHomeState();
}

class _SetAlarmHomeState extends State<SetAlarmHome> {
  var _dayController = TextEditingController();
  var _hourController = TextEditingController();
  var _minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();
  }

// The callback for our alarm
  static Future<void> callback() async {
    print('Alarm fired!');
  }

  _saveAlarmTime(String datetime) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("alarmTime", datetime);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline3;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Alarm Setting",
              style: textStyle,
            ),
            RaisedButton(
              child: Text(
                'Schedule Alarm',
              ),
              key: ValueKey('RegisterOneShotAlarm'),
              onPressed: () async {
                var _day = int.parse(_dayController.text);
                var _hour = int.parse(_hourController.text);
                var _minute = int.parse(_minuteController.text);

                var _alarmTime = DateTime(2020, 8, _day, _hour, _minute);

                await AndroidAlarmManager.oneShotAt(
                  _alarmTime,
                  // Ensure we have a unique alarm ID.
                  Random().nextInt(pow(2, 31)),
                  callback,
                  exact: true,
                  wakeup: true,
                );
                _saveAlarmTime(_alarmTime.toString());
              },
            ),
            TextFormField(
              controller: _dayController,
            ),
            TextFormField(
              controller: _hourController,
            ),
            TextFormField(
              controller: _minuteController,
            ),
          ],
        ),
      ),
    );
  }
}