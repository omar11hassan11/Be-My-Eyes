import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/welcome_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Fetching available cameras...');
    cameras = await availableCameras();
    print('Found ${cameras.length} cameras');
  } catch (e) {
    print('Error fetching cameras: $e');
    cameras = [];
  }

  runApp(BeMyEyesApp());
}

class BeMyEyesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be My Eyes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'CoolFont'),
      ),
      home: WelcomeScreen(),
    );
  }
}
