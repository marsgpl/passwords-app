import 'package:flutter/material.dart';
import '../entities/Password.dart';
import '../PasswordsStorage.dart';

Widget passwordsListItem(
    PasswordsStorage pwStorage,
    String passwordId,
    void onTap(String passwordId),
) {
    Password item = pwStorage.getById(passwordId);
    String subtitle = item.subtitle();

    return ListTile(
        key: Key(passwordId),
        title: item.title.length > 0 ?
            Text(item.title, maxLines: 1) :
            Text('EMPTY', style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
            )),
        subtitle: subtitle.length > 0 ? Text(subtitle) : null,
        trailing: Icon(Icons.chevron_right),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () => onTap(passwordId),
    );
}

Widget passwordsList(
    PasswordsStorage pwStorage,
    List<String> shownPasswordsIds,
    void onItemTap(String passwordId),
) {
    return ListView.builder(
        itemCount: shownPasswordsIds.length * 2,
        itemBuilder: (context, index) {
            if (index.isOdd) return Divider(
                height: .5,
                indent: 0,
                thickness: .5,
            );

            int passwordIndex = index ~/ 2;

            return passwordsListItem(
                pwStorage,
                shownPasswordsIds[passwordIndex],
                onItemTap,
            );
        }
    );
}
