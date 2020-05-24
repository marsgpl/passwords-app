import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Cryptography.dart';
import 'package:passwords/model/Password.dart';

class PasswordsRepository {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Map<String, Password> items;
    Map<String, String> search;
    String storageItemKeyPrefix = 'Password.';
    Cryptography crypto;

    bool get isInited => items != null;

    Future<void> init(Map<String, String> localStorageInitialData, Cryptography crypto) async {
        this.crypto = crypto;
        items = {};

        final minKeyLength = storageItemKeyPrefix.length + 1;

        for (String key in localStorageInitialData.keys) {
            if (key.length < minKeyLength) continue;
            if (key.substring(0, storageItemKeyPrefix.length) != storageItemKeyPrefix) continue;

            try {
                Password item = Password.fromJson(json.decode(crypto.decrypt(localStorageInitialData[key])));
                items[item.id] = item;
            } catch(error) {
                print('Password init from key "$key" error: $error');
            }
        }

        buildSearch();
    }

    void reset() {
        items = null;
        search = null;
    }

    Password getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(Password item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = crypto.encrypt(json.encode(item.toJson()));

        await storage.write(key: key, value: value);

        items[item.id] = item;
        search[item.id] = buildSearchForItem(item);
    }

    Future<void> deleteItem(Password item) async {
        String key = storageItemKeyPrefix + item.id;

        await storage.delete(key: key);

        items.remove(item.id);
        search.remove(item.id);
    }

    void buildSearch() {
        search = {};

        items.forEach((id, item) {
            search[id] = buildSearchForItem(item);
        });
    }

    String buildSearchForItem(Password item) {
        List<String> search = [];

        if (item.title != null && item.title.length > 0) search.add(item.title.toLowerCase());
        if (item.login != null && item.login.length > 0) search.add(item.login.toLowerCase());
        if (item.website != null && item.website.length > 0) search.add(item.website.toLowerCase());

        if (item.secretQuestions.length > 0) {
            item.secretQuestions.forEach((question) {
                if (question.length > 0) search.add(question.toLowerCase());
            });
        }

        if (item.secretQuestionsAnswers.length > 0) {
            item.secretQuestionsAnswers.forEach((answer) {
                if (answer.length > 0) search.add(answer.toLowerCase());
            });
        }

        return search.join(' ');
    }
}
