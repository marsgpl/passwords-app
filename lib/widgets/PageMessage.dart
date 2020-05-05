import 'package:flutter/material.dart';

const PADDING_VERTICAL = 8.0;
const PADDING_HORIZONTAL = 35.0;

class PageMessage {
    static Widget title(String text) => Padding(
        padding: const EdgeInsets.symmetric(
            vertical: PADDING_VERTICAL,
            horizontal: PADDING_HORIZONTAL,
        ),
        child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
            ),
        ),
    );

    static Widget paragraph(String text) => Padding(
        padding: const EdgeInsets.symmetric(
            vertical: PADDING_VERTICAL,
            horizontal: PADDING_HORIZONTAL,
        ),
        child: Text(text),
    );
}
