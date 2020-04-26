import 'package:flutter/cupertino.dart';

abstract class Styles {
    static const primaryColor = const Color(0xFF0C7AFF);
    static const whiteColor = const Color(0xFFFFFFFF);
    static const blackColor = const Color(0xFF000000);
    static const redColor = const Color(0xFFFF0000);
    static const hintColor = const Color(0xFF888888);
    static const dividerColor = const Color(0xFFD9D9D9);
    static const notImportantColor = const Color(0xFF666666);
    static const hint = const TextStyle(color: hintColor);
    static const delete = const TextStyle(color: redColor);
    static const notImportantChoice = const TextStyle(color: notImportantColor);
    static const inputLabel = const TextStyle(color: notImportantColor, fontSize: 14);
}
