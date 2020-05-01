import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:provider/provider.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/pages/material/LoginsPage.dart';
import 'package:passwords/pages/material/BankCardsPage.dart';
import 'package:passwords/pages/material/DocumentsPage.dart';
import 'package:passwords/pages/material/SettingsPage.dart';
import 'package:passwords/pages/material/AddLoginPage.dart';

class TabsPage extends StatefulWidget {
    @override
    TabsPageState createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> {
    int bottomNavBarCurrentIndex = 0;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: buildAppBar(),
            body: buildBody(),
            bottomNavigationBar: buildBottomNavigationBar(),
        );
    }

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            switch (bottomNavBarCurrentIndex) {
                case 0: return LoginsPage();
                case 1: return BankCardsPage();
                case 2: return DocumentsPage();
                case 3: return SettingsPage();
                default: return null;
            }
        }
    );

    Widget buildAppBar() {
        switch (bottomNavBarCurrentIndex) {
            case 0: return buildLoginsAppBar();
            case 1: return buildBankCardsAppBar();
            case 2: return buildDocumentsAppBar();
            case 3: return buildSettingsAppBar();
            default: return null;
        }
    }

    Widget buildLoginsAppBar() => AppBar(
        title: const Text('Logins'),
        actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () => gotoAddLoginPage(context),
            ),
        ],
    );

    Widget buildBankCardsAppBar() => AppBar(
        title: const Text('Bank cards'),
    );

    Widget buildDocumentsAppBar() => AppBar(
        title: const Text('Documents'),
    );

    Widget buildSettingsAppBar() => AppBar(
        title: const Text('Settings'),
    );

    Widget buildBottomNavigationBar() => BottomNavigationBar(
        items: const [
            BottomNavigationBarItem(
                icon: Icon(PwdIcons.login),
                title: Text('Logins'),
            ),
            BottomNavigationBarItem(
                icon: Icon(PwdIcons.bank_card),
                title: Text('Bank cards'),
            ),
            BottomNavigationBarItem(
                icon: Icon(PwdIcons.document),
                title: Text('Documents'),
            ),
            BottomNavigationBarItem(
                icon: Icon(PwdIcons.settings),
                title: Text('Settings'),
            ),
        ],
        onTap: (index) => setState(() {
            bottomNavBarCurrentIndex = index;
        }),
        currentIndex: bottomNavBarCurrentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
    );

    void gotoAddLoginPage(BuildContext context) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddLoginPage(),
            ),
        );
    }
}
