import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';

class AIChatScreen extends StatefulWidget {
  final String userName;

  AIChatScreen({required this.userName});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'sender': 'user'/'ai', 'text': ...}
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    STTService.init();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isLoading = true;
    });
    _controller.clear();

    final response = await AIService.getResponse(message);

    setState(() {
      _messages.add({'sender': 'ai', 'text': response});
      _isLoading = false;
    });

    await TTSService.speak(response);
  }

  Future<void> _startListening() async {
    final speechText = await STTService.listen(seconds: 5);
    if (speechText.isNotEmpty) {
      _sendMessage(speechText);
    }
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? Colors.purpleAccent : Colors.deepPurple.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'CoolFont'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Companion - ${widget.userName}"),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic, color: Colors.purpleAccent),
                  onPressed: _startListening,
                  tooltip: "Speak",
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white, fontFamily: 'CoolFont'),
                    decoration: InputDecoration(
                      hintText: "Type your message",
                      hintStyle: TextStyle(color: Colors.white54, fontFamily: 'CoolFont'),
                      filled: true,
                      fillColor: Colors.deepPurple.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.purpleAccent),
                  onPressed: () => _sendMessage(_controller.text),
                  tooltip: "Send",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}