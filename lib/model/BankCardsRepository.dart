import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/BankCard.dart';
import 'package:passwords/model/SettingsRepository.dart';

class BankCardsRepository {
    final FlutterSecureStorage storage;
    Map<String, BankCard> items;
    Map<String, String> search = {};
    String storageItemKeyPrefix = 'BankCard.';
    SettingsRepository settings;

    BankCardsRepository():
        storage = FlutterSecureStorage();

    Future<void> initAll() async {
        items = {};

        Map<String, String> kvs = await storage.readAll();

        for (String key in kvs.keys) {
            if (key.length > storageItemKeyPrefix.length &&
                key.substring(0, storageItemKeyPrefix.length) == storageItemKeyPrefix
            ) {
                BankCard item = BankCard.fromJson(json.decode(settings.decrypt(kvs[key])));
                items[item.id] = item;
            }
        }
    }

    BankCard getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(BankCard item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = settings.encrypt(json.encode(item.toJson()));

        await storage.write(key: key, value: value);

        items[item.id] = item;
    }

    Future<void> deleteItem(BankCard item) async {
        String key = storageItemKeyPrefix + item.id;

        await storage.delete(key: key);

        items.remove(item.id);
    }
}
