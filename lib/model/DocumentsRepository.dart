import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Cryptography.dart';
import 'package:passwords/model/Document.dart';
import 'package:passwords/helpers/generateRandomPassword.dart';

class DocumentsRepository {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Map<String, Document> items;
    Map<String, String> search;
    String storageItemKeyPrefix = 'Document.';
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
                Document item = Document.fromJson(json.decode(crypto.decrypt(localStorageInitialData[key])));
                items[item.id] = item;
            } catch(error) {
                print('Document init from key "$key" error: $error');
            }
        }

        buildSearch();
    }

    Document getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(Document item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = crypto.encrypt(json.encode(item.toJson()));

        await storage.write(key: key, value: value);

        items[item.id] = item;
        buildSearchForItem(item);
    }

    Future<void> deleteItem(Document item) async {
        String key = storageItemKeyPrefix + item.id;

        await storage.write(key: key, value: generateRandomPassword(length: 256));
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

    String buildSearchForItem(Document item) {
        List<String> search = [];

        if (item.title != null && item.title.length > 0) search.add(item.title.toLowerCase());

        return search.join(' ');
    }
}
