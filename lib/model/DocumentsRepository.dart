import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/helpers/generateRandomPassword.dart';
import 'package:passwords/model/Document.dart';
import 'package:passwords/model/SettingsRepository.dart';

class DocumentsRepository {
    final FlutterSecureStorage storage;
    Map<String, Document> items;
    Map<String, String> search = {};
    String storageItemKeyPrefix = 'Document.';
    SettingsRepository settings;

    DocumentsRepository():
        storage = FlutterSecureStorage();

    Future<void> initAll() async {
        items = {};

        Map<String, String> kvs = await storage.readAll();

        for (String key in kvs.keys) {
            if (key.length > storageItemKeyPrefix.length &&
                key.substring(0, storageItemKeyPrefix.length) == storageItemKeyPrefix
            ) {
                Document item = Document.fromJson(json.decode(settings.decrypt(kvs[key])));
                items[item.id] = item;
            }
        }
    }

    Document getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(Document item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = settings.encrypt(json.encode(item.toJson()));

        await storage.write(key: key, value: value);

        items[item.id] = item;
    }

    Future<void> deleteItem(Document item) async {
        String key = storageItemKeyPrefix + item.id;

        await storage.write(key: key, value: generateRandomPassword(length: 128));
        await storage.delete(key: key);

        items.remove(item.id);
    }
}
