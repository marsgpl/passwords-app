import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class BasePageState<T extends StatefulWidget> extends State<T> {
    @override
    Widget build(BuildContext context) => Scaffold();

    Future<bool> openUrl(String url) async {
        if (url == null || url.trim().length == 0) {
            return false;
        }

        url = Uri.encodeFull(url.trim());

        if (!url.contains('://')) {
            url = 'https://$url';
        }

        if (!await canLaunch(url)) {
            return false;
        }

        await launch(url, forceSafariVC: false);

        return true;
    }

    void snack({
        BuildContext context,
        String message,
    }) {
        Scaffold.of(context ?? this.context).showSnackBar(SnackBar(content: Text(message)));
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
        Function onAccept,
        Function onRefuse,
        bool isAcceptCritical = false,
        bool isRefuseCritical = false,
        bool titleIsCritical = false,
    }) {
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text(title, style: titleIsCritical ?
                    const TextStyle(color: Colors.red) : null),
                content: Text(message),
                actions: <Widget>[
                    FlatButton(
                        child: Text(refuseText),
                        textColor: isRefuseCritical ?
                            Colors.red :
                            Colors.black87,
                        onPressed: () {
                            Navigator.of(context).pop();
                            if (onRefuse != null) onRefuse();
                        },
                    ),
                    FlatButton(
                        child: Text(acceptText),
                        textColor: isAcceptCritical ?
                            Colors.red :
                            PRIMARY_COLOR,
                        onPressed: () {
                            Navigator.of(context).pop();
                            if (onAccept != null) onAccept();
                        },
                    ),
                ],
            ),
        );
    }
}
