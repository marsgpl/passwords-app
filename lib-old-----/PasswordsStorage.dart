import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import './entities/Password.dart';

const STORAGE_PASSWORD_KEY_PREFIX = 'pwd.';

class PasswordsStorage {
    Map<String, Password> passwords;
    FlutterSecureStorage storage;

    PasswordsStorage():
        storage = FlutterSecureStorage();

    List<String> ids() {
        List<String> ids = passwords.keys.toList();

        ids.sort((id1, id2) =>
            passwords[id1].compareTo(passwords[id2]));

        return ids;
    }

    Password getById(String id) {
        return passwords[id];
    }

    Future<void> loadAll() async {
        passwords = {};

        Map<String, String> all = await storage.readAll();

        for (String key in all.keys) {
            if (key.substring(0, STORAGE_PASSWORD_KEY_PREFIX.length) == STORAGE_PASSWORD_KEY_PREFIX) {
                Map<String, dynamic> password = json.decode(all[key]);
                String id = key.substring(STORAGE_PASSWORD_KEY_PREFIX.length);

                passwords[id] = Password(
                    id: id,
                    createdAt: DateTime.parse(password['createdAt']),
                    title: password['title'],
                    login: password['login'],
                    email: password['email'],
                    phone: password['phone'],
                    password: password['password'],
                );
            }
        }
    }

    Future<String> add(Password newPassword) async {
        newPassword.id = Uuid().v4();
        newPassword.createdAt = DateTime.now();

        await save(newPassword);

        return newPassword.id;
    }

    Future<void> save(Password password) async {
        String key = STORAGE_PASSWORD_KEY_PREFIX + password.id;
        String value = password.toJson();

        await storage.write(
            key: key,
            value: value,
        );

        passwords[password.id] = password;
    }

    Future<void> delete(Password password) async {
        String key = STORAGE_PASSWORD_KEY_PREFIX + password.id;

        await storage.delete(key: key);

        passwords.remove(password.id);
    }
}
