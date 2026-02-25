import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CalibrationDialog extends StatelessWidget {
  final VoidCallback onDone;

  const CalibrationDialog({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CalibrationAnimation(),
            const SizedBox(height: 24),
            const Text(
              "للمعايرة، قم بتحريك هاتفك على شكل الرقم 8",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onDone();
                },
                child: const Text(
                  "معايـرة",
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalibrationAnimation extends StatefulWidget {
  const CalibrationAnimation({super.key});

  @override
  State<CalibrationAnimation> createState() => _CalibrationAnimationState();
}

class _CalibrationAnimationState extends State<CalibrationAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/Infinity Loader.json',
      controller: _controller,
      frameRate: FrameRate.max,
      height: 180,
      width: 180,
    );
  }
}
