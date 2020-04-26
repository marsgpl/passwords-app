import 'package:flutter/material.dart';
import './pages/PasswordsListPage.dart';

class PasswordsApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Passwords',
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: PasswordsListPage(),
        );
    }
}
