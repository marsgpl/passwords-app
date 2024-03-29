import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/MaterialPasswordsApp.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);

    return runApp(ChangeNotifierProvider<AppStateModel>(
        create: (context) => AppStateModel(),
        child: MaterialPasswordsApp(),
    ));
}
