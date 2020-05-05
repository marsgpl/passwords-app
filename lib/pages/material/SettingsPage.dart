import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
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
        children.add(rowDownloadBackup(model));
        children.add(rowRestoreFromBackup(model));
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
        final s = model.settings.settings;
        final isEnabled = s.useSpecialSymbolsInGeneratedPasswords;

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
        final s = model.settings.settings;

        if (s.isFaceIdSupported || s.isFaceIdEnabled) {
            return rowBiometricsFaceId(model);
        } else if (s.isTouchIdSupported || s.isTouchIdEnabled) {
            return rowBiometricsTouchId(model);
        } else {
            return rowBiometricsNotSupported();
        }
    }

    Widget rowBiometricsNotSupported() => ListTile(
        key: Key('rowBiometricsNotSupported'),
        leading: const Icon(Icons.fingerprint),
        title: const Text('Biometric auth is not supported or disabled in system settings for this app'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        enabled: false,
    );

    Widget rowBiometricsFaceId(AppStateModel model) {
        final s = model.settings.settings;
        final isEnabled = s.isFaceIdEnabled;

        return ListTile(
            key: Key('rowBiometricsFaceId'),
            leading: const Icon(Icons.face),
            title: isEnabled ?
                const Text('Face ID is enabled') :
                const Text('Enable Face ID protection?'),
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
        final s = model.settings.settings;
        final isEnabled = s.isTouchIdEnabled;

        return ListTile(
            key: Key('rowBiometricsTouchId'),
            leading: const Icon(Icons.fingerprint),
            title: isEnabled ?
                const Text('Touch ID is enabled') :
                const Text('Enable Touch ID protection?'),
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

    Widget rowDownloadBackup(AppStateModel model) {
        return ListTile(
            key: Key('rowDownloadBackup'),
            leading: const Icon(Icons.cloud_download),
            title: const Text('Create backup file'),
            subtitle: const Text('File contents will be encrypted'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            onTap: () => downloadBackup(model),
        );
    }

    Widget rowRestoreFromBackup(AppStateModel model) {
        return ListTile(
            key: Key('rowRestoreFromBackup'),
            leading: const Icon(Icons.cloud_upload, color: Colors.red),
            title: const Text('Restore from backup file', style: const TextStyle(color: Colors.red)),
            subtitle: const Text('Warning: it will erase all current data'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            onTap: () => restoreFromBackup(model),
        );
    }

    Future<void> restoreFromBackup(AppStateModel model) => confirm(
        title: 'Warning: are you sure?',
        message: 'Imported backup will erase all your currently saved logins, bank cards, documents and settings',
        titleIsCritical: true,
        isAcceptCritical: true,
        onAccept: () => restoreFromBackupConfirmed(model),
    );

    Future<void> restoreFromBackupConfirmed(AppStateModel model) async {
        File bkpFile;

        try {
            final params = OpenFileDialogParams(
                dialogType: OpenFileDialogType.document,
            );
            String bkpFilePath = await FlutterFileDialog.pickFile(params: params);
            bkpFile = File(bkpFilePath);
            String jsonEncoded = await bkpFile.readAsString();
            await model.restoreFromBackup(jsonEncoded);
            await model.reinitAll();
            snack(message: 'Restored from backup');
        } catch (error) {
            if (bkpFile != null) {
                alert(message: 'Something went wrong');
                print('error: $error');
            }
        } finally {
            if (bkpFile != null) {
                await bkpFile.delete();
            }
        }
    }

    Future<void> downloadBackup(AppStateModel model) async {
        try {
            final tmpDir = await getTemporaryDirectory();
            final bkpFileData = await model.dumpAllData();
            final bkpFileName = 'passwords-backup.pb';
            final bkpFilePath = '${tmpDir.path}/$bkpFileName';
            final bkpFile = File(bkpFilePath);
            await bkpFile.writeAsString(bkpFileData);

            final params = SaveFileDialogParams(sourceFilePath: bkpFile.path);
            String path = await FlutterFileDialog.saveFile(params: params);

            await bkpFile.delete();

            if (path != null) {
                snack(message: 'File saved');
            }
        } catch (error) {
            alert(message: 'Something went wrong');
            print('error: $error');
        }
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
        message: 'All stored data is encrypted with strong symmetric cryptography (aes-256-cfb)\n\nBefore removal, data is replaced with random noise bytes to make it impossible to restore directly by scanning the storage with special tools',
    );

    Future<void> eraseAllData(AppStateModel model) => confirm(
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

    Future<void> setSettingIsFaceIdEnabled(AppStateModel model, bool enabled) async {
        if (enabled) {
            bool checkSuccess = await model.checkBiometrics();
            if (!checkSuccess) {
                return alert(
                    title: 'Face ID failed',
                    message: 'Make sure you have Face ID enabled for this app in system settings',
                );
            }
        }
        model.settings.settings.isFaceIdEnabled = enabled;
        await model.saveSettings();
    }

    Future<void> setSettingIsTouchIdEnabled(AppStateModel model, bool enabled) async {
        if (enabled) {
            bool checkSuccess = await model.checkBiometrics();
            if (!checkSuccess) {
                return alert(
                    title: 'Touch ID failed',
                    message: 'Make sure you have Touch ID enabled for this app in system settings',
                );
            }
        }
        model.settings.settings.isTouchIdEnabled = enabled;
        await model.saveSettings();
    }

    Future<void> hideHowToCopyPasswordTip(AppStateModel model) async {
        model.settings.settings.howToCopyPasswordTipHidden = true;
        await model.saveSettings();
    }
}
