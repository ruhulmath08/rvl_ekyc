import 'package:flutter/material.dart';

class DocumentGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Bangladesh NID aspect ratio
    const double aspectRatio = 85.6 / 53.98;

    // Guide width (screen width এর 90%)
    final double guideWidth = size.width * 0.9;
    final double guideHeight = guideWidth / aspectRatio;

    final double left = (size.width - guideWidth) / 2;
    final double top = (size.height - guideHeight) / 2;

    final Rect rect = Rect.fromLTWH(
      left,
      top,
      guideWidth,
      guideHeight,
    );

    // Draw rounded rectangle
    final RRect rRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(16),
    );

    canvas.drawRRect(rRect, paint);

    // Corner highlight
    final cornerPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 25;

    // Top-left corner
    canvas.drawLine(
        Offset(left, top),
        Offset(left + cornerLength, top),
        cornerPaint);
    canvas.drawLine(
        Offset(left, top),
        Offset(left, top + cornerLength),
        cornerPaint);

    // Top-right
    canvas.drawLine(
        Offset(left + guideWidth, top),
        Offset(left + guideWidth - cornerLength, top),
        cornerPaint);
    canvas.drawLine(
        Offset(left + guideWidth, top),
        Offset(left + guideWidth, top + cornerLength),
        cornerPaint);

    // Bottom-left
    canvas.drawLine(
        Offset(left, top + guideHeight),
        Offset(left + cornerLength, top + guideHeight),
        cornerPaint);
    canvas.drawLine(
        Offset(left, top + guideHeight),
        Offset(left, top + guideHeight - cornerLength),
        cornerPaint);

    // Bottom-right
    canvas.drawLine(
        Offset(left + guideWidth, top + guideHeight),
        Offset(left + guideWidth - cornerLength, top + guideHeight),
        cornerPaint);
    canvas.drawLine(
        Offset(left + guideWidth, top + guideHeight),
        Offset(left + guideWidth, top + guideHeight - cornerLength),
        cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}