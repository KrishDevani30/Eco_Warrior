import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(userPointsProvider);
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.deepOrange.shade600]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.star_rounded, size: 64, color: Colors.white),
                const SizedBox(height: 8),
                Text('$points', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Total Eco Points', style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Rewards Catalog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _RewardItem(title: 'Bus Pass Discount', pointsRequired: 500, icon: Icons.directions_bus),
                _RewardItem(title: 'Grocery Voucher', pointsRequired: 1000, icon: Icons.local_grocery_store),
                _RewardItem(title: 'Free Parking', pointsRequired: 750, icon: Icons.local_parking),
                _RewardItem(title: 'Tree Donation', pointsRequired: 200, icon: Icons.park),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String title;
  final int pointsRequired;
  final IconData icon;

  const _RewardItem({required this.title, required this.pointsRequired, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Chip(
              label: Text('$pointsRequired pt', style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.orange.shade100,
            ),
          ],
        ),
      ),
    );
  }
}
