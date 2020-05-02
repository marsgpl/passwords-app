import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) => ListView(
        children: [
            proTip(),
            Image(image: new AssetImage('assets/swipe.gif')),
        ],
    );

    Widget proTip() => ListTile(
        title: const Text('How to use:'),
    );
}
