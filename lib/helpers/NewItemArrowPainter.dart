import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';

class NewItemArrowPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
        Path path;

        Paint paint = Paint()
            ..color = const Color(0xFFDDDDDD)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 2.0;

        path = Path();
        path.moveTo(110, size.height - 40);
        path.relativeCubicTo(
            0,
            0,
            size.width * .5,
            -size.height * .3,
            size.width - 24 - 110,
            -size.height + 15 + 40,
        );
        path = ArrowPath.make(path: path);
        canvas.drawPath(path, paint);
    }

    @override
    bool shouldRepaint(NewItemArrowPainter oldDelegate) => true;
}
