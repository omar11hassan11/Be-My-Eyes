import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';
import '../widgets/feature_card.dart';
import 'camera_screen.dart';
import 'ai_chat_screen.dart';

class FeatureSelectionScreen extends StatefulWidget {
  final String userName;

  FeatureSelectionScreen({required this.userName});

  @override
  _FeatureSelectionScreenState createState() => _FeatureSelectionScreenState();
}

class _FeatureSelectionScreenState extends State<FeatureSelectionScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool _greeted = false;

  final List<Map<String, String>> features = [
    {
      'title': 'Scene Description',
      'animation': 'assets/animations/scene.json',
      'desc': 'This option describes your surroundings using AI vision.'
    },
    {
      'title': 'OCR & Translation',
      'animation': 'assets/animations/translate.json',
      'desc': 'Reads and translates text instantly.'
    },
    {
      'title': 'Money Detection',
      'animation': 'assets/animations/money.json',
      'desc': 'Identifies currency and value in your hand.'
    },
    {
      'title': 'AI Companion',
      'animation': 'assets/animations/ai.json',
      'desc': 'Talk with your personal digital assistant.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakFeature(0, greet: true);
    STTService.init();
  }

  Future<void> _speakFeature(int index, {bool greet = false}) async {
    final title = features[index]['title']!;
    final desc = features[index]['desc']!;

    if (greet && !_greeted) {
      _greeted = true;
      await TTSService.speak("Hi ${widget.userName}.");
    }

    await TTSService.speak("$title.");
    await TTSService.speak(desc);
    await TTSService.speak(
      "Do you want this option? Tap the screen to select it, or say NEXT to continue.",
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _speakFeature(index);
  }

  void _goToNextFeature() {
    int nextIndex = (_currentIndex + 1) % features.length;
    _controller.animateToPage(
      nextIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousFeature() {
    int previousIndex = (_currentIndex - 1 + features.length) % features.length;
    _controller.animateToPage(
      previousIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _finishSelection() {
    final selectedFeature = features[_currentIndex]['title']!;
    TTSService.speak("You have selected $selectedFeature. Thank you.");

    if (selectedFeature == 'AI Companion') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AIChatScreen(userName: widget.userName),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CameraScreen(feature: selectedFeature),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi ${widget.userName},",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                        fontFamily: 'CoolFont',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We're pleased to help you!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'CoolFont',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: GestureDetector(
                onTap: _finishSelection,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: features.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return FeatureCard(
                      title: feature['title']!,
                      animation: feature['animation']!,
                      description: feature['desc']!,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: size.height / 2 + 40,
              child: CircleAvatar(
                backgroundColor: Colors.white10,
                radius: 26,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: _goToPreviousFeature,
                  tooltip: 'Previous feature',
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: size.height / 2 + 40,
              child: CircleAvatar(
                backgroundColor: Colors.white10,
                radius: 26,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: _goToNextFeature,
                  tooltip: 'Next feature',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}