import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/pages/material/TabsPage.dart';

class MaterialPasswordsApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: APP_TITLE,
            home: TabsPage(),
            theme: ThemeData(
                primarySwatch: PRIMARY_COLOR,
                platform: TargetPlatform.iOS,
            ),
            // debugShowCheckedModeBanner: false,
        );
    }
}
