import 'dart:math' as math;
import 'dart:async';

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
  AudioCache cacheClassic = new AudioCache(prefix: 'assets/');
  AudioPlayer playerClassic;
  bool _isCameraActive = false;
  AudioCache cacheGood = new AudioCache(prefix: 'assets/');
  AudioPlayer playerGood;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(
      widget.cameras[0],
      ResolutionPreset.ultraHigh,
    );
    controller.initialize();
    _loopFile("wakeUp.wav");
    setState(() {
      _mode = "wakeUp";
    });
  }

  void _playFile(String fileName) async{
    playerGood = await cacheGood.play(fileName+".wav");
  }

  void _loopFile(String fileName) async {
    player = await cache.loop(fileName);
  }

  voice(mode) async{
    await new Future.delayed(new Duration(seconds: 1));
      _loopFile(mode + ".wav");

      if (mode == "standingOnTiptoe") {
        playerClassic = await cache.loop("classic.mp3", volume: 0.1);
      }

      if (mode == "leftSide") {
        playerClassic?.stop();
        playerClassic = await cache.loop("classic.mp3", volume: 0.3);
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
          _mode = "rightSide";
        });
        break;
      case "rightSide":
        setState(() {
          _mode = "leftSide";
        });
        break;
      case "leftSide":
        setState(() {
          _mode = "bending";
        });
        break;
      case "bending":
        setState(() {
          _mode = "finish";
          //ここの動作を追加
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
        voice(_mode);
      }
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });

    if (_mode == poseType) {
      changeMode(_mode);
      if (_mode == "finish") {
        player?.stop();
        _playFile("finish");
        playerClassic?.stop();
      } else {
        player?.stop();
        _playFile("goodPose");
        voice(_mode);
      }
    }

    print("-----------------------------------------------------");
    print(_mode);
    print("-----------------------------------------------------");
    print(poseType);
    print("-----------------------------------------------------");
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
      ):_mode == "finish" ?
      Text("おはよう")
      :Stack(
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