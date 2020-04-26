import 'package:flutter/cupertino.dart';
import 'package:passwords/Styles@cupertino.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';
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

class EditLoginPageState extends State<EditLoginPage> {
    TextEditingController title;
    TextEditingController login;
    TextEditingController password;
    TextEditingController website;

    @override
    void initState() {
        title = TextEditingController(text: widget.item.title);
        login = TextEditingController(text: widget.item.login);
        password = TextEditingController(text: widget.item.password);
        website = TextEditingController(text: widget.item.website);

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
        String titleText = title.text.trim();

        if (titleText.length == 0) {
            return saveErrorDialog('Title is empty');
        }

        widget.item.title = titleText;
        widget.item.login = login.text.trim();
        widget.item.password = password.text;
        widget.item.website = website.text.trim();

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
                title: title,
                login: login,
                password: password,
                website: website,
                onSave: save,
                onMoar: showActionSheet,
            ),
        );
    }
}
