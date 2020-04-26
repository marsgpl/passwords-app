import 'package:flutter/material.dart';

class BasePageState<T extends StatefulWidget> extends State<T> {
    @override
    Widget build(BuildContext context) {
        return Scaffold();
    }

    Future<void> alert({
        String title = 'Error',
        String message,
        String closeText = 'OK',
    }) {
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                    FlatButton(
                        child: Text(closeText),
                        onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
            ),
        );
    }

    Future<void> confirm({
        String title = 'Are you sure?',
        String message,
        String acceptText = 'Yes',
        String refuseText = 'No',
        Color acceptTextColor,
        Function onAccept,
    }) {
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                    FlatButton(
                        child: Text(refuseText),
                        textColor: Colors.grey[700],
                        onPressed: () => Navigator.of(context).pop(),
                    ),
                    FlatButton(
                        child: Text(acceptText),
                        textColor: acceptTextColor,
                        onPressed: () {
                            Navigator.of(context).pop();
                            onAccept();
                        },
                    ),
                ],
            ),
        );
    }
}
