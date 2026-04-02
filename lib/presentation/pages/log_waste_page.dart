import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../widgets/premium_header.dart';
import '../../data/models/waste_log_model.dart';
import '../providers/app_state_provider.dart';

class LogWastePage extends ConsumerStatefulWidget {
  const LogWastePage({super.key});

  @override
  ConsumerState<LogWastePage> createState() => _LogWastePageState();
}

class _LogWastePageState extends ConsumerState<LogWastePage> {
  String _selectedCategory = 'Organic';
  double _quantity = 1.0;
  final _categories = ['Organic', 'Plastic', 'E-Waste', 'Glass', 'Paper'];

  void _submit() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    final newLog = WasteLogModel(
      id: const Uuid().v4(),
      category: _selectedCategory,
      quantity: _quantity,
      date: DateTime.now(),
      isSynced: false,
      userId: user.id,
    );
    ref.read(wasteLogsProvider.notifier).addLog(newLog);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Waste successfully logged! Points earned! 🚀')),
    );
    
    setState(() {
      _quantity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const PremiumHeader(title: 'Log Waste', subtitle: 'Every item counts', icon: Icons.recycling),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Select Waste Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final isSelected = c == _selectedCategory;
                    return ChoiceChip(
                      label: Text(c),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = c);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                const Text('Estimated Quantity (kg)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() =>
                          _quantity = (_quantity > 0.5) ? _quantity - 0.5 : 0.5),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Expanded(
                      child: Slider(
                        value: _quantity,
                        min: 0.5,
                        max: 20.0,
                        divisions: 39,
                        label: '$_quantity kg',
                        onChanged: (val) => setState(() => _quantity = val),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity += 0.5),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    '${_quantity.toStringAsFixed(1)} kg',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.primary),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Add Photo (Optional)'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('LOG WASTE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
