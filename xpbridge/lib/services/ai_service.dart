import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/student_profile.dart';

class AiService {
  static String? _apiKey;
  static List<Map<String, dynamic>> _chatHistory = [];

  static const String _systemPrompt = '''
You are a friendly and helpful career advisor for students on XpBridge, a platform that connects students with startup internship opportunities.

Your role is to:
1. Have a natural conversation to understand the student's background
2. Learn about their education, skills, interests, and career goals
3. When you have enough information, recommend suitable job roles

Guidelines:
- Be conversational and encouraging
- Ask follow-up questions to understand them better
- Consider their skills, education level, and interests
- Suggest 3-5 specific job roles that would be a good fit
- Explain WHY each role suits them

When you're ready to give recommendations, format them clearly like:
"Based on our conversation, here are roles that would suit you:

1. **[Role Title]** - [Brief explanation of why this fits]
2. **[Role Title]** - [Brief explanation of why this fits]
..."

Also extract and remember:
- Skills mentioned (technical and soft skills)
- Education level and field
- Interests and preferred industries
- Hours available per week

Keep responses concise but helpful. Don't be overly formal.
''';

  static Future<void> initialize() async {
    _apiKey = dotenv.env['GEMINI_API_KEY'];
    if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'your_api_key_here') {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _chatHistory = [];
  }

  static Future<String> sendMessage(String message) async {
    if (_apiKey == null) {
      await initialize();
    }

    // Debug: If message is "list models", show available models
    if (message.toLowerCase() == 'list models') {
      return await listModels();
    }

    // Add user message to history
    _chatHistory.add({
      'role': 'user',
      'parts': [{'text': message}]
    });

    try {
      final response = await _callGeminiApi();
      return response;
    } catch (e) {
      // Remove failed message from history
      _chatHistory.removeLast();
      return 'Error: $e';
    }
  }

  static Future<String> sendMessageWithContext(
    String message,
    StudentProfile? profile,
  ) async {
    if (_apiKey == null) {
      await initialize();
    }

    String fullMessage = message;

    // If this is the first message and we have profile data, include it
    if (_chatHistory.isEmpty && profile != null) {
      fullMessage = '''
[Student Profile Context - Use this to personalize your advice]
Name: ${profile.name}
Education: ${profile.education ?? 'Not specified'}
Current Skills: ${profile.skills.join(', ')}
Bio: ${profile.bio ?? 'Not specified'}
Available Hours: ${profile.availabilityHours} hrs/week

Now respond to their message: $message
''';
    }

    // Add user message to history
    _chatHistory.add({
      'role': 'user',
      'parts': [{'text': fullMessage}]
    });

    try {
      final response = await _callGeminiApi();
      return response;
    } catch (e) {
      // Remove failed message from history
      _chatHistory.removeLast();
      return 'Error: $e';
    }
  }

  static Future<String> listModels() async {
    if (_apiKey == null) {
      await initialize();
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey'
    );

    final response = await http.get(url);
    return response.body;
  }

  static Future<String> _callGeminiApi() async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'
    );

    // Prepend system prompt to chat history for context
    final contents = <Map<String, dynamic>>[];

    // Add system context as first user message if this is the start
    if (_chatHistory.length == 1) {
      contents.add({
        'role': 'user',
        'parts': [{'text': '$_systemPrompt\n\n${_chatHistory.first['parts'][0]['text']}'}]
      });
    } else {
      contents.addAll(_chatHistory);
    }

    final body = {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
          'Sorry, I could not generate a response.';

      // Add assistant response to history
      _chatHistory.add({
        'role': 'model',
        'parts': [{'text': text}]
      });

      return text;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? 'API request failed: ${response.statusCode}');
    }
  }

  static void resetChat() {
    _chatHistory = [];
  }

  static List<String> extractRecommendedRoles(String response) {
    final List<String> roles = [];
    final lines = response.split('\n');

    for (final line in lines) {
      final match = RegExp(r'\*\*([^*]+)\*\*').firstMatch(line);
      if (match != null) {
        roles.add(match.group(1)!.trim());
      }
    }

    return roles;
  }
}
