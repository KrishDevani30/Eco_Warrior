import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import '../../data/models/waste_log_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final logs = ref.watch(wasteLogsProvider);
    final points = ref.watch(userPointsProvider);
    final pickups = ref.watch(pickupRequestsProvider);
    
    // Calculate stats
    double totalWeight = 0;
    for (var log in logs) {
      totalWeight += log.quantity;
    }

    // Calculate streak
    int streak = 0;
    final uniqueDates = logs.map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toSet().toList();
    uniqueDates.sort((a, b) => b.compareTo(a));
    
    if (uniqueDates.isNotEmpty) {
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final firstDiff = today.difference(uniqueDates.first).inDays;
      if (firstDiff == 0 || firstDiff == 1) {
        streak = 1;
        for (int i = 0; i < uniqueDates.length - 1; i++) {
          if (uniqueDates[i].difference(uniqueDates[i+1]).inDays == 1) {
            streak++;
          } else {
            break;
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: colors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, Eco Warrior!',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ready to save the planet? 🌱',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(ref.watch(themeProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                                  onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                                  onPressed: () => ref.read(currentUserProvider.notifier).logout(),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person, color: Colors.grey),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Floating Stats Card
                    _PremiumSummaryCard(
                      logsCount: logs.length,
                      totalWeight: totalWeight,
                      points: points,
                    ),
                    const SizedBox(height: 32),
                    
                    // Quick Action Row
                    Text(
                      'Quick Insights',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _QuickActionCard(icon: Icons.local_shipping, label: '${pickups.length} Req', subLabel: 'Pickups', color: Colors.blue),
                        _QuickActionCard(icon: Icons.eco, label: '${logs.where((l) => l.category == 'Organic').length} Logs', subLabel: 'Organic', color: Colors.green),
                        _QuickActionCard(icon: Icons.local_fire_department, label: '$streak Day', subLabel: 'Streak!', color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Recent Activity',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (logs.isEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.auto_awesome, size: 64, color: colors.primary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'A fresh start! Log some waste.',
                                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final catData = _getCategoryData(log.category);
                          final statusColor = _getStatusColor(log.pickupStatus);
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: catData.color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(catData.icon, color: catData.color),
                                  ),
                                  title: Text(
                                    log.category,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${log.date.day}/${log.date.month}/${log.date.year}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          log.pickupStatus,
                                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${log.quantity} kg',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                if (log.pickupStatus == 'Not Requested')
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showRequestDialog(context, ref, log),
                                        icon: const Icon(Icons.local_shipping, size: 16),
                                        label: const Text('Request Pickup'),
                                        style: OutlinedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Requested': return Colors.orange;
      case 'Approved': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showRequestDialog(BuildContext context, WidgetRef ref, WasteLogModel log) {
    final controller = TextEditingController(text: log.location);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Pickup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Confirm your pickup address:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(wasteLogsProvider.notifier).requestPickupFromLog(log, controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pickup requested successfully! 🚛')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  _CategoryData _getCategoryData(String category) {
    var lower = category.toLowerCase();
    if (lower.contains('plastic')) return _CategoryData(Icons.local_drink, Colors.blue);
    if (lower.contains('organic')) return _CategoryData(Icons.eco, Colors.green);
    if (lower.contains('e-waste')) return _CategoryData(Icons.computer, Colors.redAccent);
    if (lower.contains('glass')) return _CategoryData(Icons.wine_bar, Colors.purple);
    return _CategoryData(Icons.delete, Colors.grey);
  }
}

class _CategoryData {
  final IconData icon;
  final Color color;
  _CategoryData(this.icon, this.color);
}

class _PremiumSummaryCard extends StatelessWidget {
  final int logsCount;
  final double totalWeight;
  final int points;

  const _PremiumSummaryCard({
    required this.logsCount,
    required this.totalWeight,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.assignment_turned_in,
                  iconColor: Colors.blueAccent,
                  value: logsCount.toString(),
                  label: 'Total Logs',
                ),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _StatItem(
                  icon: Icons.scale,
                  iconColor: Colors.green,
                  value: '${totalWeight.toStringAsFixed(1)} kg',
                  label: 'Recycled',
                ),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _StatItem(
                  icon: Icons.star_rounded,
                  iconColor: Colors.orange,
                  value: points.toString(),
                  label: 'Eco Points',
                  subLabel: 'On Complete',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? subLabel;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        if (subLabel != null)
           Text(
             subLabel!,
             style: TextStyle(fontSize: 9, color: Colors.grey[400]),
           ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8), fontSize: 14),
              textAlign: TextAlign.center, // Make sure label stays centered and bound properly
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
