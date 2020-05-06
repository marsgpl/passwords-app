import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/pages/material/TabsPage.dart';

class MaterialPasswordsApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            // debugShowCheckedModeBanner: false,
            title: APP_TITLE,
            theme: ThemeData(
                primarySwatch: PRIMARY_COLOR,
            ),
            home: TabsPage(),
        );
    }
}
