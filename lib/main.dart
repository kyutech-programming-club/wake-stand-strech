// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs
import 'dart:math';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _readAlarmTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString("alarmTime");
    return DateTime.parse(data);
  }
  bool _isAlarm(DateTime alarmTime) {
    var now = new DateTime.now();
    now = new DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (alarmTime == now) {
      return true;
    }
    return false;
  }
  var alarmTime = await _readAlarmTime();
  if (_isAlarm(alarmTime)) {
    runApp(PoseNetApp());
  } else {
    runApp(WakeStandStretchApp());
  }
}

class PoseNetApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final player = AudioCache(prefix: 'assets/');
    player.loop('wakeup.wav');
    return MaterialApp(
      title: 'Wake Stand Stretch',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Pose Net App"),
        ),
        body: Center(
          child: Text(
            "Good Morning!\nLet's stand & stretch!",
          ),
        ),
      ),
    );
  }
}

class WakeStandStretchApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wake Stand Stretch',
      home: _HomePage(title: 'Wake Stand Stretch'),
    );
  }
}

class _HomePage extends StatefulWidget {
  _HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
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