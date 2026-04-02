import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/app_state_provider.dart';
import 'data/repositories/local_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await Hive.initFlutter();
  await ThemeNotifier.init(); // Initialize settings box
  final repo = LocalRepository();
  await repo.init();
  
  runApp(ProviderScope(
    overrides: [
      localRepositoryProvider.overrideWithValue(repo),
    ],
    child: const SmartWasteApp(),
  ));
}

class SmartWasteApp extends ConsumerWidget {
  const SmartWasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'EcoSmart Waste',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
