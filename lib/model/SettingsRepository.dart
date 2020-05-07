import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/model/Settings.dart';

class SettingsRepository {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Settings settings;
    String storageKey = 'Settings';

    bool get isInited => settings != null;

    Future<void> init(Map<String, String> localStorageInitialData) async {
        final List<Future<void>> tasks = [];

        try {
            settings = Settings.fromJson(json.decode(localStorageInitialData[storageKey]));
        } catch (error) {
            tasks.add(reset());

            print('Settings init error: $error');
        }

        if (tasks.length > 0) {
            await Future.wait(tasks);
        }
    }

    Future<void> reset() async {
        settings = Settings();
        await save();
    }

    Future<void> save() async {
        String key = storageKey;
        String value = json.encode(settings.toJson());

        await storage.write(key: key, value: value);
    }
}
