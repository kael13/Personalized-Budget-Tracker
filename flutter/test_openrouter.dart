import 'dart:convert';
import 'package:budgetarian/services/openrouter_service.dart';

void main() async {
  print('🔄 Testing OpenRouter LLM connection...\n');

  final testBudgets = [
    {
      'name': 'Monthly Budget',
      'totalBudget': 15000.0,
      'currency': 'PHP',
      'daysToConsume': 30,
      'categories': [
        {
          'name': 'Food',
          'allocatedAmount': 6000.0,
          'spentAmount': 3200.0,
          'subCategories': [
            {'name': 'Groceries', 'allocatedAmount': 4000.0, 'spentAmount': 2000.0},
            {'name': 'Dining Out', 'allocatedAmount': 2000.0, 'spentAmount': 1200.0},
          ],
        },
        {
          'name': 'Transport',
          'allocatedAmount': 3000.0,
          'spentAmount': 1500.0,
          'subCategories': [
            {'name': 'Gas', 'allocatedAmount': 2000.0, 'spentAmount': 1000.0},
            {'name': 'Parking', 'allocatedAmount': 1000.0, 'spentAmount': 500.0},
          ],
        },
        {
          'name': 'Savings',
          'allocatedAmount': 2000.0,
          'spentAmount': 500.0,
          'subCategories': [
            {'name': 'Emergency Fund', 'allocatedAmount': 1500.0, 'spentAmount': 500.0},
          ],
        },
      ],
    },
  ];

  try {
    final content = await OpenRouterService.getRecommendations(testBudgets);
    print('✅ API call succeeded!\n');
    print('📝 Raw response:');
    print(content);
    print('');

    final cleaned = content.replaceAll(RegExp(r'```json|```'), '').trim();
    final decoded = jsonDecode(cleaned) as List;
    print('✅ Valid JSON array with ${decoded.length} recommendations:');
    for (int i = 0; i < decoded.length; i++) {
      print('  ${i + 1}. ${decoded[i]}');
    }
  } catch (e) {
    print('❌ API call failed: $e');
  }
}
