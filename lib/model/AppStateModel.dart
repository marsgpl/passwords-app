import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/BankCard.dart';
import 'package:passwords/model/Document.dart';
import 'package:passwords/model/Password.dart';
import 'package:passwords/model/Biometrics.dart';
import 'package:passwords/model/Cryptography.dart';
import 'package:passwords/model/PasswordsRepository.dart';
import 'package:passwords/model/BankCardsRepository.dart';
import 'package:passwords/model/DocumentsRepository.dart';
import 'package:passwords/model/SettingsRepository.dart';

class AppStateModel extends foundation.ChangeNotifier {
    final regexpSearchChunkSeparator = RegExp(r'[ ,\n\r\t]+', multiLine: true);
    final regexpEscapeQuoteForJsonEncode = RegExp(r'"');

    final storage = FlutterSecureStorage();
    Map<String, String> localStorageInitialData;

    final SettingsRepository settings = SettingsRepository();
    final PasswordsRepository passwords = PasswordsRepository();
    final BankCardsRepository bankCards = BankCardsRepository();
    final DocumentsRepository documents = DocumentsRepository();
    final Biometrics biometrics = Biometrics();
    final Cryptography crypto = Cryptography();

    bool isBiometricAuthRequired;
    bool isBiometricAuthSucceed;

    String passwordsFilter = '';
    String bankCardsFilter = '';
    String documentsFilter = '';

    List<String> passwordsFilterChunks = [];
    List<String> bankCardsFilterChunks = [];
    List<String> documentsFilterChunks = [];

    List<String> passwordsVisibleIds = [];
    List<String> bankCardsVisibleIds = [];
    List<String> documentsVisibleIds = [];

    bool passwordsNotFoundBySearch() =>
        passwords.isInited &&
        passwordsFilter.length > 0 &&
        passwordsVisibleIds.length == 0;

    bool passwordsNoItems() =>
        passwords.isInited &&
        passwordsFilter.length == 0 &&
        passwordsVisibleIds.length == 0;

    void onPasswordSearch(String searchText, { bool silent = false }) {
        passwordsFilter = searchText.trim().toLowerCase();
        passwordsFilterChunks = passwordsFilter.split(regexpSearchChunkSeparator);
        filterPasswordsVisibleIds();
        if (!silent) notifyListeners();
    }

    bool bankCardsNotFoundBySearch() =>
        bankCards.isInited &&
        bankCardsFilter.length > 0 &&
        bankCardsVisibleIds.length == 0;

    bool bankCardsNoItems() =>
        bankCards.isInited &&
        bankCardsFilter.length == 0 &&
        bankCardsVisibleIds.length == 0;

    void onBankCardsSearch(String searchText, { bool silent = false }) {
        bankCardsFilter = searchText.trim().toLowerCase();
        bankCardsFilterChunks = bankCardsFilter.split(regexpSearchChunkSeparator);
        filterBankCardsVisibleIds();
        if (!silent) notifyListeners();
    }

    bool documentsNotFoundBySearch() =>
        documents.isInited &&
        documentsFilter.length > 0 &&
        documentsVisibleIds.length == 0;

    bool documentsNoItems() =>
        documents.isInited &&
        documentsFilter.length == 0 &&
        documentsVisibleIds.length == 0;

    void onDocumentSearch(String searchText, { bool silent = false }) {
        documentsFilter = searchText.trim().toLowerCase();
        documentsFilterChunks = documentsFilter.split(regexpSearchChunkSeparator);
        filterDocumentsVisibleIds();
        if (!silent) notifyListeners();
    }

    void filterBankCardsVisibleIds() {
        final items = bankCards.items;
        final searchCache = bankCards.search;

        if (bankCardsFilter.length == 0) {
            bankCardsVisibleIds = items.keys.toList();
        } else if (bankCardsFilterChunks.length == 1) {
            bankCardsVisibleIds = items.keys.where((itemId) =>
                searchCache[itemId].contains(bankCardsFilter)).toList();
        } else {
            bankCardsVisibleIds = items.keys.where((itemId) {
                final itemSearchCache = searchCache[itemId];
                for (int i = 0, c = bankCardsFilterChunks.length; i < c; ++i) {
                    if (!itemSearchCache.contains(bankCardsFilterChunks[i])) return false;
                }
                return true;
            }).toList();
        }

        bankCardsVisibleIds.sort((id1, id2) =>
            items[id1].compareTo(items[id2]));
    }

