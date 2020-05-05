import 'package:flutter/foundation.dart' as foundation;
import 'package:passwords/helpers/generateRandomPassword.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/model/BankCard.dart';
import 'package:passwords/model/Document.dart';
import 'package:passwords/model/LoginsRepository.dart';
import 'package:passwords/model/BankCardsRepository.dart';
import 'package:passwords/model/DocumentsRepository.dart';
import 'package:passwords/model/SettingsRepository.dart';

class AppStateModel extends foundation.ChangeNotifier {
    final searchSplit = new RegExp('[ ,\n\r\t]+');

    final LoginsRepository logins = LoginsRepository();
    final BankCardsRepository bankCards = BankCardsRepository();
    final DocumentsRepository documents = DocumentsRepository();
    final SettingsRepository settings = SettingsRepository();

    bool loginsInited = false;
    bool bankCardsInited = false;
    bool documentsInited = false;
    bool settingsInited = false;

    String loginsFilter = '';
    String bankCardsFilter = '';
    String documentsFilter = '';

    List<String> loginsFilterChunks = [];
    List<String> bankCardsFilterChunks = [];
    List<String> documentsFilterChunks = [];

    List<String> loginsVisibleIds;
    List<String> bankCardsVisibleIds;
    List<String> documentsVisibleIds;

    bool loginsNotFoundBySearch() =>
        loginsInited &&
        loginsVisibleIds.length == 0 &&
        loginsFilter.length > 0;

    bool loginsNoItems() =>
        loginsInited &&
        loginsVisibleIds.length == 0 &&
        loginsFilter.length == 0;

    void onLoginSearch(String searchText) {
        loginsFilter = searchText.trim().toLowerCase();
        loginsFilterChunks = loginsFilter.split(searchSplit);
        filterLoginsVisibleIds();
        notifyListeners();
    }

    void filterLoginsVisibleIds() {
        final items = logins.items;
        final itemsSearchBuffs = logins.search;

        if (loginsFilter.length == 0) {
            loginsVisibleIds = items.keys.toList();
        } else if (loginsFilterChunks.length == 1) {
            loginsVisibleIds = items.keys.where((itemId) =>
                itemsSearchBuffs[itemId].contains(loginsFilter)).toList();
        } else {
            loginsVisibleIds = items.keys.where((itemId) {
                final item = itemsSearchBuffs[itemId];
                for (int i = 0, c = loginsFilterChunks.length; i < c; ++i) {
                    if (!item.contains(loginsFilterChunks[i])) return false;
                }
                return true;
            }).toList();
        }

        loginsVisibleIds.sort((id1, id2) =>
            items[id1].compareTo(items[id2]));
    }

    Future<void> addLogin(Login item) async {
        await logins.saveItem(item);

        if (loginsFilter.length == 0) {
            loginsVisibleIds.insert(0, item.id);
        }

        notifyListeners();
    }

    Future<void> saveLogin(Login item) async {
        await logins.saveItem(item);

        notifyListeners();
    }

    Future<void> deleteLogin(Login item) async {
        await logins.deleteItem(item);

        loginsVisibleIds.remove(item.id);

        notifyListeners();
    }

    Future<void> initLogins() async {
        if (loginsInited) return;

        await initSettings();

        logins.settings = settings;

        await logins.initAll().catchError((error) {
            print('oops: logins.initAll: $error');
        });

        filterLoginsVisibleIds();

        loginsInited = true;

        notifyListeners();
    }

    Future<void> initBankCards() async {
        if (bankCardsInited) return;

        await initSettings();

        bankCards.settings = settings;

        await bankCards.initAll().catchError((error) {
            print('oops: bankCards.initAll: $error');
        });

        bankCardsInited = true;

        notifyListeners();
    }

    Future<void> initDocuments() async {
        if (documentsInited) return;

        await initSettings();

        documents.settings = settings;

        await documents.initAll().catchError((error) {
            print('oops: documents.initAll: $error');
        });

        documentsInited = true;

        notifyListeners();
    }

    Future<void> initSettings() async {
        if (settingsInited) return;

        await settings.init().catchError((error) {
            print('oops: settings.init: $error');
        });

        await initBiometrics();

        settingsInited = true;

        notifyListeners();
    }

    Future<void> initBiometrics() async {
        final s = settings.settings;

        if (s.isFaceIdEnabled || s.isTouchIdEnabled) {
            s.authenticated = await checkBiometrics();
        }
    }

    Future<bool> checkBiometrics() async {
        bool success;

        try {
            success = await settings.settings.localAuth.authenticateWithBiometrics(
                localizedReason: 'Passwords require biometric identification',
                useErrorDialogs: true,
                stickyAuth: true,
            );
        } catch (error) {
            success = false;
        }

        return success;
    }

    Future<void> saveSettings() async {
        await settings.save();
        notifyListeners();
    }

    Future<void> resetAndSaveSettings() async {
        await settings.resetAndSave();
        notifyListeners();
    }

    Future<void> eraseAllData() async {
        await eraseAllWithRandom();
        await settings.storage.deleteAll();
        await reinitAll();
    }

    Future<void> eraseAllWithRandom() async {
        Map<String, String> kvs = await settings.storage.readAll();

        for (String key in kvs.keys) {
            await settings.storage.write(
                key: key,
                value: generateRandomPassword(length: kvs[key].length),
            );
        }
    }

    Future<void> reinitAll() async {
        loginsInited = false;
        bankCardsInited = false;
        documentsInited = false;
        settingsInited = false;

        await initLogins();
        await initBankCards();
        await initDocuments();
        await initSettings();

        notifyListeners();
    }
}
