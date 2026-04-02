import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/premium_header.dart';
import '../../../data/models/waste_log_model.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRequests = ref.watch(allPickupRequestsProvider);
    final allLogs = ref.watch(allWasteLogsProvider);
    final colors = Theme.of(context).colorScheme;

    // Filter pending requests for approval
    final pendingRequests = allRequests.where((r) => r.status == 'Scheduled').toList();
    final otherRequests = allRequests.where((r) => r.status != 'Scheduled').toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const PremiumHeader(
            title: 'Admin Analytics',
            subtitle: 'System-wide overview',
            icon: Icons.admin_panel_settings,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalStats(allRequests.length, allLogs.length),
                  const SizedBox(height: 24),
                  const Text('Global Waste Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildGlobalChart(allLogs),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Pending Approvals (${pendingRequests.length})'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          pendingRequests.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No pending requests.'))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final req = pendingRequests[index];
                      return _AdminRequestCard(req: req, isAdminAction: true);
                    },
                    childCount: pendingRequests.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSectionTitle('Request History'),
            ),
          ),
          otherRequests.isEmpty
              ? const SliverToBoxAdapter(child: SizedBox())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final req = otherRequests[index];
                      return _AdminRequestCard(req: req, isAdminAction: false);
                    },
                    childCount: otherRequests.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildGlobalChart(List<WasteLogModel> logs) {
    if (logs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No global waste data yet'))));
    
    final Map<String, double> categoryCounts = {};
    for (var log in logs) {
      categoryCounts[log.category] = (categoryCounts[log.category] ?? 0) + 1;
    }

    final List<PieChartSectionData> sections = [];
    final categories = categoryCounts.keys.toList();
    final List<Color> colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.red];

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      sections.add(PieChartSectionData(
        value: categoryCounts[cat],
        title: cat,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        color: colors[i % colors.length],
      ));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalStats(int totalPickups, int totalLogs) {
    return Row(
      children: [
        _StatCard(title: 'Tot. Pickups', value: '$totalPickups', icon: Icons.local_shipping, color: Colors.blue),
        const SizedBox(width: 12),
        _StatCard(title: 'Global Logs', value: '$totalLogs', icon: Icons.analytics, color: Colors.green),
      ],
    );
  }
}

class _AdminRequestCard extends ConsumerWidget {
  final dynamic req;
  final bool isAdminAction;

  const _AdminRequestCard({required this.req, required this.isAdminAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.primary.withOpacity(0.1),
              child: const Icon(Icons.email_outlined, size: 20),
            ),
            title: Text('User ID: ${req.userId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${req.address}\nDate: ${req.scheduledDate.toString().split(' ')[0]}'),
            isThreeLine: true,
          ),
          if (isAdminAction)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => _updateStatus(ref, req.id, 'Denied'),
                      child: const Text('DENY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () => _updateStatus(ref, req.id, 'Approved'),
                      child: const Text('APPROVE'),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text('Status: ${req.status}', 
                style: TextStyle(fontWeight: FontWeight.bold, color: req.status == 'Approved' ? Colors.green : Colors.red)),
            ),
        ],
      ),
    );
  }

  void _updateStatus(WidgetRef ref, String id, String status) {
    ref.read(pickupRequestsProvider.notifier).updateStatus(id, status);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
