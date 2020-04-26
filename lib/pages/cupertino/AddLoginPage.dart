import 'package:flutter/cupertino.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/widgets/cupertino/loginForm.dart';
import 'package:provider/provider.dart';

class AddLoginPage extends StatefulWidget {
    @override
    AddLoginPageState createState() => AddLoginPageState();
}

class AddLoginPageState extends State<AddLoginPage> {
    TextEditingController title = TextEditingController(text: '');
    TextEditingController login = TextEditingController(text: '');
    TextEditingController password = TextEditingController(text: '');
    TextEditingController website = TextEditingController(text: '');

    Future<void> addErrorDialog(String reason) async => showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Not created'),
            content: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(reason),
            ),
            actions: [
                CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                ),
            ],
        ),
    );

    Future<void> add() async {
        String titleText = title.text.trim();

        if (titleText.length == 0) {
            return addErrorDialog('Title is empty');
        }

        Login item = Login(
            title: titleText,
            login: login.text.trim(),
            password: password.text,
            website: website.text.trim(),
        );

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        await model.addLogin(item);

        Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: loginForm(
                title: title,
                login: login,
                password: password,
                website: website,
                onAdd: add,
            ),
        );
    }
}
