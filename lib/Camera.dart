import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

typedef void Callback(List<dynamic> list, int h, int w, String poseType);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  Camera(this.cameras, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.ultraHigh,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;
            Tflite.runPoseNetOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              numResults: 2,
            ).then((recognitions) {
              int endTime = new DateTime.now().millisecondsSinceEpoch;
              print("Detection took ${endTime - startTime}");
              print(recognitions);

              var poseType = checkPose(recognitions);
              widget.setRecognitions(
                  recognitions, img.height, img.width, poseType);

              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() async {
    await controller?.dispose();
    await Tflite.close(); //add to example
    super.dispose();
  }

  String checkPose(dynamic recognitions) {
    if (recognitions.isEmpty) {
      return "None";
    }
    var k = recognitions[0]["keypoints"];
    print("k:$k");
    bool standUp = k[13]["y"] > k[11]["y"] && k[11]["y"] > k[5]["y"] &&
        k[5]["y"] > k[0]["y"];
    bool standingOnTiptoe = k[13]["y"] > k[11]["y"] && k[11]["y"] > k[5]["y"] &&
        k[0]["y"] > k[7]["y"];
    bool leftSide = k[10]["x"] > k[5]["x"] ;
    bool rightSide = k[6]["x"] > k[9]["x"];
    bool bending = k[11]["y"] > k[14]["y"] && k[12]["y"] > k[13]["y"] ;


    if (bending) {
      print("bending");
      return "bending";
    } else if (leftSide) {
      print("leftSide");
      return "leftSide";
    } else if (rightSide) {
      print("rightSide");
      return "rightSide";
    } else if (standingOnTiptoe) {
      print("standingOnTiptoe");
      return "standingOnTiptoe";
    } else if (standUp) {
      print("standUp");
      return "standUp";
    } else {
      return "None";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    var tmp = MediaQuery
        .of(context)
        .size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
      screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
      screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
