import 'dart:math' as math;

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
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
  AudioCache cache = new AudioCache(prefix: 'assets/');
  AudioPlayer player;
  bool _isCameraActive = false;
  int _count = 1;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(
      widget.cameras[0],
      ResolutionPreset.ultraHigh,
    );
    controller.initialize();
    _loopFile("wakeup.wav");
    setState(() {
      _mode = "wakeUp";
    });
  }

  void _playFile(String fileName) async{
    player = await cache.play(fileName);
  }

  void _loopFile(String fileName) async {
    player = await cache.loop(fileName);
  }

  voice() {
    if (_count % 3 == 0) {
      _playFile("standup.wav");
      setState(() {
        _count = 1;
      });
    }
  }

  changeMode(mode) {
    switch (mode) {
      case "wakeUp":
        setState(() {
          _mode = "standUp";
        });
        break;
      case "standUp":
        setState(() {
          _mode = "standingOnTiptoe";
        });
        break;
      case "standingOnTiptoe":
        setState(() {
          _mode = "leftSide";
        });
        break;
      case "leftSide":
        setState(() {
          _mode = "rightSide";
        });
        break;
      case "rightSide":
        setState(() {
          _mode = "bending";
        });
        break;
    }
  }

  loadModel() async {
    String res;
    res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
    print(res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth, poseType) {
    setState(() {
      if (!_isCameraActive) {
        _isCameraActive = true;
        player?.stop();
      }
      _count += 1;
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
    voice();
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