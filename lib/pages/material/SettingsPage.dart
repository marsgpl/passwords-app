import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: const Text('Settings & info'),
    );

    Widget buildBody() => ListView(
        semanticChildCount: 1,
        children: [
            howToUseRow(),
            const Image(image: AssetImage('assets/swipe.gif')),
        ],
    );

    Widget howToUseRow() => const ListTile(
        title: const Text('How to copy password:'),
    );
}
