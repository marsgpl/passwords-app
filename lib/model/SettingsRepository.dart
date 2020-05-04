import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/helpers/generateRandomPassword.dart';
import 'package:passwords/helpers/reverse.dart';
import 'package:passwords/model/Settings.dart';
import 'package:passwords/constants.dart';

class SettingsRepository {
    final FlutterSecureStorage storage;
    Settings settings;
    String storageKey = 'Settings';

    SettingsRepository():
        storage = FlutterSecureStorage();

    Future<void> init() async {
        String rawSettings = await storage.read(key: storageKey);

        if (rawSettings != null) {
            settings = Settings.fromJson(json.decode(rawSettings));

            await initMasterkey();
        } else {
            await resetAndSave();
        }

        await initBiometrics();
    }

    Future<void> initBiometrics() async {
        LocalAuthentication localAuth = LocalAuthentication();
        List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();

        settings.localAuth = localAuth;
        settings.isFaceIdSupported = availableBiometrics.contains(BiometricType.face);
        settings.isTouchIdSupported = availableBiometrics.contains(BiometricType.fingerprint);
    }

    Future<void> save() async {
        String key = storageKey;
        String value = json.encode(settings.toJson());

        await storage.write(key: key, value: value);
    }

    Future<void> resetAndSave() async {
        settings = Settings();

        await save();
        await init();
    }

    Future<void> ensureDecoys() async {
        for (int i = 0, c = MASTERKEY_DECOY_STORAGE_KEYS.length; i < c; ++i) {
            String key = MASTERKEY_DECOY_STORAGE_KEYS[i];
            String value = await storage.read(key: key);

            if (value == null) {
                value = generateRandomPassword(length: i.isEven ?
                    MASTERKEY_LENGTH :
                    MASTERKEY_INIT_VECTOR_LENGTH);

                await storage.write(key: key, value: value);
            }
        }
    }

    Future<void> initMasterkey() async {
        await ensureDecoys();

        String masterkey = await storage.read(key: MASTERKEY_STORAGE_KEY);

        if (masterkey == null) {
            masterkey = reverse(generateRandomPassword(length: MASTERKEY_LENGTH));
            await storage.write(key: MASTERKEY_STORAGE_KEY, value: masterkey);
        }

        String masterkeyInitVector = await storage.read(key: MASTERKEY_INIT_VECTOR_STORAGE_KEY);

        if (masterkeyInitVector == null) {
            masterkeyInitVector = reverse(generateRandomPassword(length: MASTERKEY_INIT_VECTOR_LENGTH));
            await storage.write(key: MASTERKEY_INIT_VECTOR_STORAGE_KEY, value: masterkeyInitVector);
        }

        settings.masterkey = reverse(masterkey);
        settings.masterkeyInitVector = reverse(masterkeyInitVector);
        settings.key = Key.fromUtf8(settings.masterkey);
        settings.iv = IV.fromUtf8(settings.masterkeyInitVector);
        settings.encrypter = Encrypter(AES(settings.key));
    }

    String encrypt(String text) {
        return settings.encrypter.encrypt(text, iv: settings.iv).base64;
    }

    String decrypt(String textBase64) {
        return settings.encrypter.decrypt64(textBase64, iv: settings.iv);
    }
}
