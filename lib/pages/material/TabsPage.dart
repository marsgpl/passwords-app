import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/widgets/PageMessage.dart';
import 'package:passwords/pages/material/SettingsPage.dart';

class TabsPage extends StatefulWidget {
    static final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

    @override
    TabsPageState createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> with WidgetsBindingObserver {
    int bottomNavBarCurrentIndex = 0;
    bool isInBackground = false;
    DateTime whenGoneToBackground;

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
            if (whenGoneToBackground != null) {
                int secondsFromLastActivity =
                    DateTime.now().difference(whenGoneToBackground).inSeconds;

                whenGoneToBackground = null;

                if (secondsFromLastActivity >= 30) {
                    biometricAuthRetry();
                }
            }

            setState(() {
                isInBackground = false;
            });
        } else { // inactive, paused, ... -> gone to background
            if (whenGoneToBackground == null) {
                whenGoneToBackground = DateTime.now();
            }

            setState(() {
                isInBackground = true;
            });
        }
    }

    @override
    void initState() {
        super.initState();

        WidgetsBinding.instance.addObserver(this);

        final model = Provider.of<AppStateModel>(context, listen: false);

        model.biometricAuth();
    }

    @override
    void dispose() {
        super.dispose();

        WidgetsBinding.instance.removeObserver(this);
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        key: TabsPage.scaffoldKey,
        body: buildBody(),
        bottomNavigationBar: buildBottomNavBar(),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            if (model.isBiometricAuthRequired == null || model.isBiometricAuthSucceed == null) {
                return buildBodyLoading();
            } else if (!model.isBiometricAuthRequired || model.isBiometricAuthSucceed) {
                return buildBodyPages();
            } else if (!model.biometrics.isSupported) {
                return buildBodyBiometricsDisabledButRequired(model);
            } else {
                return buildBodyBiometricsAuthFail(model);
            }
        }
    );

    Widget buildBodyLoading() => Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: const CircularProgressIndicator(),
        ),
    );

    Widget buildBodyPages() {
        switch (bottomNavBarCurrentIndex) {
            case 0: return Scaffold(appBar: AppBar(title:Text('Logins')),body:Center(child:Text('TODO: Logins')));
            case 1: return Scaffold(appBar: AppBar(title:Text('Bank cards')),body:Center(child:Text('TODO: Bank cards')));
            case 2: return Scaffold(appBar: AppBar(title:Text('Documents')),body:Center(child:Text('TODO: Documents')));
            case 3: return SettingsPage();
            default: return null;
        }
    }

    Widget buildBodyBiometricsDisabledButRequired(AppStateModel model) => Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    PageMessage.title('Biometric auth is not available'),
                    PageMessage.paragraph('1. Make sure you have Face ID or Touch ID enabled for this app in system settings'),
                    PageMessage.paragraph('2. Try to lock and then unlock your device, this will reset biometric failure retries count'),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: FlatButton(
                            child: const Text('Try again'),
                            color: PRIMARY_COLOR,
                            textColor: Colors.white,
                            onPressed: biometricAuthRetry,
                        ),
                    ),
                ],
            ),
        ),
    );

    Widget buildBodyBiometricsAuthFail(AppStateModel model) => Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    PageMessage.title('Biometric auth failed'),
                    PageMessage.paragraph('Try again or contact support'),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: FlatButton(
                            child: const Text('Try again'),
                            color: PRIMARY_COLOR,
                            textColor: Colors.white,
                            onPressed: biometricAuthRetry,
                        ),
                    ),
                ],
            ),
        ),
    );

    Future<void> biometricAuthRetry() async {
        final model = Provider.of<AppStateModel>(context, listen: false);
        await model.biometricAuth(reset: true);
    }

    Widget buildBottomNavBar() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            if (model.isBiometricAuthRequired == null || // pending init
                model.isBiometricAuthSucceed == null || // pending auth
                (model.isBiometricAuthRequired && !model.isBiometricAuthSucceed) // failed auth
            ) {
                return buildBottomNavBarEmpty();
            } else {
                return buildBottomNavBarPages();
            }
        }
    );

    Widget buildBottomNavBarPages() => BottomNavigationBar(
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

    Widget buildBottomNavBarEmpty() => BottomNavigationBar(
        items: [
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
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
    );
}
