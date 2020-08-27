// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs
import 'package:audioplayers/audio_cache.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:wake_stand_strech/SetAlarmHome.dart';
import 'package:wake_stand_strech/StopAlarmHome.dart';

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
    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }
    runApp(StopAlarmApp(cameras));
  } else {
    runApp(SetAlarmApp());
  }
}

class StopAlarmApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  StopAlarmApp(this.cameras);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final player = AudioCache(prefix: 'assets/');
    player.loop('wakeup.wav');
    return MaterialApp(
      title: 'Wake Stand Stretch',
      home: Scaffold(
        body: StopAlarmHome(cameras),
      ),
    );
  }
}

class SetAlarmApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wake Stand Stretch',
      home: SetAlarmHome(title: 'Wake Stand Stretch'),
    );
  }
}