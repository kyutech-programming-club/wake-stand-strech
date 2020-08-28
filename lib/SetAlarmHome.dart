import 'dart:math';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/widgets.dart';
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
  bool _isSet = false;

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
        backgroundColor: Colors.lightGreen,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(),
            ),
            Flexible(
              flex: 1,
              child:Text(
                "Alarm Setting",
                style: textStyle,
              ),
            ),
            Flexible(
              flex: 1,
              child: myDateTimePicker(),
            ),
            Flexible(
              flex: 1,
              child: mySetButton(),
            ),
          ],
        ),
      ),
    );
  }
  Widget myDateTimePicker() {
    return  Row(
      children: [
        Expanded(
          flex:1,
          child: Container(),
        ),
        Expanded(
          flex: 10,
          child: Text(
            // フォーマッターを使用して指定したフォーマットで日時を表示
            // format()に渡すのはDate型の値で、String型で返される
            formatter.format(_myDateTime),
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        Expanded(
          flex:2,
          child:FloatingActionButton(
            onPressed: () {
              DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                // onChanged内の処理はDatepickerの選択に応じて毎回呼び出される
                onChanged: (date) {
                  //   print('change $date');
                  setState(() {
                    _isSet = false;
                  });
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
            backgroundColor: Colors.lightGreen,
            splashColor: Colors.green,
            child: Icon(Icons.access_time,),
          ),
        ),
        Expanded(
          flex:1,
          child: Container(),
        ),
      ],
    );
  }

  Widget mySetButton() {
    return RaisedButton(
      child: Text(
        _isSet? "Done" : "Set",
        style: TextStyle(
          fontFamily: 'JockeyOne',
          fontWeight: FontWeight.bold,
          fontSize: 50,
          color: Colors.white,
        ),
      ),
      shape: StadiumBorder(),
      key: ValueKey('RegisterOneShotAlarm'),
      onPressed: () async {
        var _date = DateTime.parse(formatter.format(_myDateTime));
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
        setState(() {
          _isSet = true;
        });
      },
      color: _isSet? Colors.grey : Colors.lightGreen,
      splashColor: Colors.green,
    );
  }
}