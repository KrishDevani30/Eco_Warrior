import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../../data/models/pickup_request_model.dart';
import '../widgets/premium_header.dart';
import '../providers/app_state_provider.dart';

class PickupSchedulePage extends ConsumerStatefulWidget {
  const PickupSchedulePage({super.key});

  @override
  ConsumerState<PickupSchedulePage> createState() => _PickupSchedulePageState();
}

class _PickupSchedulePageState extends ConsumerState<PickupSchedulePage> {
  DateTime? _selectedDate;
  String _simulatedAddress = 'Fetching GPS location...';
  bool _isFetching = false;

  void _fetchLocation() async {
    setState(() => _isFetching = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _simulatedAddress = 'Sector ${Random().nextInt(15) + 1}, College Road, Nadiad, Gujarat';
        _isFetching = false;
      });
    }
  }

  Future<void> _schedule() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first!'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User session not found. Please log in again.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    try {
      final newRequest = PickupRequestModel(
        id: const Uuid().v4(),
        scheduledDate: _selectedDate!,
        address: _simulatedAddress,
        latitude: 0,
        longitude: 0,
        status: 'Scheduled',
        userId: user.id,
      );
      
      await ref.read(pickupRequestsProvider.notifier).addRequest(newRequest);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pickup Scheduled Successfully!'), backgroundColor: Colors.green),
        );
        setState(() => _selectedDate = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled': return Colors.blue;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final requests = ref.watch(pickupRequestsProvider);
    
    return CustomScrollView(
      slivers: [
        const PremiumHeader(title: 'Schedule Pickup', subtitle: 'Hassle-free recycling', icon: Icons.local_shipping),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request a Pickup',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                            child: Icon(Icons.location_on, color: colors.onPrimaryContainer, size: 20),
                          ),
                          title: Text(_isFetching ? 'Locating...' : _simulatedAddress, style: const TextStyle(fontSize: 14)),
                          trailing: TextButton(onPressed: _fetchLocation, child: const Text('Refresh')),
                        ),
                        const Divider(height: 32),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: colors.secondaryContainer, shape: BoxShape.circle),
                            child: Icon(Icons.calendar_month, color: colors.onSecondaryContainer, size: 20),
                          ),
                          title: Text(_selectedDate == null ? 'Select Date' : _formatDate(_selectedDate!), 
                                      style: TextStyle(fontSize: 15, fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold)),
                          trailing: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date != null) setState(() => _selectedDate = date);
                            },
                            child: const Text('Pick Date'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _schedule,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: const Text('CONFIRM SCHEDULE', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    if (requests.isNotEmpty) Text('${requests.length} Total', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (requests.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No pickups scheduled yet', 
                    style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final req = requests[index];
                  final statusColor = _getStatusColor(req.status);
                  
                  return Dismissible(
                    key: Key(req.id), // Unique ID safety
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      ref.read(pickupRequestsProvider.notifier).deleteRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request removed.')));
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.1),
                            child: Icon(Icons.local_shipping, color: statusColor),
                          ),
                          title: Text(_formatDate(req.scheduledDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(req.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(req.status, 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                              if (req.status != 'Completed')
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.only(top: 4),
                                  icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                  onPressed: () {
                                    ref.read(pickupRequestsProvider.notifier).updateStatus(req.id, 'Completed');
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Completed!')));
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: requests.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }


}
