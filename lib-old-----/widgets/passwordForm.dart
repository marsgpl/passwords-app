import 'package:flutter/material.dart';

Widget passwordFormField({
    String label,
    TextEditingController controller,
}) {
    return Container(
        margin: EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: TextFormField(
            key: Key(label),
            controller: controller,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
                labelText: label,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 14,
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey[350],
                        width: .5,
                    ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width: .5,
                    ),
                ),
            ),
        ),
    );
}

Widget passwordForm({
    TextEditingController title,
    TextEditingController login,
    TextEditingController email,
    TextEditingController phone,
    TextEditingController password,
    Function onAdd,
    Function onSave,
    Function onDelete,
}) {
    List<Widget> buttons = [];

    EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 24,
    );

    if (onAdd != null) {
        buttons.add(FlatButton(
            child: Text('Save'),
            onPressed: onAdd,
            color: Colors.blue,
            padding: buttonPadding,
        ));
    } else if (onSave != null) {
        if (onDelete != null) {
            buttons.add(FlatButton(
                child: Text('Delete'),
                onPressed: onDelete,
                textColor: Colors.red,
                padding: buttonPadding,
            ));
        }

        buttons.add(FlatButton(
            child: Text('Save'),
            onPressed: onSave,
            color: Colors.blue,
            padding: buttonPadding,
        ));
    }

    return Column(
        children: <Widget>[
            Container(
                margin: EdgeInsets.all(4),
            ),
            passwordFormField(label: 'Title', controller: title),
            passwordFormField(label: 'Login', controller: login),
            passwordFormField(label: 'Email', controller: email),
            passwordFormField(label: 'Phone', controller: phone),
            passwordFormField(label: 'Password', controller: password),
            ButtonBar(
                // layoutBehavior: ButtonBarLayoutBehavior.constrained,
                buttonPadding: EdgeInsets.all(15),
                children: buttons,
            ),
        ],
    );
}
