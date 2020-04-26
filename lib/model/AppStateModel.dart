import 'package:flutter/foundation.dart' as foundation;
import 'package:passwords/model/Login.dart';
import 'package:passwords/model/LoginsRepository.dart';
import 'package:passwords/model/BankCardsRepository.dart';
import 'package:passwords/model/DocumentsRepository.dart';

class AppStateModel extends foundation.ChangeNotifier {
    LoginsRepository logins = LoginsRepository();
    BankCardsRepository bankCards = BankCardsRepository();
    DocumentsRepository documents = DocumentsRepository();

    bool loginsInited = false;
    bool bankCardsInited = false;
    bool documentsInited = false;

    List<String> loginsVisibleIds;
    List<String> bankCardsVisibleIds;
    List<String> documentsVisibleIds;

    String loginsFilter = '';
    String bankCardsFilter = '';
    String documentsFilter = '';

    bool loginsNotFoundBySearch() =>
        loginsInited &&
        loginsVisibleIds.length == 0 &&
        loginsFilter.length > 0;

    bool loginsNoItems() =>
        loginsInited &&
        loginsVisibleIds.length == 0 &&
        loginsFilter.length == 0;

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

        loginsVisibleIds = logins.items.keys.toList();
        loginsVisibleIds.sort((id1, id2) =>
            logins.items[id1].compareTo(logins.items[id2]));

        loginsInited = true;

        notifyListeners();
    }

    Future<void> initBankCards() async {
        if (bankCardsInited) return;

        await bankCards.initAll();

        bankCardsVisibleIds = bankCards.items.keys.toList();
        bankCardsVisibleIds.sort((id1, id2) =>
            bankCards.items[id1].compareTo(bankCards.items[id2]));

        bankCardsInited = true;

        notifyListeners();
    }

    Future<void> initDocuments() async {
        if (documentsInited) return;

        await documents.initAll();

        documentsVisibleIds = documents.items.keys.toList();
        documentsVisibleIds.sort((id1, id2) =>
            documents.items[id1].compareTo(documents.items[id2]));

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
