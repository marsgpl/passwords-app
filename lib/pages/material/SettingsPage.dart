import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/pages/material/BasePage.dart';

const PRIVACY_POLICY_URL = 'https://eki.one/passwords/PrivacyPolicy.html';

class SettingsPage extends StatefulWidget {
    @override
    SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends BasePageState<SettingsPage> {
    @override
    void initState() {
        super.initState();

        final model = Provider.of<AppStateModel>(context, listen: false);

        model.initBiometrics();
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
            if (!model.settings.isInited) {
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

        final conf = model.settings.settings;

        if (!conf.howToCopyPasswordTipHidden) {
            children.add(howToCopyPasswordTipTitle());
            children.add(howToCopyPasswordTipImage());
        }

        children.add(rowAbout());
        children.add(rowBiometrics(model));
        children.add(rowPasswordGeneratorStrength(model));
        children.add(rowDownloadBackup());
        children.add(rowRestoreFromBackup());
        children.add(rowResetUISettings());
        children.add(rowEraseAllData());
        children.add(rowPrivacyPolicy());

        return ListView(
            semanticChildCount: children.length,
            children: children,
        );
    }

    Widget howToCopyPasswordTipTitle() => ListTile(
        key: Key('howToCopyPasswordTipTitle'),
        title: const Text('How to copy password:'),
        trailing: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.grey,
            onPressed: hideHowToCopyPasswordTip,
        ),
        contentPadding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
    );

    Widget howToCopyPasswordTipImage() => const Image(
        key: Key('howToCopyPasswordTipImage'),
        image: AssetImage('assets/swipe.gif'),
        alignment: Alignment.topLeft,
        height: 52,
    );

    Future<void> hideHowToCopyPasswordTip() async {
        final model = Provider.of<AppStateModel>(context, listen: false);
        final conf = model.settings.settings;
        conf.howToCopyPasswordTipHidden = true;
        await model.saveSettings();
    }

    Widget rowAbout() => ListTile(
        key: Key('rowAbout'),
        leading: const Icon(Icons.info),
        title: const Text('About'),
        onTap: showAbout,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    void showAbout() => alert(
        title: APP_TITLE,
        message: 'All stored passwords, bank cards and documents are encrypted with strong symmetric cryptography.',
    );

    Widget rowBiometrics(AppStateModel model) {
        final bio = model.biometrics;
        final conf = model.settings.settings;

        if ((bio.isInited && bio.isFaceIdSupported) || conf.isFaceIdEnabled) {
            return rowBiometricsFaceId(model);
        } else if ((bio.isInited && bio.isTouchIdSupported) || conf.isTouchIdEnabled) {
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
        trailing: IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.grey,
            onPressed: () async {
                await resetBiometrics();
                snack(message: 'Biometrics reloaded');
            },
        ),
    );

    Future<void> resetBiometrics() async {
        final model = Provider.of<AppStateModel>(context, listen: false);
        await model.biometricAuth(reset: true, singleUpdate: true, skipChallenge: true);
    }

    Widget rowBiometricsFaceId(AppStateModel model) {
        final conf = model.settings.settings;
        final isEnabled = conf.isFaceIdEnabled;

        return ListTile(
            key: Key('rowBiometricsFaceId'),
            leading: const Icon(Icons.face),
            title: isEnabled ?
                const Text('Face ID is enabled') :
                const Text('Enable Face ID?'),
            subtitle: isEnabled ?
                const Text('Tap to disable') :
                const Text('For additional protection'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            trailing: Switch(
                value: isEnabled,
                onChanged: (value) => setSettingIsFaceIdEnabled(model, value),
            ),
            onTap: () => setSettingIsFaceIdEnabled(model, !isEnabled),
        );
    }

    Widget rowBiometricsTouchId(AppStateModel model) {
        final conf = model.settings.settings;
        final isEnabled = conf.isTouchIdEnabled;

        return ListTile(
            key: Key('rowBiometricsTouchId'),
            leading: const Icon(Icons.fingerprint),
            title: isEnabled ?
                const Text('Touch ID is enabled') :
                const Text('Enable Touch ID?'),
            subtitle: isEnabled ?
                const Text('Tap to disable') :
                const Text('For additional protection'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            trailing: Switch(
                value: isEnabled,
                onChanged: (value) => setSettingIsTouchIdEnabled(model, value),
            ),
            onTap: () => setSettingIsTouchIdEnabled(model, !isEnabled),
        );
    }

    Future<void> setSettingIsFaceIdEnabled(AppStateModel model, bool enabled) async {
        if (enabled) {
            bool success = await model.biometricAuth(
                singleUpdate: true,
                forceChallenge: true,
            );

            if (!success) {
                await resetBiometrics();

                return alert(
                    title: 'Face ID failed',
                    message: 'Make sure you have Face ID enabled for this app in system settings',
                );
            }
        }

        final conf = model.settings.settings;
        conf.isFaceIdEnabled = enabled;
        await model.saveSettings();
    }

    Future<void> setSettingIsTouchIdEnabled(AppStateModel model, bool enabled) async {
        if (enabled) {
            bool success = await model.biometricAuth(
                singleUpdate: true,
                forceChallenge: true,
            );

            if (!success) {
                await resetBiometrics();

                return alert(
                    title: 'Touch ID failed',
                    message: 'Make sure you have Touch ID enabled for this app in system settings',
                );
            }
        }

        final conf = model.settings.settings;
        conf.isTouchIdEnabled = enabled;
        await model.saveSettings();
    }

    Widget rowPasswordGeneratorStrength(AppStateModel model) {
        final conf = model.settings.settings;
        final isEnabled = conf.useSpecialSymbolsInGeneratedPasswords;

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

    Future<void> setSettingSpecialSymbolsInPasswords(AppStateModel model, bool newValue) async {
        final conf = model.settings.settings;
        conf.useSpecialSymbolsInGeneratedPasswords = newValue;
        await model.saveSettings();
    }

    Widget rowResetUISettings() => ListTile(
        key: Key('rowResetUISettings'),
        leading: const Icon(Icons.refresh),
        title: const Text('Reset interface settings'),
        onTap: resetUISettings,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    void resetUISettings() => confirm(
        title: 'Reset settings?',
        message: 'Only interface settings will be resetted. Other sensitive data like passwords will remain untouched.',
        onAccept: resetSettingsConfirmed,
    );

    Future<void> resetSettingsConfirmed() async {
        final model = Provider.of<AppStateModel>(context, listen: false);
        await model.reinitSettings();
        snack(message: 'Interface settings were resetted');
    }

    Widget rowPrivacyPolicy() => ListTile(
        key: Key('rowPrivacyPolicy'),
        leading: const Icon(Icons.public),
        title: const Text('Privacy Policy'),
        subtitle: const Text('Open in browser'),
        onTap: showPrivacyPolicy,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Future<void> showPrivacyPolicy() async {
        await openUrl(PRIVACY_POLICY_URL);
    }

    Widget rowEraseAllData() => ListTile(
        key: Key('rowEraseAllData'),
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Erase all data', style: const TextStyle(color: Colors.red)),
        onTap: eraseAllData,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );

    Future<void> eraseAllData() => confirm(
        title: 'Warning: are you sure?',
        message: 'All your saved passwords, bank cards, documents, attached photos and interface settings will be permanently removed from this device.\n\nMake sure you have a backup.',
        titleIsCritical: true,
        isAcceptCritical: true,
        onAccept: eraseAllDataConfirmed,
    );

    Future<void> eraseAllDataConfirmed() async {
        final model = Provider.of<AppStateModel>(context, listen: false);
        await model.eraseAllData(silent: true);
        await model.initSettings(silent: true);
        await model.biometricAuth(singleUpdate: true);
        snack(message: 'All data was erased');
    }

    Widget rowDownloadBackup() {
        return ListTile(
            key: Key('rowDownloadBackup'),
            leading: const Icon(Icons.cloud_download),
            title: const Text('Download backup file'),
            subtitle: const Text('File contents will be encrypted'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            onTap: downloadBackup,
        );
    }

    Widget rowRestoreFromBackup() {
        return ListTile(
            key: Key('rowRestoreFromBackup'),
            leading: const Icon(Icons.cloud_upload, color: Colors.red),
            title: const Text('Restore from backup file', style: const TextStyle(color: Colors.red)),
            subtitle: const Text('Warning: it will erase all current data'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            onTap: restoreFromBackup,
        );
    }

    Future<void> downloadBackup() async {
        try {
            final model = Provider.of<AppStateModel>(context, listen: false);

            final tmpDir = await getTemporaryDirectory();
            final bkpFileData = await model.dumpAllDataExceptSettings();
            final bkpFileName = 'passwords-backup.pb';
            final bkpFilePath = '${tmpDir.path}/$bkpFileName';
            final bkpFile = File(bkpFilePath);
            await bkpFile.writeAsString(bkpFileData);

            final params = SaveFileDialogParams(sourceFilePath: bkpFile.path);
            String path = await FlutterFileDialog.saveFile(params: params);

            if (path != null) {
                snack(message: 'File saved');
            }

            await bkpFile.delete();
        } catch (error) {
            alert(message: 'Something went wrong');
            print('error: $error');
        }
    }

    Future<void> restoreFromBackup() => confirm(
        title: 'Warning: are you sure?',
        message: 'Imported backup will erase all your currently saved passwords, bank cards, documents and settings',
        titleIsCritical: true,
        isAcceptCritical: true,
        onAccept: restoreFromBackupConfirmed,
    );

    Future<void> restoreFromBackupConfirmed() async {
        File bkpFile;

        try {
            final model = Provider.of<AppStateModel>(context, listen: false);

            final params = OpenFileDialogParams(
                dialogType: OpenFileDialogType.document,
            );

            String bkpFilePath = await FlutterFileDialog.pickFile(params: params);
            bkpFile = File(bkpFilePath);

            String jsonEncoded = await bkpFile.readAsString();

            await model.restoreFromBackup(jsonEncoded);

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
}
