import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';

// ios
import 'package:flutter/cupertino.dart';
import 'package:passwords/CupertinoPasswordsApp.dart';

// android
// import 'package:flutter/material.dart';
// import 'package:passwords/MaterialPasswordsApp.dart';

// pubspec.yaml
// flutter:
//   uses-material-design: true

void main() {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);

    // ios
    return runApp(
        ChangeNotifierProvider<AppStateModel>(
            create: (context) => AppStateModel(),
            child: CupertinoPasswordsApp(),
        ));

    // android
    // return runApp(MaterialPasswordsApp());
}
