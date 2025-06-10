import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';

class VoiceAIChatScreen extends StatefulWidget {
  @override
  _VoiceAIChatScreenState createState() => _VoiceAIChatScreenState();
}

class _VoiceAIChatScreenState extends State<VoiceAIChatScreen> {
  String _conversation = "Say something to your AI companion...";
  bool _isListening = false;

  void _startChat() async {
    setState(() {
      _isListening = true;
      _conversation = "Listening...";
    });

    String userInput = await STTService.listen(seconds: 5);

    if (userInput.isEmpty) {
      setState(() {
        _conversation = "Didn't catch that. Try again!";
        _isListening = false;
      });
      return;
    }

    setState(() => _conversation = "You: $userInput\n\nThinking...");

    String response = await AIService.getResponse(userInput);

    setState(() {
      _conversation = "You: $userInput\n\nAI: $response";
      _isListening = false;
    });

    await TTSService.speak(response);
  }

  @override
  void initState() {
    super.initState();
    STTService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Companion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _conversation,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isListening ? null : _startChat,
              icon: Icon(Icons.mic),
              label: Text(_isListening ? "Listening..." : "Talk"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}