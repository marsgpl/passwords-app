import 'package:flutter/cupertino.dart';
import 'package:passwords/Styles@cupertino.dart';

class BasePageState<T extends StatefulWidget> extends State<T> {
    @override
    Widget build(BuildContext context) {
        return Container();
    }

    Future<void> showFeedback(String message) async {
        showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                content: Text(message,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Styles.notImportantColor,
                    ),
                ),
            ),
        );

        await Future.delayed(const Duration(milliseconds: 1000));

        Navigator.of(context, rootNavigator: true).pop('Discard');
    }
}
