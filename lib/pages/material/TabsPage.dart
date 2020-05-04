import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:passwords/model/AppStateModel.dart';
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
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initSettings();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        body: buildBody(),
        bottomNavigationBar: buildBottomNavigationBar(),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            if (!model.settingsInited) {
                return buildBodyLoading();
            } else if (model.settings.settings.authenticated == false) {
                return buildBodyNotAuthed();
            } else {
                return buildBodyPages();
            }
        }
    );

    Widget buildBodyLoading() => Scaffold(
        appBar: AppBar(
            title: const Text(''),
        ),
        body: const Center(
            child: const CircularProgressIndicator(),
        ),
    );

    Widget buildBodyNotAuthed() => Scaffold(
        appBar: AppBar(
            title: const Text('Authenticate'),
        ),
        body: const Center(
            child: const Text('Auth failed'),
        ),
    );

    Widget buildBodyPages() {
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
                icon: const Icon(PwdIcons.login),
                title: const Text('Logins'),
            ),
            BottomNavigationBarItem(
                icon: const Icon(PwdIcons.bank_card),
                title: const Text('Bank cards'),
            ),
            BottomNavigationBarItem(
                icon: const Icon(PwdIcons.document),
                title: const Text('Documents'),
            ),
            BottomNavigationBarItem(
                icon: const Icon(PwdIcons.settings),
                title: const Text('Settings'),
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
