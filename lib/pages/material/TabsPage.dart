import 'package:flutter/material.dart';
import 'package:passwords/widgets/PageMessage.dart';
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
        bottomNavigationBar: buildBottomNavBar(),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            final s = model.settings.settings;

            if (!model.settingsInited) {
                return buildBodyLoading();
            } else if (s.authenticated == false) {
                if (!s.isFaceIdSupported && !s.isTouchIdSupported) {
                    return buildBodyBioIdDisabled(model);
                } else {
                    return buildBodyNotAuthed(model);
                }
            } else {
                return buildBodyPages();
            }
        }
    );

    Widget buildBottomNavBar() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            final s = model.settings.settings;

            if (!model.settingsInited || s.authenticated == false) {
                return buildBottomNavBarContent([
                    BottomNavigationBarItem(
                        icon: Container(),
                        title: Container(),
                    ),
                    BottomNavigationBarItem(
                        icon: Container(),
                        title: Container(),
                    ),
                    BottomNavigationBarItem(
                        icon: Container(),
                        title: Container(),
                    ),
                    BottomNavigationBarItem(
                        icon: Container(),
                        title: Container(),
                    ),
                ]);
            } else {
                return buildBottomNavBarContent(const [
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
                ]);
            }
        }
    );

    Widget buildBodyLoading() => Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: const CircularProgressIndicator(),
        ),
    );

    Widget buildBodyBioIdDisabled(AppStateModel model) => Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    PageMessage.title('Biometric auth is disabled'),
                    PageMessage.paragraph('Make sure you have Face ID or Touch ID enabled for this app in system settings'),
                    PageMessage.paragraph('Try to lock and unlock your phone, it will reset biometric failure retries counter'),
                ],
            ),
        ),
    );

    Widget buildBodyNotAuthed(AppStateModel model) => Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    PageMessage.title('Biometric auth failed'),
                    PageMessage.paragraph('Try again or contact support'),
                    Padding(
                        padding: EdgeInsets.all(5),
                        child: FlatButton(
                            child: const Text('Try again'),
                            color: PRIMARY_COLOR,
                            textColor: Colors.white,
                            onPressed: () {
                                model.settingsInited = false;
                                model.initSettings();
                            },
                        ),
                    ),
                ],
            ),
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

    Widget buildBottomNavBarContent(List<BottomNavigationBarItem> items) =>
        BottomNavigationBar(
            items: items,
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
