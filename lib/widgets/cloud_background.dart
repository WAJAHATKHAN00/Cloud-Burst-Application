import 'package:flutter/material.dart';

class CloudBackground extends StatelessWidget {
  final Widget child;
  const CloudBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withOpacity(0.18),
            Colors.white,
            cs.primary.withOpacity(0.06),
          ],
        ),
      ),
      child: child,
    );
  }
}
