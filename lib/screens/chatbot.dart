import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final String _apiKey = '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';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': 'Hello! This is Educational Chatbot. How can I assist you today?',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final userMessage = _messageController.text.trim();
      
      setState(() {
        _messages.add({
          'text': userMessage,
          'isUser': true,
          'timestamp': DateTime.now(),
        });
        _isLoading = true;
      });
      
      _messageController.clear();
      
      try {
        final response = await _getOpenRouterResponse(userMessage);
        setState(() {
          _messages.add({
            'text': response,
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _messages.add({
            'text': 'Sorry, I encountered an error. Please try again.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getOpenRouterResponse(String message) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'amazon/nova-2-lite-v1:free',
        'messages': [
          {
            'role': 'user',
            'content': message,
          }
        ],
        'reasoning': {
          'enabled': true
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chatbot'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Thinking...'),
                        ],
                      ),
                    ),
                  );
                }
                final message = _messages[index];
                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message['isUser']
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isUser']
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  color: _isLoading ? Colors.grey : Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}