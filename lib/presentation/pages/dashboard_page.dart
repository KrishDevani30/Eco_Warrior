import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final logs = ref.watch(wasteLogsProvider);
    final points = ref.watch(userPointsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hello, Eco Warrior! 🌱', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Chip(
                label: Text('$points pt', style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: colors.primaryContainer,
                avatar: const Icon(Icons.star, size: 16, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SummaryCard(logsCount: logs.length),
          const SizedBox(height: 32),
          Text('Recent Activity', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No waste logged yet.', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length > 5 ? 5 : logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.secondaryContainer,
                    child: Icon(_getIconForCategory(log.category)),
                  ),
                  title: Text(log.category),
                  subtitle: Text('${log.date.day}/${log.date.month}/${log.date.year}'),
                  trailing: Text('${log.quantity} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    if (category.toLowerCase().contains('plastic')) return Icons.local_drink;
    if (category.toLowerCase().contains('organic')) return Icons.eco;
    if (category.toLowerCase().contains('e-waste')) return Icons.computer;
    return Icons.delete;
  }
}

class _SummaryCard extends StatelessWidget {
  final int logsCount;
  const _SummaryCard({required this.logsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Total Logs', value: logsCount.toString()),
          const _Stat(label: 'Recycled', value: '45%'),
          const _Stat(label: 'Impact', value: 'High'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }
}
