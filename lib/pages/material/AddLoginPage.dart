import 'package:flutter/material.dart';
import 'package:passwords/widgets/material/loginForm.dart';

class AddLoginPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: const Text('New login'),
    );

    Widget buildBody() => loginForm(
        onAdd: () => {},
    );
}
