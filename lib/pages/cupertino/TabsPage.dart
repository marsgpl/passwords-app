import 'package:flutter/cupertino.dart';
import 'package:passwords/pages/cupertino/LoginsPage.dart';
import 'package:passwords/pages/cupertino/BankCardsPage.dart';
import 'package:passwords/pages/cupertino/DocumentsPage.dart';
import 'package:passwords/pages/cupertino/SettingsPage.dart';
import 'package:passwords/PwdIcons.dart';

class TabsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
                currentIndex: 0,
                iconSize: 28,
                items: const [
                    BottomNavigationBarItem(
                        title: Text('Logins'),
                        icon: Icon(PwdIcons.login),
                    ),
                    BottomNavigationBarItem(
                        title: Text('Bank cards'),
                        icon: Icon(PwdIcons.bank_card, size: 32),
                    ),
                    BottomNavigationBarItem(
                        title: Text('Documents'),
                        icon: Icon(PwdIcons.document, size: 24),
                    ),
                    BottomNavigationBarItem(
                        title: Text('Settings'),
                        icon: Icon(CupertinoIcons.gear_solid),
                    ),
                ],
            ),
            tabBuilder: (context, index) {
                switch (index) {
                    case 0: return CupertinoTabView(
                        defaultTitle: 'Logins',
                        builder: (context) => LoginsPage(),
                    );
                    case 1: return CupertinoTabView(
                        defaultTitle: 'Bank cards',
                        builder: (context) => BankCardsPage(),
                    );
                    case 2: return CupertinoTabView(
                        defaultTitle: 'Documents',
                        builder: (context) => DocumentsPage(),
                    );
                    case 3: return CupertinoTabView(
                        defaultTitle: 'Settings',
                        builder: (context) => SettingsPage(),
                    );
                    default: return null;
                }
            },
        );
    }
}
