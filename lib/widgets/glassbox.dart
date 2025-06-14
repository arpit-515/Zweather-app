import 'dart:ui';
import 'package:flutter/material.dart';
final _borderRadius = BorderRadius.circular(20);

class GlassBox extends StatelessWidget {
  const GlassBox({
    required this.height,
    required this.width,
    required this.child,
    super.key,
  });

  final double height;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(),
            ),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withAlpha(51)),
                borderRadius: _borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(102),
                    Colors.white.withAlpha(25),
                  ],
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
