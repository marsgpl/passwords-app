import 'package:flutter/material.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/pages/material/BasePage.dart';
import 'package:provider/provider.dart';

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
        children.add(rowResetSettings(model));
        children.add(rowPasswordGeneratorStrength(model));
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

    Widget rowPasswordGeneratorStrength(AppStateModel model) => ListTile(
        key: Key('rowPasswordGeneratorStrength'),
        leading: const Icon(Icons.enhanced_encryption),
        title: const Text('Use special symbols in generated passwords?'),
        trailing: Switch(
            value: model.settings.settings.useSpecialSymbolsInGeneratedPasswords,
            onChanged: (value) {
                model.settings.settings.useSpecialSymbolsInGeneratedPasswords = value;
                model.saveSettings();
            },
        ),
        onTap: () {
            model.settings.settings.useSpecialSymbolsInGeneratedPasswords =
                !model.settings.settings.useSpecialSymbolsInGeneratedPasswords;
            model.saveSettings();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Widget rowPurge(AppStateModel model) => ListTile(
        key: Key('rowPurge'),
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Erase all data', style: const TextStyle(color: Colors.red)),
        onTap: () => eraseAllData(model),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Future<void> hideHowToCopyPasswordTip(AppStateModel model) async {
        model.settings.settings.howToCopyPasswordTipHidden = true;
        await model.saveSettings();
    }

    void resetSettings(AppStateModel model) => confirm(
        title: 'Reset UI settings?',
        message: 'Other sensitive data will remain unchanged',
        isAcceptCritical: true,
        onAccept: () => resetSettingsConfirmed(model),
    );

    Future<void> resetSettingsConfirmed(AppStateModel model) async {
        await model.resetAndSaveSettings();
    }

    void showAbout() => alert(
        title: 'Passwords',
        message: 'All data is encrypted with strong symmetric cryptography (aes-256-cfb)',
    );

    void eraseAllData(AppStateModel model) => confirm(
        title: 'Warning: are you sure?',
        message: 'All your saved passwords and other data will be permanently removed from this device',
        isAcceptCritical: true,
        onAccept: () => eraseAllDataConfirmed(model),
    );

    Future<void> eraseAllDataConfirmed(AppStateModel model) async {
        await model.eraseAllData();
    }
}
