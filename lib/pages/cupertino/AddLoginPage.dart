import 'package:flutter/cupertino.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/pages/cupertino/BasePage.dart';
import 'package:passwords/widgets/cupertino/loginForm.dart';
import 'package:provider/provider.dart';

class AddLoginPage extends StatefulWidget {
    @override
    AddLoginPageState createState() => AddLoginPageState();
}

class AddLoginPageState extends BasePageState<AddLoginPage> {
    TextEditingController titleController = TextEditingController(text: '');
    TextEditingController loginController = TextEditingController(text: '');
    TextEditingController passwordController = TextEditingController(text: '');
    TextEditingController websiteController = TextEditingController(text: '');
    FocusNode titleFocus = FocusNode();
    FocusNode loginFocus = FocusNode();
    FocusNode passwordFocus = FocusNode();
    FocusNode websiteFocus = FocusNode();

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
        String titleText = titleController.text.trim();
        String loginText = loginController.text.trim();

        if (titleText.length == 0) return addErrorDialog('Title is empty');
        if (loginText.length == 0) return addErrorDialog('Login is empty');

        // capitalize
        titleText = '${titleText[0].toUpperCase()}${titleText.substring(1)}';

        Login item = Login(
            title: titleText,
            login: loginText,
            password: passwordController.text,
            website: websiteController.text.trim(),
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
                titleController: titleController,
                loginController: loginController,
                passwordController: passwordController,
                websiteController: websiteController,
                titleFocus: titleFocus,
                loginFocus: loginFocus,
                passwordFocus: passwordFocus,
                websiteFocus: websiteFocus,
                onAdd: add,
            ),
        );
    }
}
