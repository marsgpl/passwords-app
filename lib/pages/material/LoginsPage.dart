import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passwords/pages/material/BasePage.dart';
import 'package:passwords/model/AppStateModel.dart';

class LoginsPage extends StatefulWidget {
    @override
    LoginsPageState createState() => LoginsPageState();
}

class LoginsPageState extends BasePageState<LoginsPage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: buildAppBar(),
            body: buildBody(),
        );
    }

    Widget buildAppBar() => AppBar(
        title: Text('Logins'),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            return Center(
                child: Text('ok'),
            );
        }
    );
}
