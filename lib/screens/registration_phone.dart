import 'dart:async';
import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import 'feature_selection_screen.dart';

class RegistrationPhoneScreen extends StatefulWidget {
  final String userName;

  RegistrationPhoneScreen({required this.userName});

  @override
  _RegistrationPhoneScreenState createState() =>
      _RegistrationPhoneScreenState();
}

class _RegistrationPhoneScreenState extends State<RegistrationPhoneScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  Timer? _fallbackTimer;
  bool _proceeding = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(() {
      setState(() {});
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    Future.delayed(Duration(milliseconds: 800), () async {
      await TTSService.speak(
          "Would you kindly repeat the same step, but say your phone number, or type it below.");
    });

    STTService.init();

    _fallbackTimer = Timer(Duration(seconds: 20), () {
      if (!_proceeding && _phoneController.text.isEmpty) {
        TTSService.speak(
            "We are going to let you log in as a random user. No data will be saved.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FeatureSelectionScreen(userName: "Guest"),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fallbackTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final result = await STTService.listen(seconds: 7);
    if (result.isNotEmpty) {
      _phoneController.text = result.replaceAll(RegExp(r'\D'), '');
      _validateAndContinue();
    } else {
      await TTSService.speak(
          "Sorry, I didn’t catch that. Try typing instead.");
    }
  }

  void _validateAndContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8 || !RegExp(r'^\d+$').hasMatch(phone)) {
      await TTSService.speak(
          "Process failed. That number doesn't look valid. Please try again.");
      return;
    }

    _proceeding = true;
    await TTSService.speak("Process succeeded. Welcome ${widget.userName}");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FeatureSelectionScreen(userName: widget.userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GestureDetector(
            onLongPress: _startListening,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(Icons.phone_android, size: 80, color: Colors.white),
                ),
                SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Hold to say your phone number\nor type it below",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'CoolFont',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _phoneController.text.trim().isNotEmpty
                      ? _validateAndContinue
                      : null,
                  child: Text("Continue"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    textStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}