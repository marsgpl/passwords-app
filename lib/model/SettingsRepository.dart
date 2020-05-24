import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Settings.dart';

class SettingsRepository {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Settings settings;
    String storageKey = 'Settings';

    bool get isInited => settings != null;

    Future<void> init(Map<String, String> localStorageInitialData) async {
        String settingsJson = localStorageInitialData[storageKey];

        try {
            if (settingsJson != null) {
                settings = Settings.fromJson(json.decode(settingsJson));
            } else {
                await resetAndSaveInitial();
            }
        } catch (error) {
            await resetAndSaveInitial();

            print('Settings init error: $error');
        }
    }

    void reset() {
        settings = null;
    }

    Future<void> resetAndSaveInitial() async {
        settings = Settings();
        await save();
    }

    Future<void> save() async {
        String key = storageKey;
        String value = exportAsJsonString();

        await storage.write(key: key, value: value);
    }

    String exportAsJsonString() => json.encode(settings.toJson());
}
