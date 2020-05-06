import 'package:flutter/foundation.dart';
import 'dart:async';

class Debouncer {
    int milliseconds;
    VoidCallback action;
    Timer timer;

    Debouncer({
        this.milliseconds = 100,
    });

    run(VoidCallback action) {
        if (timer != null) {
            timer.cancel();
        }

        timer = Timer(Duration(milliseconds: milliseconds), action);
    }
}
