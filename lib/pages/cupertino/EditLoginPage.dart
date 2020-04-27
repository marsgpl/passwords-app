import 'package:flutter/cupertino.dart';
import 'package:passwords/Styles@cupertino.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/pages/cupertino/BasePage.dart';
import 'package:passwords/widgets/cupertino/loginForm.dart';
import 'package:provider/provider.dart';

class EditLoginPage extends StatefulWidget {
    final Login item;

    EditLoginPage({
        Key key,
        this.item,
    }) : super(key: key);

    @override
    EditLoginPageState createState() => EditLoginPageState();
}

class EditLoginPageState extends BasePageState<EditLoginPage> {
    TextEditingController titleController;
    TextEditingController loginController;
    TextEditingController passwordController;
    TextEditingController websiteController;
    FocusNode titleFocus = FocusNode();
    FocusNode loginFocus = FocusNode();
    FocusNode passwordFocus = FocusNode();
    FocusNode websiteFocus = FocusNode();

    @override
    void initState() {
        titleController = TextEditingController(text: widget.item.title);
        loginController = TextEditingController(text: widget.item.login);
        passwordController = TextEditingController(text: widget.item.password);
        websiteController = TextEditingController(text: widget.item.website);

        super.initState();
    }

    Future<void> saveErrorDialog(String reason) async => showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Not saved'),
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

    Future<void> save() async {
        String titleText = titleController.text.trim();
        String loginText = loginController.text.trim();

        if (titleText.length == 0) return saveErrorDialog('Title is empty');
        if (loginText.length == 0) return saveErrorDialog('Login is empty');

        // capitalize
        titleText = '${titleText[0].toUpperCase()}${titleText.substring(1)}';

        widget.item.title = titleText;
        widget.item.login = loginText;
        widget.item.password = passwordController.text;
        widget.item.website = websiteController.text.trim();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        await model.saveLogin(widget.item);

        Navigator.of(context).pop();
    }

    Future<void> delete() async {
        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);
        await model.deleteLogin(widget.item);
        Navigator.of(context).pop();
    }

    Future<void> deleteDialog() async => showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Delete?'),
            content: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('${widget.item.title}: ${widget.item.login}'),
            ),
            actions: [
                CupertinoDialogAction(
                    child: const Text('No', style: Styles.notImportantChoice),
                    onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                    child: const Text('Yes', style: Styles.delete),
                    onPressed: () async {
                        Navigator.of(context).pop();
                        delete();
                    },
                ),
            ],
        ),
    );

    Future<void> showActionSheet() => showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
            message: const Text('Deleted logins can be restored from backup'),
            actions: [
                CupertinoActionSheetAction(
                    child: const Text('Delete', style: Styles.delete),
                    onPressed: () {
                        Navigator.of(context).pop();
                        deleteDialog();
                    },
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
            ),
        ),
    );

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
                onSave: save,
                onMoar: showActionSheet,
            ),
        );
    }
}
