import 'dart:async';

import 'package:flutter/material.dart';
import 'package:packop/packopApp.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();
  runApp(new MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Packop",
      theme: new ThemeData(
        primaryColor: new Color(0xff212121),
        accentColor: new Color(0xffeeeeee),
        buttonColor: new Color(0xff212121),
        textSelectionColor: new Color(0xffff3d00)
      ),
      debugShowCheckedModeBanner: false,
      home: new PackopApp(cameras),
    );
  }
}