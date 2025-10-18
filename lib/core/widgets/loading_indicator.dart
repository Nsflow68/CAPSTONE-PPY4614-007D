import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.2),
                  width: 4,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color ?? Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).rotate(
              duration: const Duration(seconds: 1),
            ),
          ],
        ),
      ),
    );
  }
}