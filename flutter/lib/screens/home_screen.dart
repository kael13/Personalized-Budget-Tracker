import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/budget_models.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BudgetAllocation> _budgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshBudgets();
  }

  Future<void> _refreshBudgets() async {
    setState(() => _isLoading = true);
    final budgets = await DatabaseHelper.instance.getBudgets();
    setState(() {
      _budgets = budgets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Bloom Budget',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              IconButton(onPressed: () {}, icon: Icon(LucideIcons.settings)),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_budgets.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.flower2, size: 80, color: Colors.pink.shade100),
                    const SizedBox(height: 16),
                    Text(
                      'No budget plans yet ✨',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start Growing Your Savings'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final budget = _budgets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BudgetCard(budget: budget),
                    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
                  },
                  childCount: _budgets.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('New Plan'),
        icon: Icon(LucideIcons.plus),
      ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  final BudgetAllocation budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          budget.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${budget.currency} ${budget.totalBudget.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.pink.shade300, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.45, // Example
                backgroundColor: Colors.pink.shade50,
                color: const Color(0xFFFF8EAD),
                minHeight: 8,
              ),
            ),
          ],
        ),
        trailing: Icon(LucideIcons.chevronRight),
        onTap: () {},
      ),
    );
  }
}
