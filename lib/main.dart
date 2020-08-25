// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Register the UI isolate's SendPort to allow for communication from the
// background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  runApp(WakeStandStretchApp());
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

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();

  }

// The background
  static SendPort uiSendPort;

// The callback for our alarm
  static Future<void> callback() async {
    print('Alarm fired!');

// This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
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
              "Good Morning!",
              style: textStyle,
            ),
            RaisedButton(
              child: Text(
                'Schedule OneShot Alarm',
              ),
              key: ValueKey('RegisterOneShotAlarm'),
              onPressed: () async {
                await AndroidAlarmManager.oneShot(
                  const Duration(seconds: 10),
                  // Ensure we have a unique alarm ID.
                  Random().nextInt(pow(2, 31)),
                  callback,
                  exact: true,
                  wakeup: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}