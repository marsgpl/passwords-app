import 'package:flutter/foundation.dart' as foundation;
import 'package:passwords/model/Login.dart';
import 'package:passwords/model/BankCard.dart';
import 'package:passwords/model/Document.dart';
import 'package:passwords/model/LoginsRepository.dart';
import 'package:passwords/model/BankCardsRepository.dart';
import 'package:passwords/model/DocumentsRepository.dart';

class AppStateModel extends foundation.ChangeNotifier {
    final LoginsRepository logins = LoginsRepository();
    final BankCardsRepository bankCards = BankCardsRepository();
    final DocumentsRepository documents = DocumentsRepository();

    final searchSplit = new RegExp('[ ,\n\r\t]+');

    bool loginsInited = false;
    bool bankCardsInited = false;
    bool documentsInited = false;

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

        await logins.initAll();

        filterLoginsVisibleIds();

        loginsInited = true;

        notifyListeners();
    }

    Future<void> initBankCards() async {
        if (bankCardsInited) return;

        await bankCards.initAll();

        // filterBankCardsVisibleIds();

        bankCardsInited = true;

        notifyListeners();
    }

    Future<void> initDocuments() async {
        if (documentsInited) return;

        await documents.initAll();

        // filterDocumentsVisibleIds();

        documentsInited = true;

        notifyListeners();
    }

    Future<void> unlockBankCardsPage() async {
        bankCards.settings['unlocked'] = true;
        await bankCards.saveSettings();
        notifyListeners();
    }

    Future<void> unlockDocumentsPage() async {
        documents.settings['unlocked'] = true;
        await documents.saveSettings();
        notifyListeners();
    }
}
