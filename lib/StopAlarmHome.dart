import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'package:wake_stand_strech/Camera.dart';

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

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        )
    );
  }
}