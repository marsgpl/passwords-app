import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';

Widget loginForm({
    Function onAdd,
}) {
    List<Widget> buttons = [];

    if (onAdd != null) {
        buttons.add(FlatButton(
            child: const Text('Create'),
            color: PRIMARY_COLOR,
            onPressed: onAdd,
        ));
    }

    return ListView(
        padding: const EdgeInsets.all(8),
        children: [
            TextFormField(initialValue: 'Title'),
            TextFormField(initialValue: 'Login'),
            TextFormField(initialValue: 'Password'),
            TextFormField(initialValue: 'Website'),
            TextFormField(initialValue: 'backup2faCodes'),
            TextFormField(initialValue: 'secretQuestion1'),
            TextFormField(initialValue: 'secretQuestion1Answer'),
            ButtonBar(
                children: buttons,
            ),
        ],
    );
}
