import 'package:flutter/material.dart';
import 'package:startlink/features/compass/presentation/widgets/innovation_compass_widget.dart';

class CompassPage extends StatelessWidget {
  const CompassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Innovation Compass')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: InnovationCompassWidget(),
      ),
    );
  }
}