    void filterDocumentsVisibleIds() {
        final items = documents.items;
        final searchCache = documents.search;

        if (documentsFilter.length == 0) {
            documentsVisibleIds = items.keys.toList();
        } else if (documentsFilterChunks.length == 1) {
            documentsVisibleIds = items.keys.where((itemId) =>
                searchCache[itemId].contains(documentsFilter)).toList();
        } else {
            documentsVisibleIds = items.keys.where((itemId) {
                final itemSearchCache = searchCache[itemId];
                for (int i = 0, c = documentsFilterChunks.length; i < c; ++i) {
                    if (!itemSearchCache.contains(documentsFilterChunks[i])) return false;
                }
                return true;
            }).toList();
        }

        documentsVisibleIds.sort((id1, id2) =>
            items[id1].compareTo(items[id2]));
    }

    void filterPasswordsVisibleIds() {
        final items = passwords.items;
        final searchCache = passwords.search;

        if (passwordsFilter.length == 0) {
            passwordsVisibleIds = items.keys.toList();
        } else if (passwordsFilterChunks.length == 1) {
            passwordsVisibleIds = items.keys.where((itemId) =>
                searchCache[itemId].contains(passwordsFilter)).toList();
        } else {
            passwordsVisibleIds = items.keys.where((itemId) {
                final itemSearchCache = searchCache[itemId];
                for (int i = 0, c = passwordsFilterChunks.length; i < c; ++i) {
                    if (!itemSearchCache.contains(passwordsFilterChunks[i])) return false;
                }
                return true;
            }).toList();
        }

        passwordsVisibleIds.sort((id1, id2) =>
            items[id1].compareTo(items[id2]));
    }

    Future<void> addBankCard(BankCard item) async {
        await bankCards.saveItem(item);

        if (bankCardsFilter.length > 0) {
            filterBankCardsVisibleIds();
            notifyListeners();
        } else {
            bankCardsVisibleIds.insert(0, item.id);
            notifyListeners();
        }
    }

    Future<void> saveBankCard(BankCard item) async {
        await bankCards.saveItem(item);

        notifyListeners();
    }

    Future<void> deleteBankCard(BankCard item) async {
        await bankCards.deleteItem(item);

        bankCardsVisibleIds.remove(item.id);

        notifyListeners();
    }

    Future<void> addDocument(Document item) async {
        await documents.saveItem(item);

        if (documentsFilter.length > 0) {
            filterDocumentsVisibleIds();
            notifyListeners();
        } else {
            documentsVisibleIds.insert(0, item.id);
            notifyListeners();
        }
    }

    Future<void> saveDocument(Document item) async {
        await documents.saveItem(item);

        notifyListeners();
    }

    Future<void> deleteDocument(Document item) async {
        await documents.deleteItem(item);

        documentsVisibleIds.remove(item.id);

        notifyListeners();
    }

    Future<void> addPassword(Password item) async {
        await passwords.saveItem(item);

        if (passwordsFilter.length > 0) {
            filterPasswordsVisibleIds();
            notifyListeners();
        } else {
            passwordsVisibleIds.insert(0, item.id);
            notifyListeners();
        }
    }

    Future<void> savePassword(Password item) async {
        await passwords.saveItem(item);

        notifyListeners();
    }

    Future<void> deletePassword(Password item) async {
        await passwords.deleteItem(item);

        passwordsVisibleIds.remove(item.id);

        notifyListeners();
    }

    Future<void> initLocalStorageInitialData() async {
        if (localStorageInitialData != null) return;
        localStorageInitialData = await storage.readAll();
    }

    void resetLocalStorageInitialData() {
        localStorageInitialData = null;
    }

