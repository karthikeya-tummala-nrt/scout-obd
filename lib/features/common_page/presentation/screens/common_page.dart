import 'package:flutter/material.dart';

import '../widgets/hud_sidebar.dart';

class CommonPage extends StatefulWidget {
  const CommonPage({super.key});

  @override
  State<CommonPage> createState() => _CommonPageState();
}

class _CommonPageState extends State<CommonPage> {
  int _selectedIndex = 0;

  static const _items = <String>[
    'SYSTEM',
    'DRIVE',
    'POWER',
    'COMPUTE',
    'SENSOR',
    'COM',
    'ALERTS',
    'PAYLOAD',
  ];

  @override
  Widget build(BuildContext context) {
    final clampedIndex = _selectedIndex.clamp(0, _items.length - 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(
            index: clampedIndex,
            children: [
              // Placeholder screens; add real screen content later.
              for (final _ in _items) const SizedBox.expand(),

              // Screen-name placeholders (disabled for now):
              // for (final name in _items)
              //   Center(
              //     child: Text(
              //       name,
              //       style: const TextStyle(
              //         fontSize: 28,
              //         letterSpacing: 2.0,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white70,
              //       ),
              //     ),
              //   ),
            ],
          ),
          HudSidebar(
            items: _items,
            selectedIndex: clampedIndex,
            onSelect: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
        ],
      ),
    );
  }
}
