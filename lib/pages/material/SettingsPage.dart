import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/pages/material/BasePage.dart';

class SettingsPage extends StatefulWidget {
    @override
    SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends BasePageState<SettingsPage> {
    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initSettings();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: const Text('Settings'),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            if (!model.settingsInited) {
                return buildBodyLoading();
            } else {
                return buildSettingsList(model);
            }
        }
    );

    Widget buildBodyLoading() => const Center(
        child: const CircularProgressIndicator(),
    );

    Widget buildSettingsList(AppStateModel model) {
        List<Widget> children = [];

        if (!model.settings.settings.howToCopyPasswordTipHidden) {
            children.add(howToCopyPasswordTipTitle(model));
            children.add(howToCopyPasswordTipImage());
        }

        children.add(rowAbout());
        children.add(rowBiometrics(model));
        children.add(rowPasswordGeneratorStrength(model));
        children.add(rowResetSettings(model));
        children.add(rowPurge(model));

        return ListView(
            semanticChildCount: children.length,
            children: children,
        );
    }

    Widget howToCopyPasswordTipTitle(AppStateModel model) => ListTile(
        key: Key('howToCopyPasswordTipTitle'),
        title: const Text('How to copy password:'),
        trailing: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.grey,
            onPressed: () => hideHowToCopyPasswordTip(model),
        ),
        contentPadding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
    );

    Widget howToCopyPasswordTipImage() => const Image(
        key: Key('howToCopyPasswordTipImage'),
        image: AssetImage('assets/swipe.gif'),
    );

    Widget rowAbout() => ListTile(
        key: Key('rowAbout'),
        leading: const Icon(Icons.info),
        title: const Text('About'),
        onTap: showAbout,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Widget rowResetSettings(AppStateModel model) => ListTile(
        key: Key('rowResetSettings'),
        leading: const Icon(Icons.refresh),
        title: const Text('Reset UI settings'),
        onTap: () => resetSettings(model),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Widget rowPasswordGeneratorStrength(AppStateModel model) {
        final isEnabled = model.settings.settings.useSpecialSymbolsInGeneratedPasswords;

        return ListTile(
            key: Key('rowPasswordGeneratorStrength'),
            leading: const Icon(Icons.enhanced_encryption),
            title: const Text('Use special symbols in generated passwords?'),
            trailing: Switch(
                value: isEnabled,
                onChanged: (value) => setSettingSpecialSymbolsInPasswords(model, value),
            ),
            onTap: () => setSettingSpecialSymbolsInPasswords(model, !isEnabled),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        );
    }

    Widget rowPurge(AppStateModel model) => ListTile(
        key: Key('rowPurge'),
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Erase all data', style: const TextStyle(color: Colors.red)),
        onTap: () => eraseAllData(model),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Widget rowBiometrics(AppStateModel model) {
        final settings = model.settings.settings;

        if (settings.isFaceIdSupported) {
            return rowBiometricsFaceId(model);
        } else if (settings.isTouchIdSupported) {
            return rowBiometricsTouchId(model);
        } else {
            return rowBiometricsNotSupported();
        }
    }

    Widget rowBiometricsNotSupported() => ListTile(
        key: Key('rowBiometricsNotSupported'),
        leading: const Icon(Icons.fingerprint),
        title: const Text('FaceId and TouchId are not supported on this device'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        enabled: false,
    );

    Widget rowBiometricsFaceId(AppStateModel model) {
        final isEnabled = model.settings.settings.isFaceIdEnabled;

        return ListTile(
            key: Key('rowBiometricsFaceId'),
            leading: const Icon(Icons.face),
            title: isEnabled ?
                const Text('Face ID is enabled') :
                const Text('Enable Face ID?'),
            subtitle: isEnabled ?
                const Text('Tap to disable') :
                const Text('On every time you open the app'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            trailing: Switch(
                value: isEnabled,
                onChanged: (value) => setSettingIsFaceIdEnabled(model, value),
            ),
            onTap: () => setSettingIsFaceIdEnabled(model, !isEnabled),
        );
    }

    Widget rowBiometricsTouchId(AppStateModel model) {
        final isEnabled = model.settings.settings.isTouchIdEnabled;

        return ListTile(
            key: Key('rowBiometricsTouchId'),
            leading: const Icon(Icons.fingerprint),
            title: isEnabled ?
                const Text('Touch ID is enabled') :
                const Text('Enable Touch ID?'),
            subtitle: isEnabled ?
                const Text('Tap to disable') :
                const Text('On every time you open the app'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            trailing: Switch(
                value: isEnabled,
                onChanged: (value) => setSettingIsTouchIdEnabled(model, value),
            ),
            onTap: () => setSettingIsTouchIdEnabled(model, !isEnabled),
        );
    }

    void resetSettings(AppStateModel model) => confirm(
        title: 'Reset UI settings?',
        message: 'Other sensitive data will remain unchanged',
        onAccept: () => resetSettingsConfirmed(model),
    );

    Future<void> resetSettingsConfirmed(AppStateModel model) async {
        await model.resetAndSaveSettings();
    }

    void showAbout() => alert(
        title: 'Passwords',
        message: 'All data is encrypted with strong symmetric cryptography (aes-256-cfb)\n\nBefore removal, data is replaced with random noise bytes to make it impossible to restore directly by scanning the storage with special tools',
    );

    void eraseAllData(AppStateModel model) => confirm(
        title: 'Warning: are you sure?',
        message: 'All your saved logins, passwords, bank cards, documents, attached photos and UI settings will be permanently removed from this device\n\nMake sure you have a backup',
        titleIsCritical: true,
        isAcceptCritical: true,
        onAccept: () => eraseAllDataConfirmed(model),
    );

    Future<void> eraseAllDataConfirmed(AppStateModel model) async {
        await model.eraseAllData();
    }

    Future<void> setSettingSpecialSymbolsInPasswords(AppStateModel model, bool newValue) async {
        model.settings.settings.useSpecialSymbolsInGeneratedPasswords = newValue;
        await model.saveSettings();
    }

    Future<void> setSettingIsFaceIdEnabled(AppStateModel model, bool newValue) async {
        model.settings.settings.isFaceIdEnabled = newValue;
        await model.saveSettings();
    }

    Future<void> setSettingIsTouchIdEnabled(AppStateModel model, bool newValue) async {
        model.settings.settings.isTouchIdEnabled = newValue;
        await model.saveSettings();
    }

    Future<void> hideHowToCopyPasswordTip(AppStateModel model) async {
        model.settings.settings.howToCopyPasswordTipHidden = true;
        await model.saveSettings();
    }
}