    Future<void> initCrypto() async {
        if (crypto.isInited) return;

        await initLocalStorageInitialData();

        await crypto.init(localStorageInitialData);
    }

    Future<void> initBiometrics({
        bool silent = false,
    }) async {
        if (biometrics.isInited) return;

        await biometrics.init();

        if (!silent) notifyListeners();
    }

    Future<void> initPasswords({
        bool silent = false,
    }) async {
        if (passwords.isInited) return;

        await initLocalStorageInitialData();
        await initCrypto();

        await passwords.init(localStorageInitialData, crypto);

        filterPasswordsVisibleIds();
        if (!silent) notifyListeners();
    }

    Future<void> initBankCards({
        bool silent = false,
    }) async {
        if (bankCards.isInited) return;

        await initLocalStorageInitialData();
        await initCrypto();

        await bankCards.init(localStorageInitialData, crypto);

        filterBankCardsVisibleIds();
        if (!silent) notifyListeners();
    }

    Future<void> initDocuments({
        bool silent = false,
    }) async {
        if (documents.isInited) return;

        await initLocalStorageInitialData();
        await initCrypto();

        await documents.init(localStorageInitialData, crypto);

        filterDocumentsVisibleIds();
        if (!silent) notifyListeners();
    }

    Future<void> initSettings({
        bool silent = false,
    }) async {
        if (settings.isInited) return;

        await initLocalStorageInitialData();

        await settings.init(localStorageInitialData);

        if (!silent) notifyListeners();
    }

    Future<void> saveSettings({
        bool silent = false,
    }) async {
        await settings.save();

        if (!silent) notifyListeners();
    }

    void resetBiometrics({
        bool silent = false,
    }) {
        isBiometricAuthRequired = null;
        isBiometricAuthSucceed = null;

        biometrics.reset();

        if (!silent) notifyListeners();
    }

    Future<bool> biometricAuth({
        bool reset: false,
        bool singleUpdate: false, // call notifyListeners only at the end
        bool skipChallenge: false,
        bool forceChallenge: false,
    }) async {
        if (reset) resetBiometrics(silent: singleUpdate);

        await Future.wait([
            initBiometrics(silent: singleUpdate),
            initSettings(silent: singleUpdate),
        ]);

        final conf = settings.settings;

        isBiometricAuthRequired = conf.isFaceIdEnabled || conf.isTouchIdEnabled;

        if ((isBiometricAuthRequired || forceChallenge) && !skipChallenge) {
            isBiometricAuthSucceed = await biometrics.challenge();
        } else {
            isBiometricAuthSucceed = false;
        }

        notifyListeners();

        return isBiometricAuthSucceed;
    }

    Future<String> dumpAllDataExceptSettings() async {
        Map<String, String> kvs = await storage.readAll();

        List<String> lines = [];

        for (String key in kvs.keys) {
            if (key == settings.storageKey) continue;

            String value = kvs[key].replaceAll(regexpEscapeQuoteForJsonEncode, '\\"');

            lines.add('"$key": "$value"');
        }

        return '{${lines.join(',\n')}}\n';
    }

    Future<void> eraseAllData({
        bool silent = false,
    }) async {
        await storage.deleteAll();

        resetLocalStorageInitialData();

        crypto.reset();
        resetBiometrics(silent: true);

        passwords.reset();
        bankCards.reset();
        documents.reset();
        settings.reset();

        if (!silent) notifyListeners();
    }

    Future<void> reinitSettings({
        bool silent = false,
    }) async {
        await settings.resetAndSaveInitial();

        if (!silent) notifyListeners();
    }

    Future<void> restoreFromBackup(String jsonEncoded) async {
        String settingsBackup = settings.exportAsJsonString();

        await eraseAllData(silent: true);

        Map<String, dynamic> kvs = json.decode(jsonEncoded);

        for (String key in kvs.keys) {
            await storage.write(
                key: key,
                value: kvs[key],
            );
        }

        await initLocalStorageInitialData();
        localStorageInitialData[settings.storageKey] = settingsBackup;

        await initSettings(silent: true);
        await saveSettings(silent: true);
        await biometricAuth(singleUpdate: true);
    }
}
