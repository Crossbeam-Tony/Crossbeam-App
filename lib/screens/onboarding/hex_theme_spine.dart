import 'package:flutter/material.dart';
import '../../components/hex_toggle.dart';

class HexThemeSpine extends StatelessWidget {
  const HexThemeSpine({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = [
      "Classic",
      "Dark",
      "Solar",
      "Neon",
      "Retro",
      "Steel",
      "Ocean",
      "Fire",
      "Wood",
      "Desert",
      "Cyber",
      "Forest",
      "Mono",
      "Glow",
      "Camo",
      "Tech",
      "Bold",
      "Glass",
      "Smoke",
      "Stone",
    ];

    int labelIndex = 0;

    final layout = [3, 2, 3, 2, 3, 2, 3, 2];

    List<Widget> buildRows() {
      return layout.map((count) {
        final children = <Widget>[];

        for (int i = 0; i < count; i++) {
          if (labelIndex >= labels.length) break;
          children.add(HexToggle(label: labels[labelIndex++]));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Choose your starting theme",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildRows(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
