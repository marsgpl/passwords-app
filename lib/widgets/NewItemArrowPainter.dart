import 'package:flutter/material.dart';
import 'package:arrow_path/arrow_path.dart';

class NewItemArrowPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
        TextSpan textSpan = const TextSpan(
            text: 'Add login',
            style: const TextStyle(
                color: const Color(0xFF444444),
                fontSize: 14,
            ),
        );

        TextPainter textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr,
        );

        textPainter.layout(minWidth: size.width);
        textPainter.paint(canvas, Offset(
            -122,
            90,
        ));

        Path arrowPath = Path();

        arrowPath.moveTo(size.width - 120 + 9.0, 90 + 11.0);
        arrowPath.relativeCubicTo(
            0,
            0,
            70,
            20,
            84,
            -86,
        );

        Paint arrowPaint = Paint()
            ..color = const Color(0xFF666666)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 1;

        canvas.drawPath(ArrowPath.make(path: arrowPath), arrowPaint);
    }

    @override
    bool shouldRepaint(NewItemArrowPainter oldDelegate) => true;
}
