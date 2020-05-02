import 'package:flutter/material.dart';
import 'package:passwords/pages/material/BasePage.dart';

class InfoPage extends StatefulWidget {
    @override
    InfoPageState createState() => InfoPageState();
}

class InfoPageState extends BasePageState<InfoPage> {
    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: const Text('Information'),
    );

    Widget buildBody() {
        List<Widget> children = [];

        children.add(Text('lol'));
        children.add(Text('kek'));

        return ListView(
            padding: const EdgeInsets.all(14),
            children: children,
        );
    }
}
