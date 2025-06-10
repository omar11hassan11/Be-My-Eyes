import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import 'registration_phone.dart';

class RegistrationNameScreen extends StatefulWidget {
  @override
  _RegistrationNameScreenState createState() => _RegistrationNameScreenState();
}

class _RegistrationNameScreenState extends State<RegistrationNameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {}); // Rebuild to enable/disable button
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

    Future.delayed(Duration(seconds: 1), () async {
      await TTSService.speak(
        "Would you kindly hold the middle of your screen and say your name, or type it below.",
      );
    });

    STTService.init();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final result = await STTService.listen(seconds: 5);
    if (result.isNotEmpty) {
      setState(() {
        _textController.text = result;
      });

      await TTSService.speak("Thanks $result");
      await Future.delayed(Duration(seconds: 1));
      _goToNext();
    } else {
      await TTSService.speak("Sorry, I didn't catch that. Try typing instead.");
    }
  }

  void _goToNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationPhoneScreen(
          userName: _textController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.black, Colors.indigo.shade800],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
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
                        color: Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(Icons.mic, size: 80, color: Colors.white),
                ),
                SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Hold to speak your name\nor type below",
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
                  controller: _textController,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "Your Name",
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
                  onPressed: _textController.text.trim().isEmpty
                      ? null
                      : _goToNext,
                  child: Text("Continue"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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