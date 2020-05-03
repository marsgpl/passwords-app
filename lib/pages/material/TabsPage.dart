import 'package:flutter/material.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:passwords/pages/material/LoginsPage.dart';
import 'package:passwords/pages/material/BankCardsPage.dart';
import 'package:passwords/pages/material/DocumentsPage.dart';
import 'package:passwords/pages/material/SettingsPage.dart';

class TabsPage extends StatefulWidget {
    @override
    TabsPageState createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> {
    int bottomNavBarCurrentIndex = 0;

    @override
    Widget build(BuildContext context) => Scaffold(
        body: buildBody(),
        bottomNavigationBar: buildBottomNavigationBar(),
    );

    Widget buildBody() {
        switch (bottomNavBarCurrentIndex) {
            case 0: return LoginsPage();
            case 1: return BankCardsPage();
            case 2: return DocumentsPage();
            case 3: return SettingsPage();
            default: return null;
        }
    }

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
}
