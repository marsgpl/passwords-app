import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/pages/material/LoginsPage.dart';

class MaterialPasswordsApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: APP_TITLE,
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: LoginsPage(),
        );
    }
}
