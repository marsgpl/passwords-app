import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwords/helpers/generateRandomPassword.dart';
import 'package:passwords/helpers/reverse.dart';

const SYMMETRIC_KEY_STORAGE_KEY = 'Stage2Seed';
const SYMMETRIC_KEY_LENGTH = 32;
const SYMMETRIC_KEY_INIT_VECTOR_STORAGE_KEY = 'SessionCookie';
const SYMMETRIC_KEY_INIT_VECTOR_LENGTH = 16;
const DECOY_STORAGE_KEYS = [
    'InitSeed',
    'Stage1Seed',
    'Stage3Seed',
    'SymmetricKey',
    'InitVector',
];

class Cryptography {
    final storage = FlutterSecureStorage();
    String symmetricKey;
    String symmetricKeyInitVector;
    Encrypter encrypter;
    Key key;
    IV iv;

    bool isInited = false;

    Future<void> init(Map<String, String> localStorageInitialData) async {
        isInited = true;

        await Future.wait([
            initDecoys(localStorageInitialData),
            initEncrypter(localStorageInitialData),
        ]);
    }

    Future<void> initDecoys(Map<String, String> localStorageInitialData) async {
        final List<Future<void>> tasks = [];

        for (int i = 0, c = DECOY_STORAGE_KEYS.length; i < c; ++i) {
            final key = DECOY_STORAGE_KEYS[i];

            if (localStorageInitialData[key] == null) {
                final value = generateRandomPassword(length: i.isEven ?
                    SYMMETRIC_KEY_LENGTH :
                    SYMMETRIC_KEY_INIT_VECTOR_LENGTH);

                tasks.add(storage.write(key: key, value: value));
            }
        }

        if (tasks.length > 0) {
            await Future.wait(tasks);
        }
    }

    Future<void> initEncrypter(Map<String, String> localStorageInitialData) async {
        final List<Future<void>> tasks = [];

        symmetricKey = localStorageInitialData[SYMMETRIC_KEY_STORAGE_KEY];
        symmetricKeyInitVector = localStorageInitialData[SYMMETRIC_KEY_INIT_VECTOR_STORAGE_KEY];

        if (symmetricKey == null) {
            symmetricKey = generateRandomPassword(length: SYMMETRIC_KEY_LENGTH);
            tasks.add(storage.write(key: SYMMETRIC_KEY_STORAGE_KEY, value: symmetricKey));
        }

        if (symmetricKeyInitVector == null) {
            symmetricKeyInitVector = generateRandomPassword(length: SYMMETRIC_KEY_INIT_VECTOR_LENGTH);
            tasks.add(storage.write(key: SYMMETRIC_KEY_INIT_VECTOR_STORAGE_KEY, value: symmetricKeyInitVector));
        }

        key = Key.fromUtf8(reverse(symmetricKey));
        iv = IV.fromUtf8(reverse(symmetricKeyInitVector));

        encrypter = Encrypter(AES(key));

        if (tasks.length > 0) {
            await Future.wait(tasks);
        }
    }

    String encrypt(String text) {
        return encrypter.encrypt(text, iv: iv).base64;
    }

    String decrypt(String textBase64) {
        return encrypter.decrypt64(textBase64, iv: iv);
    }
}
