import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_display/core/providers.dart';
import '../widgets/hud_sidebar.dart';

class CommonPage extends ConsumerStatefulWidget {
  const CommonPage({super.key});

  @override
  ConsumerState<CommonPage> createState() => _CommonPageState();
}

class _CommonPageState extends ConsumerState<CommonPage> {
  int _selectedIndex = 0;

  static const _items = <String>[
    'SYSTEM', 'DRIVE', 'POWER', 'COMPUTE', 'SENSOR', 'COM', 'ALERTS', 'PAYLOAD',
  ];

  @override
  Widget build(BuildContext context) {
    final transport = ref.watch(transportProvider);
    final timeSync = ref.watch(timeSyncRepoProvider);

    return timeSync.when(
      data: (_) => _buildMainUI(),
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent)),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              Text('Startup failed: $err', style: const TextStyle(color: Colors.white)),
              ElevatedButton(
                onPressed: () => ref.invalidate(timeSyncRepoProvider),  // Retry
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainUI() {  // Extracted original UI
    final clampedIndex = _selectedIndex.clamp(0, _items.length - 1);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(
            index: clampedIndex,
            children: [for (final _ in _items) const SizedBox.expand()],
          ),
          HudSidebar(
            items: _items,
            selectedIndex: clampedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),
    );
  }
}