import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/helpers/generateRandomPassword.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/model/SettingsRepository.dart';

class LoginsRepository {
    final FlutterSecureStorage storage;
    Map<String, Login> items;
    Map<String, String> search = {};
    String storageItemKeyPrefix = 'Login.';
    SettingsRepository settings;

    LoginsRepository():
        storage = FlutterSecureStorage();

    Future<void> initAll() async {
        items = {};

        Map<String, String> kvs = await storage.readAll();

        for (String key in kvs.keys) {
            if (key.length > storageItemKeyPrefix.length &&
                key.substring(0, storageItemKeyPrefix.length) == storageItemKeyPrefix
            ) {
                try {
                    Login item = Login.fromJson(json.decode(settings.decrypt(kvs[key])));
                    items[item.id] = item;
                } catch(error) {
                    print('oops: $error');
                }
            }
        }

        buildSearch(null);
    }

    void buildSearch(String id) {
        final currentItem = items[id];

        if (id == null) { // rebuild all
            search = {};
            items.forEach((id, item) {
                search[id] = buildSearchForItem(item);
            });
        } else if (currentItem != null) { // rebuild item
            search[id] = buildSearchForItem(currentItem);
        } else { // delete item
            search.remove(id);
        }
    }

    String buildSearchForItem(Login item) {
        String search = '';

        search += item.title.toLowerCase() + ' ';
        search += item.login.toLowerCase() + ' ';
        search += item.website.toLowerCase() + ' ';

        if (item.secretQuestions.length > 0) {
            item.secretQuestions.forEach((question) {
                search += question.toLowerCase() + ' ';
            });
        }

        if (item.secretQuestionsAnswers.length > 0) {
            item.secretQuestionsAnswers.forEach((answer) {
                search += answer.toLowerCase() + ' ';
            });
        }

        return search;
    }

    Login getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(Login item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = settings.encrypt(json.encode(item.toJson()));

        await storage.write(key: key, value: value);

        items[item.id] = item;

        buildSearch(item.id);
    }

    Future<void> deleteItem(Login item) async {
        String key = storageItemKeyPrefix + item.id;

        await storage.write(key: key, value: generateRandomPassword(length: 128));
        await storage.delete(key: key);

        items.remove(item.id);

        buildSearch(item.id);
    }
}
