import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

const String ssd = "SSD MobileNer";
const String yolo = "Tiny YOLOv2";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TfliteHome(),
    );
  }
}

class TfliteHome extends StatefulWidget {
  @override
  _TfliteHomeState createState() => _TfliteHomeState();
}

class _TfliteHomeState extends State<TfliteHome> {
  String _model = ssd;
  File _image;

  double _imageWidth;
  double _imageHeight;
  bool _busy = false;

  List _recognitions;

  selectFromImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _busy = true;
    });

    predictImage(image);
  }

  predictImage(File image) async {
    if (image == null) return;

    if (_model == yolo) {
      await yoloV2Tiny(image);
    } else {
      await ssdMobileNet(image);
    }

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageWidth = info.image.height.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    }));

    setState(() {
      _image = image;
      _busy = false;
    });
  }

  yoloV2Tiny(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        model: "YOLO",
        threshold: 0.3,
        imageMean: 0.0,
        imageStd: 255.0,
        numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Text("No image Selected") : Image.file(_image),
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text("TFlite Demo"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.image),
        tooltip: "Pick image from galery",
        onPressed: selectFromImagePicker,
      ),
      body: Stack(
        children: stackChildren,
      ),
    );
  }
}
