import 'package:flutter/material.dart';
import '../widgets/passwordForm.dart';
import '../entities/Password.dart';
import '../pages/BasePage.dart';

class EditPasswordPage extends StatefulWidget {
    final Password password;
    final Future<void> Function(Password) onPasswordSave;
    final Future<void> Function(Password) onPasswordDelete;

    EditPasswordPage({
        Key key,
        this.password,
        this.onPasswordSave,
        this.onPasswordDelete,
    }) : super(key: key);

    @override
    EditPasswordPageState createState() => EditPasswordPageState();
}

class EditPasswordPageState extends BasePageState<EditPasswordPage> {
    TextEditingController title;
    TextEditingController login;
    TextEditingController email;
    TextEditingController phone;
    TextEditingController password;

    @override
    void initState() {
        title = TextEditingController(text: widget.password.title);
        login = TextEditingController(text: widget.password.login);
        email = TextEditingController(text: widget.password.email);
        phone = TextEditingController(text: widget.password.phone);
        password = TextEditingController(text: widget.password.password);
        super.initState();
    }

    Future<void> save() async {
        String titleText = title.text.trim();

        if (titleText.length == 0) {
            return alert(message: 'Title is empty');
        }

        widget.password.title = titleText;
        widget.password.login = login.text.trim();
        widget.password.email = email.text.trim();
        widget.password.phone = phone.text.trim();
        widget.password.password = password.text;

        await widget.onPasswordSave(widget.password);

        Navigator.of(context).pop();
    }

    Future<void> delete() => confirm(
        title: 'Delete?',
        message: '${widget.password.title}: ${widget.password.subtitle()}',
        acceptTextColor: Colors.red,
        onAccept: () async {
            await widget.onPasswordDelete(widget.password);
            Navigator.of(context).pop();
        }
    );

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Edit'),
            ),
            body: passwordForm(
                title: title,
                login: login,
                email: email,
                phone: phone,
                password: password,
                onSave: save,
                onDelete: delete,
            ),
        );
    }
}
