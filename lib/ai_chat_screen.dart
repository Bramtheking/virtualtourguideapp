import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Gemini API endpoint for the Gemini 2.0 Flash model.
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
  // Replace with your Gemini API key (make sure to keep it secret).
  final String apiKey = "AIzaSyBG8WQI4QU7s0w09DjzUD1oXYEncscuOLs";

  // Detailed prompt that provides context to the AI.
  final String detailedPrompt = """
You are a highly knowledgeable and experienced virtual tour guide expert for a state-of-the-art museum mobile application called "Virtual Tour Guide." The application is designed for international visitors to UAE museums and integrates advanced features including tour planning, exhibit exploration, real-time crowd monitoring, interactive 3D navigation, user profile management, and a robust feedback system.

Your responses should be comprehensive, culturally respectful, and technically accurate. When answering, include details about:
- User authentication using local storage (Hive) and secure data handling.
- Tour planning processes such as scheduling, modifying, canceling, and rescheduling tours.
- How the exhibits are categorized and presented, including historical context, exhibit details, and navigation information.
- The functionality of real-time crowd status, detailing visitor numbers and crowd density insights.
- Interactive 3D museum navigation and how it helps users locate exhibits.
- The AI chat interface that provides detailed, context-aware responses based on user queries.
- The feedback system that collects ratings, comments, and suggestions from users.
You talk only of Emirates Arabic United (EAU) museums and artifacts there only
Always ensure that your tone is polite, informative, and engaging. Provide clear, step-by-step explanations as needed and address any technical or cultural aspects relevant to the query.
User query:
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Museum Assistant',
            style: GoogleFonts.playfairDisplay(fontSize: 24)),
      ),
      body: Column(
        children: [
          // The ListView shows messages in normal top-to-bottom order.
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser 
              ? const Color(0xFF2E3192).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isUser)
              const CircleAvatar(
                backgroundImage: AssetImage('assets/mascot.png'),
                radius: 15,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text,
                      style: GoogleFonts.roboto(fontSize: 16)),
                  if (_isLoading && !message.isUser)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickPrompts = [
      'Show me ancient weapons',
      'Find restrooms',
      'Explain Islamic calligraphy',
      'What is this artifact?'
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: quickPrompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(quickPrompts[index]),
              onPressed: () => _sendMessage(quickPrompts[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: _handleImageInput,
          ),
          IconButton(
            icon: const Icon(Icons.mic_outlined),
            onPressed: _handleVoiceInput,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask about exhibits...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;
    
    // Add user's message at the end.
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _textController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    // Combine the detailed context with the user's query.
    String prompt = "$detailedPrompt\n$text";

    try {
      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generation_config": {
            "maxOutputTokens": 60,
            "temperature": 0.7,
            "topP": 0.9
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Adjust extraction based on the Gemini API response structure.
        final answer = result["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "No response";
        setState(() {
          _messages.add(ChatMessage(text: answer, isUser: false));
        });
        _scrollToBottom();
      } else {
        _showError('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleImageInput() {
    // Placeholder: Implement image input functionality if needed.
    _sendMessage("Can you tell me about this exhibit?");
  }

  void _handleVoiceInput() {
    // Placeholder: Implement voice input functionality if needed.
    _sendMessage("Explain the Bedouin heritage section");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
