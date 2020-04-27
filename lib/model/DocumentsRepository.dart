import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Document.dart';

class DocumentsRepository {
    final FlutterSecureStorage storage;
    Map<String, Document> items;
    Map<String, dynamic> settings = {};
    String storageItemKeyPrefix = 'Document.';
    String storageSettingsKey = 'Document:Settings';

    DocumentsRepository():
        storage = FlutterSecureStorage();

    Future<void> initAll() async {
        items = {};

        Map<String, String> kvs = await storage.readAll();

        for (String key in kvs.keys) {
            if (key.substring(0, storageItemKeyPrefix.length) == storageItemKeyPrefix) {
                Document item = Document.fromJson(json.decode(kvs[key]));
                items[item.id] = item;
            } else if (key == storageSettingsKey) {
                settings = json.decode(kvs[key]);
            }
        }

        if (settings['unlocked'] != null) {
            print('removing unlocked status: $storageSettingsKey');
            settings.remove('unlocked');
            await saveSettings();
        }
    }

    Document getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(Document item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = json.encode(item.toJson());

        await storage.write(key: key, value: value);

        items[item.id] = item;
    }

    Future<void> deleteItem(Document item) async {
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
