import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/premium_header.dart';
import '../../../data/models/waste_log_model.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRequests = ref.watch(allPickupRequestsProvider);
    final allLogs = ref.watch(allWasteLogsProvider);
    final colors = Theme.of(context).colorScheme;

    // Filter requests by workflow stage
    final pendingRequests = allRequests.where((r) => r.status == 'Scheduled').toList();
    final activeRequests = allRequests.where((r) => r.status == 'Approved').toList();
    final historyRequests = allRequests.where((r) => r.status == 'Completed' || r.status == 'Denied' || r.status == 'Rejected').toList();

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(ref.watch(themeProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onPressed: () => ref.read(currentUserProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
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
                  _buildSectionTitle('Pending Approval (${pendingRequests.length})'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          pendingRequests.isEmpty
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No pending approvals.'))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AdminRequestCard(req: pendingRequests[index], type: 'approval'),
                    childCount: pendingRequests.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSectionTitle('Active Pickups (${activeRequests.length})'),
            ),
          ),
          activeRequests.isEmpty
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No active pickups.'))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AdminRequestCard(req: activeRequests[index], type: 'completion'),
                    childCount: activeRequests.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSectionTitle('History'),
            ),
          ),
          historyRequests.isEmpty
              ? const SliverToBoxAdapter(child: SizedBox())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AdminRequestCard(req: historyRequests[index], type: 'history'),
                    childCount: historyRequests.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSectionTitle('Recent Waste Logs (All Users)'),
            ),
          ),
          allLogs.isEmpty
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No logs found.'))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = allLogs[allLogs.length - 1 - index]; // Show newest first
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(Icons.history, color: Colors.grey[400]),
                          title: Text('${log.category} - ${log.quantity}kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('User: ${log.userId.substring(0, 8)}... | ${log.pickupStatus}'),
                          trailing: Text('${log.date.day}/${log.date.month}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      );
                    },
                    childCount: allLogs.length > 10 ? 10 : allLogs.length, // Show last 10
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
  final String type; // 'approval', 'completion', 'history'

  const _AdminRequestCard({required this.req, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final allLogs = ref.watch(allWasteLogsProvider);
    
    // Find linked waste log
    final linkedLog = allLogs.where((l) => l.id == req.wasteLogId).firstOrNull;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colors.outlineVariant.withOpacity(0.5))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: colors.primary.withOpacity(0.1),
                child: const Icon(Icons.person_outline, size: 20),
              ),
              title: Text('User ID: ${req.userId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${req.id.substring(0, 8)}...'),
              trailing: _getStatusChip(req.status),
            ),
            const Divider(),
            if (linkedLog != null) ...[
              const Text('Waste Details:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                   _DetailItem(icon: Icons.category, label: linkedLog.category),
                   const SizedBox(width: 16),
                   _DetailItem(icon: Icons.scale, label: '${linkedLog.quantity} kg'),
                ],
              ),
              const SizedBox(height: 8),
              _DetailItem(icon: Icons.location_on, label: req.address),
              const SizedBox(height: 12),
            ] else 
              Text('Address: ${req.address}', style: const TextStyle(fontSize: 13)),
            
            if (type == 'approval')
               Row(
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: () => _updateStatus(ref, req.id, 'Approved'),
                      child: const Text('APPROVE'),
                    ),
                  ),
                ],
              )
            else if (type == 'completion')
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () => _updateStatus(ref, req.id, 'Completed'),
                    label: const Text('MARK AS COMPLETED'),
                  ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Approved') color = Colors.blue;
    if (status == 'Completed') color = Colors.green;
    if (status == 'Denied' || status == 'Rejected') color = Colors.red;
    if (status == 'Scheduled') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _updateStatus(WidgetRef ref, String id, String status) {
    ref.read(pickupRequestsProvider.notifier).updateStatus(id, status);
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: const TextStyle(fontSize: 13))),
      ],
    );
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
