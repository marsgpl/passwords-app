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
            const Image(
                key: Key('HowToUseImg'),
                image: AssetImage('assets/swipe.gif'),
            ),
        ],
    );

    Widget howToUseRow() => const ListTile(
        key: Key('HowToUse'),
        title: const Text('How to copy password:'),
    );
}
