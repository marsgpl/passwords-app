import 'package:flutter/material.dart';
import '../widgets/passwordForm.dart';
import '../entities/Password.dart';
import '../pages/BasePage.dart';

class AddPasswordPage extends StatefulWidget {
    final Future<void> Function(Password) onPasswordAdd;

    AddPasswordPage({
        Key key,
        this.onPasswordAdd,
    }) : super(key: key);

    @override
    AddPasswordPageState createState() => AddPasswordPageState();
}

class AddPasswordPageState extends BasePageState<AddPasswordPage> {
    TextEditingController title;
    TextEditingController login;
    TextEditingController email;
    TextEditingController phone;
    TextEditingController password;

    @override
    void initState() {
        title = TextEditingController(text: '');
        login = TextEditingController(text: '');
        email = TextEditingController(text: '');
        phone = TextEditingController(text: '');
        password = TextEditingController(text: '');
        super.initState();
    }

    Future<void> add() async {
        String titleText = title.text.trim();

        if (titleText.length == 0) {
            return alert(
                title: 'Not saved',
                message: 'Title is empty',
            );
        }

        Password newPassword = Password(
            title: titleText,
            login: login.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            password: password.text,
        );

        await widget.onPasswordAdd(newPassword);

        Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Add'),
            ),
            body: passwordForm(
                title: title,
                login: login,
                email: email,
                phone: phone,
                password: password,
                onAdd: add,
            ),
        );
    }
}
