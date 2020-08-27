import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'package:wake_stand_strech/Camera.dart';
import 'package:wake_stand_strech/BndBox.dart';

class StopAlarmHome extends StatefulWidget {
  final List<CameraDescription> cameras;
  StopAlarmHome(this.cameras);

  @override
  _StopAlarmHomeState createState() => new _StopAlarmHomeState();
}

class _StopAlarmHomeState extends State<StopAlarmHome> {
  var _mode = "";
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(
      widget.cameras[0],
      ResolutionPreset.ultraHigh,
    );
    controller.initialize();
    setState(() {
      _mode = "wakeUp";
    });
  }

  stopAlarm(poseType) {
    switch (poseType) {
      case "Stretch":
        print("Stretch");
        break;

      default:
        print("None");
    }
  }

  changeMode(mode) {
    switch (mode) {
      case "wakeUp":
        setState(() {
          _mode = "standUp";
        });
    }
  }

  loadModel() async {
    String res;
    res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
    print(res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth, poseType) {
    stopAlarm(poseType);
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Center(
        child:
        _mode == "wakeUp" ?
        RaisedButton(
          child: Text("Stop Alarm!\nGo to Stretch"),
          onPressed: () {
            changeMode(_mode);
            loadModel();
          },
        ):
        Stack(
          children: [
            Camera(
                widget.cameras,
                setRecognitions
            ),
            BndBox(
                _recognitions == null ? [] : _recognitions,
                math.max(_imageHeight, _imageWidth),
                math.min(_imageHeight, _imageWidth),
                screen.height,
                screen.width,
            ),
          ],
        ),
    );
  }
}