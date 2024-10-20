import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Music Production',
      theme: ThemeData(
        fontFamily: 'SF Pro Text',
        colorScheme: ColorScheme.light().copyWith(
          primary: Colors.blueAccent,
          secondary: Colors.amber,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      home: DefaultTabController(
        length: 3,
        child: MusicProductionHome(),
      ),
    );
  }
}

class MusicProductionHome extends StatefulWidget {
  @override
  _MusicProductionHomeState createState() => _MusicProductionHomeState();
}

class _MusicProductionHomeState extends State<MusicProductionHome> {
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _refinedLyricsController = TextEditingController();
  String _generatedLyrics = '';
  String _refinedLyrics = '';
  bool _loading = false;
  FlutterTts flutterTts = FlutterTts();  // Flutter TTS instance
  // Added for mood selection
  String _selectedMood = 'Neutral';
  final List<String> _moods = ['Neutral', 'Happy', 'Sad', 'Funny', 'Serious'];

  @override
  void dispose() {
    flutterTts.stop(); // Stops TTS when the screen is disposed
    super.dispose();
  }
  void _playLyricsAsVoice() async {
    String text = _generatedLyrics;  // The generated lyrics
    String selectedLanguage = _languageController.text;

    String languageCode;
    if (selectedLanguage.toLowerCase() == "telugu") {
      languageCode = 'te-IN';  // Telugu voice if available
    }if (selectedLanguage.toLowerCase() == "hindi") {
      languageCode = 'hi-IN';  // Hindi voice
    } else if (selectedLanguage.toLowerCase() == "japanese") {
      languageCode = 'ja-JP';  // Japanese voice
    } else if (selectedLanguage.toLowerCase() == "korean") {
      languageCode = 'ko-KR';  // Korean voice
    } else if (selectedLanguage.toLowerCase() == "spanish") {
      languageCode = 'es-ES';  // Spanish voice
    } else if (selectedLanguage.toLowerCase() == "french") {
      languageCode = 'fr-FR';  // French voice
    } else if (selectedLanguage.toLowerCase() == "german") {
      languageCode = 'de-DE';  // German voice
    } else {
      languageCode = 'en-US';  // Default to English if language not supported
    }

    // Speak the generated lyrics in the selected language
    await _speakLyrics(text, languageCode);
  }

  Future<void> _speakLyrics(String lyrics, String language) async {
    await flutterTts.setLanguage(language); // Set the language for TTS
    await flutterTts.speak(lyrics); // Speak the generated lyrics
  }

  // Map language input to supported TTS languages
  String _getLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case 'spanish':
        return 'es-ES'; // Spanish
      case 'english':
        return 'en-US'; // English
      case 'hindi' :
        return 'hi-IN';
      case 'telugu' :
        return 'te-IN';
      case 'kannada' :
        return 'kn-IN';
      case 'tamil' :
        return 'ta-IN';
      case 'marathi' :
        return 'mr-IN';
      case 'malayalam' :
        return 'ml-IN';
      case 'french':
        return 'fr-FR'; // French
      case 'german':
        return 'de-DE'; // German
      case 'italian':
        return 'it-IT'; // Italian
      default:
        return 'en-US'; // Default to English
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.lightBlueAccent.shade100],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('AI Assisted Music Production'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.language), text: 'Language'),
              Tab(icon: Icon(Icons.category), text: 'Genre'),
              Tab(icon: Icon(Icons.library_music), text: 'Lyrics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTextFieldTab('Enter the language for the lyrics', _languageController),
            _buildTextFieldTab('Enter the genre of the song', _genreController),
            _buildLyricsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldTab(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildLyricsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Describe the song you want to produce',
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 16.0),
          
          // Mood Dropdown
          DropdownButtonFormField<String>(
            value: _selectedMood,
            items: _moods.map((String mood) {
              return DropdownMenuItem<String>(
                value: mood,
                child: Text(mood),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMood = newValue!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Mood',
              border: OutlineInputBorder(),
            ),
          ),
          
          SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              onPressed: _createOrUpdateLyrics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                _loading ? 'Generating...' : 'Create/Update Lyrics',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Generated Lyrics:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: SingleChildScrollView(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Text(
                          _generatedLyrics.isEmpty
                              ? 'Lyrics will appear here'
                              : _generatedLyrics,
                          style: TextStyle(color: Colors.black),
                        ),
                        if (_generatedLyrics.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              _speakLyrics(_generatedLyrics, _getLanguageCode(_languageController.text));
                            },
                            child: Text('Play Lyrics'),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _createOrUpdateLyrics() async {
    setState(() {
      _loading = true;
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/generate_lyrics'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'description': _descriptionController.text,
        'language': _languageController.text,
        'genre': _genreController.text,
        'mood': _selectedMood,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _generatedLyrics = data['lyrics'];
      });
    } else {
      setState(() {
        _generatedLyrics = 'Failed to generate lyrics';
      });
    }

    setState(() {
      _loading = false;
    });
  }
}

