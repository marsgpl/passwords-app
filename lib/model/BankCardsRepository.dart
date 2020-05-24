import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Cryptography.dart';
import 'package:passwords/model/BankCard.dart';

class BankCardsRepository {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Map<String, BankCard> items;
    Map<String, String> search;
    String storageItemKeyPrefix = 'BankCard.';
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
                BankCard item = BankCard.fromJson(json.decode(crypto.decrypt(localStorageInitialData[key])));
                items[item.id] = item;
            } catch(error) {
                print('BankCard init from key "$key" error: $error');
            }
        }

        buildSearch();
    }

    void reset() {
        items = null;
        search = null;
    }

    BankCard getItemById(String id) {
        return items[id];
    }

    Future<void> saveItem(BankCard item) async {
        String key = storageItemKeyPrefix + item.id;
        String value = crypto.encrypt(json.encode(item.toJson()));

        await storage.write(key: key, value: value);

        items[item.id] = item;
        search[item.id] = buildSearchForItem(item);
    }

    Future<void> deleteItem(BankCard item) async {
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

    String buildSearchForItem(BankCard item) {
        List<String> search = [];

        if (item.title != null && item.title.length > 0) search.add(item.title.toLowerCase());
        if (item.number != null && item.number.length > 0) search.add(item.number);
        if (item.csv != null) search.add(item.csv.toString());
        if (item.expiresAt != null && item.expiresAt.length > 0) search.add(item.expiresAt);
        if (item.owner != null && item.owner.length > 0) search.add(item.owner.toLowerCase());

        return search.join(' ');
    }
}
