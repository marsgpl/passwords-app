import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/model/Biometrics.dart';
import 'package:passwords/model/Cryptography.dart';
import 'package:passwords/model/LoginsRepository.dart';
import 'package:passwords/model/BankCardsRepository.dart';
import 'package:passwords/model/DocumentsRepository.dart';
import 'package:passwords/model/SettingsRepository.dart';

class AppStateModel extends foundation.ChangeNotifier {
    final regexpSearchChunkSeparator = new RegExp(r'[ ,\n\r\t]+', multiLine: true);
    final regexpEscapeQuoteForJsonEncode = new RegExp(r'"');

    final storage = FlutterSecureStorage();
    Map<String, String> localStorageInitialData;

    final SettingsRepository settings = SettingsRepository();
    final LoginsRepository logins = LoginsRepository();
    final BankCardsRepository bankCards = BankCardsRepository();
    final DocumentsRepository documents = DocumentsRepository();
    final Biometrics biometrics = Biometrics();
    final Cryptography crypto = Cryptography();

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
        logins.isInited &&
        loginsFilter.length > 0 &&
        loginsVisibleIds.length == 0;

    bool loginsNoItems() =>
        logins.isInited &&
        loginsFilter.length == 0 &&
        loginsVisibleIds.length == 0;

    void onLoginSearch(String searchText) {
        loginsFilter = searchText.trim().toLowerCase();
        loginsFilterChunks = loginsFilter.split(regexpSearchChunkSeparator);
        filterLoginsVisibleIds();
        notifyListeners();
    }

    void filterLoginsVisibleIds() {
        final items = logins.items;
        final searchCache = logins.search;

        if (loginsFilter.length == 0) {
            loginsVisibleIds = items.keys.toList();
        } else if (loginsFilterChunks.length == 1) {
            loginsVisibleIds = items.keys.where((itemId) =>
                searchCache[itemId].contains(loginsFilter)).toList();
        } else {
            loginsVisibleIds = items.keys.where((itemId) {
                final itemSearchCache = searchCache[itemId];
                for (int i = 0, c = loginsFilterChunks.length; i < c; ++i) {
                    if (!itemSearchCache.contains(loginsFilterChunks[i])) return false;
                }
                return true;
            }).toList();
        }

        loginsVisibleIds.sort((id1, id2) =>
            items[id1].compareTo(items[id2]));
    }

    Future<void> addLogin(Login item) async {
        await logins.saveItem(item);

        if (loginsFilter.length > 0) {
            filterLoginsVisibleIds();
            notifyListeners();
        } else {
            loginsVisibleIds.insert(0, item.id);
            notifyListeners();
        }
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

    Future<void> initLocalStorageInitialData() async {
        localStorageInitialData = await storage.readAll();
    }

    Future<void> initCrypto() async {
        if (crypto.isInited) return;
        if (localStorageInitialData == null) await initLocalStorageInitialData();

        await crypto.init(localStorageInitialData);
    }

    Future<void> initBiometrics() async {
        if (biometrics.isInited) return;

        await biometrics.init();
    }

    Future<void> initLogins() async {
        if (logins.isInited) return;
        if (localStorageInitialData == null) await initLocalStorageInitialData();
        if (!crypto.isInited) await initCrypto();

        logins.crypto = crypto;
        await logins.init(localStorageInitialData);

        filterLoginsVisibleIds();
        notifyListeners();
    }

    Future<void> initBankCards() async {
        if (bankCards.isInited) return;
        if (localStorageInitialData == null) await initLocalStorageInitialData();
        if (!crypto.isInited) await initCrypto();

        bankCards.crypto = crypto;
        await bankCards.init(localStorageInitialData);

        // TODO filterBankCardsVisibleIds();
        notifyListeners();
    }

    Future<void> initDocuments() async {
        if (documents.isInited) return;
        if (localStorageInitialData == null) await initLocalStorageInitialData();
        if (!crypto.isInited) await initCrypto();

        documents.crypto = crypto;
        await documents.init(localStorageInitialData);

        // TODO filterDocumentsVisibleIds();
        notifyListeners();
    }

    Future<void> initSettings() async {
        if (settings.isInited) return;
        if (localStorageInitialData == null) await initLocalStorageInitialData();

        await settings.init(localStorageInitialData);

        notifyListeners();
    }

    Future<void> saveSettings() async {
        await settings.save();
    }
}
