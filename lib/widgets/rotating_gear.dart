import 'package:flutter/material.dart';
import 'settings_dialog.dart';

class RotatingGear extends StatefulWidget {
  const RotatingGear({super.key});

  @override
  State<RotatingGear> createState() => _RotatingGearState();
}

class _RotatingGearState extends State<RotatingGear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(Icons.settings),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const SettingsDialog(),
        );
      },
    );
  }
}
