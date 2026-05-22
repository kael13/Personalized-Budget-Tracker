import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class OpenRouterService {
  static Future<String> _callModel(List<Map<String, dynamic>> budgets, String model) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${ApiConfig.openRouterApiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://budgetarian.app',
        'X-Title': 'Budgetarian Tracker',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': '''
              Analyze the following budget data and provide a short budget summary in Taglish (Tagalog + English).
              Focus on the total budget, top spending categories, and savings rate.
              Keep it fun, supportive, and "girly pop" ang vibes.
              Data: ${jsonEncode(budgets)}
              
              Return only the summary text. No JSON, no markdown, no lists.
            '''
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenRouter API status ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data case {'error': Map<String, dynamic> err}) {
      throw Exception('OpenRouter error (${err['code']}): ${err['message']}');
    }

    final content = data['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw Exception('Empty response from OpenRouter');
    }

    return content;
  }

  static Future<String> getRecommendations(List<Map<String, dynamic>> budgets) async {
    try {
      return await _callModel(budgets, ApiConfig.defaultModel);
    } catch (e) {
      print('Primary model failed, trying fallback: $e');
      try {
        return await _callModel(budgets, ApiConfig.fallbackModel);
      } catch (fallbackError) {
        print('Fallback model also failed: $fallbackError');
        rethrow;
      }
    }
  }
}
