import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // to access the 'cameras' list

class CameraScreen extends StatefulWidget {
  final String feature;

  CameraScreen({required this.feature});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      cameras[0], // Use rear camera (make sure cameras list is initialized in main.dart)
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isInitialized = true);
    }).catchError((e) {
      print('Error initializing camera: $e');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feature),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isInitialized
          ? CameraPreview(_controller)
          : Center(child: CircularProgressIndicator()),
    );
  }
}