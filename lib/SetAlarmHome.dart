import 'dart:math';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class SetAlarmHome extends StatefulWidget {
  SetAlarmHome({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SetAlarmHomeState createState() => _SetAlarmHomeState();
}

class _SetAlarmHomeState extends State<SetAlarmHome> {
  var _myDateTime = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd HH:mm');

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
                var _date = DateTime.parse(formatter.format(_myDateTime)+":00");
                var _month = _date.month;
                var _day = _date.day;
                var _hour = _date.hour;
                var _minute = _date.minute;
                var _alarmTime = DateTime(2020, _month, _day, _hour, _minute);

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
            Text(
              'あなたが選択した日時は以下です: ',
            ),
            Text(
              // フォーマッターを使用して指定したフォーマットで日時を表示
              // format()に渡すのはDate型の値で、String型で返される
              formatter.format(_myDateTime),
              style: Theme.of(context).textTheme.headline3,
            ),
            FloatingActionButton(
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  // onChanged内の処理はDatepickerの選択に応じて毎回呼び出される
                  onChanged: (date) {
                  //   print('change $date');
                  },
                  // onConfirm内の処理はDatepickerで選択完了後に呼び出される
                  onConfirm: (date) {
                    setState(() {
                      _myDateTime = date;
                    });
                    print(date);
                  },
                  // Datepickerのデフォルトで表示する日時
                  currentTime: DateTime.now(),
                  // localによって色々な言語に対応
                  //  locale: LocaleType.en
                );
              },
              tooltip: 'Datetime',
              child: Icon(Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}