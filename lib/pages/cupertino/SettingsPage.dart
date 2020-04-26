import 'package:flutter/cupertino.dart';

class SettingsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            child: CustomScrollView(
                slivers: [
                    CupertinoSliverNavigationBar(),
                ],
            ),
        );
    }
}
