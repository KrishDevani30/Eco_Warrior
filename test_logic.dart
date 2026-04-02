import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'lib/data/models/waste_log_model.dart';
import 'lib/data/models/pickup_request_model.dart';
import 'lib/data/repositories/local_repository.dart';
import 'lib/presentation/providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('test_hive');
  
  final repo = LocalRepository();
  await repo.init();

  final container = ProviderContainer(
    overrides: [
      localRepositoryProvider.overrideWithValue(repo),
    ],
  );

  print("Initial waste logs length: \${container.read(wasteLogsProvider).length}");

  final newLog = WasteLogModel(
    id: const Uuid().v4(),
    category: 'Plastic',
    quantity: 2.0,
    date: DateTime.now(),
    isSynced: false,
  );
  
  await container.read(wasteLogsProvider.notifier).addLog(newLog);

  print("Length after adding: \${container.read(wasteLogsProvider).length}");
}
