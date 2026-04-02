import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/premium_header.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final logs = ref.watch(wasteLogsProvider);
    final totalWeight = logs.fold(0.0, (sum, item) => sum + item.quantity);
    
    if (user == null) return const Scaffold(body: Center(child: Text('Please Log In')));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const PremiumHeader(
            title: 'Your Profile',
            subtitle: 'Manage your eco-journey',
            icon: Icons.person,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Info'),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(user.email),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.edit_outlined),
                            title: const Text('Name'),
                            subtitle: Text(user.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _showNameDialog(context, ref, user.name),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Preferences'),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      secondary: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                      title: const Text('Dark Mode'),
                      subtitle: Text(themeMode == ThemeMode.dark ? 'Enabled' : 'Disabled'),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Eco Achievements'),
                  const SizedBox(height: 12),
                  _buildAchievementGrid(logs.length, totalWeight),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => ref.read(currentUserProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAchievementGrid(int logsCount, double weight) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _AchievementCard(
          title: 'First Recycle',
          icon: Icons.celebration,
          isUnlocked: logsCount >= 1,
          color: Colors.orange,
        ),
        _AchievementCard(
          title: 'Eco Warrior',
          icon: Icons.shield,
          isUnlocked: logsCount >= 10,
          color: Colors.blue,
        ),
        _AchievementCard(
          title: 'Heavy Lifter',
          icon: Icons.fitness_center,
          isUnlocked: weight >= 50,
          color: Colors.purple,
        ),
        _AchievementCard(
          title: 'Green Legend',
          icon: Icons.auto_awesome,
          isUnlocked: logsCount >= 25,
          color: Colors.green,
        ),
      ],
    );
  }

  void _showNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(currentUserProvider.notifier).updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  const _AchievementCard({
    required this.title,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isUnlocked ? null : Colors.grey.withOpacity(0.1),
      child: Opacity(
        opacity: isUnlocked ? 1 : 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isUnlocked ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            if (isUnlocked) 
              const Icon(Icons.check_circle, size: 14, color: Colors.green)
            else
              const Text('Locked', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
