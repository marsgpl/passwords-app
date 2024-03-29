import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/pages/material/TabsPage.dart';
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
        String message,
        BuildContext context,
    }) {
        final state = (context != null) ?
            Scaffold.of(context) :
            TabsPage.scaffoldKey.currentState;

        state.showSnackBar(SnackBar(content: Text(message)));
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
        int messageMaxLines,
    }) {
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text(title, style: titleIsCritical ?
                    const TextStyle(color: Colors.red) : null),
                content: messageMaxLines == null ?
                    Text(message) :
                    Text(message, maxLines: messageMaxLines, overflow: TextOverflow.ellipsis),
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
