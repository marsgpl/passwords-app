import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Login.dart';

class LoginsRepository {
    final FlutterSecureStorage storage;
    Map<String, Login> items;
    Map<String, dynamic> settings = {};
    String storageItemKeyPrefix = 'Login.';
    String storageSettingsKey = 'Login:Settings';

    LoginsRepository():
        storage = FlutterSecureStorage();

    Future<void> initAll() async {
        items = {};

        Map<String, String> kvs = await storage.readAll();

        for (String key in kvs.keys) {
            if (key.substring(0, storageItemKeyPrefix.length) == storageItemKeyPrefix) {
                Login item = Login.fromJson(json.decode(kvs[key]));
                items[item.id] = item;
            } else if (key == storageSettingsKey) {
                settings = json.decode(kvs[key]);
            }
        }
    }

    Login getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(Login item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = json.encode(item.toJson());

        await storage.write(key: key, value: value);

        items[item.id] = item;
    }

    Future<void> deleteItem(Login item) async {
        String key = storageItemKeyPrefix + item.id;

        await storage.delete(key: key);

        items.remove(item.id);
    }

    Future<void> saveSettings() async {
        await storage.write(
            key: storageSettingsKey,
            value: json.encode(settings),
        );
    }
}
