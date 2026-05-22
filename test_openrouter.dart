import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'YOUR_OPENROUTER_API_KEY';

  print('🔍 Checking API key validity and available models...\n');

  // First check if the key is valid
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);

  try {
    final request = await client.getUrl(Uri.parse('https://openrouter.ai/api/v1/auth/key'));
    request.headers.set('Authorization', 'Bearer $apiKey');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      print('✅ API key is valid');
      print('   Key: ${data['data']['key']}');
      print('   Limit: ${data['data']['limit']}');
      print('   Usage: ${data['data']['usage']}');
      print('');
    } else {
      print('❌ Invalid API key: ${response.statusCode} $body');
      client.close();
      return;
    }
  } catch (e) {
    print('❌ Connection error: $e');
    client.close();
    return;
  }

  // List available free models
  try {
    final request = await client.getUrl(Uri.parse('https://openrouter.ai/api/v1/models'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final models = data['data'] as List;

      print('📋 Available free models:');
      for (final m in models) {
        final id = m['id'] as String;
        final pricing = m['pricing'] as Map<String, dynamic>?;
        final isFree = pricing?['prompt'] == 0 && pricing?['completion'] == 0;
        if (isFree || id.contains('free')) {
          print('   • $id');
        }
      }

      // Try a quick test with any available model
      print('\n🔍 Searching for a working model...');
      for (final m in models) {
        final id = m['id'] as String;
        if (!id.contains('free')) continue;

        print('   Testing $id...');
        final result = await _quickTest(apiKey, id);
        if (result) {
          print('   ✅ $id works!');
          break;
        }
        print('   ❌ $id failed');
      }
    }
  } catch (e) {
    print('❌ Failed to list models: $e');
  }

  client.close();
}

Future<bool> _quickTest(String apiKey, String model) async {
  final body = jsonEncode({
    'model': model,
    'messages': [
      {
        'role': 'user',
        'content': 'Say "hello" in one word.'
      }
    ]
  });

  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    final request = await client.postUrl(Uri.parse('https://openrouter.ai/api/v1/chat/completions'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $apiKey');
    request.headers.set('HTTP-Referer', 'https://budgetarian.app');
    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    client.close();
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
