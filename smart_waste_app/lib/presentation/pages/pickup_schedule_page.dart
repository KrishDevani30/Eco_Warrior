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
    await Future.delayed(const Duration(seconds: 1)); // Simulate GPS delay
    if (mounted) {
      setState(() {
        _simulatedAddress = '123 Smart City Avenue, District ${Random().nextInt(9) + 1}';
        _isFetching = false;
      });
    }
  }

  void _schedule() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }
    
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    final newRequest = PickupRequestModel(
      id: const Uuid().v4(),
      scheduledDate: _selectedDate!,
      address: _simulatedAddress,
      latitude: 0,
      longitude: 0,
      status: 'Pending',
      userId: user.id,
    );
    
    ref.read(pickupRequestsProvider.notifier).addRequest(newRequest);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pickup Request Scheduled!')));
    setState(() => _selectedDate = null);
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
        const PremiumHeader(title: 'Schedule Pickup', subtitle: 'We come to you', icon: Icons.local_shipping),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Schedule a Pickup',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on),
                          title: Text(
                              _isFetching ? 'Locating...' : _simulatedAddress),
                          trailing: TextButton(
                              onPressed: _fetchLocation, child: const Text('Refresh')),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_month),
                          title: Text(_selectedDate == null
                              ? 'Select Date & Time'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                          trailing: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            child: const Text('Pick Date'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _schedule,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50)),
                          child: const Text('CONFIRM SCHEDULE'),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Your Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: requests.isEmpty
                      ? Center(
                          child: Text('No pickup requests yet.',
                              style: TextStyle(color: Colors.grey[600])))
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final req = requests[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(Icons.local_shipping,
                                    color: colors.primary),
                                title: Text(
                                    '${req.scheduledDate.day}/${req.scheduledDate.month}/${req.scheduledDate.year}'),
                                subtitle: Text(req.address),
                                trailing: Chip(
                                  label: Text(req.status,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor: colors.primaryContainer,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
