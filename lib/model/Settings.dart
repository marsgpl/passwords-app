import 'package:encrypt/encrypt.dart';
import 'package:local_auth/local_auth.dart';

class Settings {
    Settings();

    bool howToCopyPasswordTipHidden = false;
    bool useSpecialSymbolsInGeneratedPasswords = false;
    bool isFaceIdEnabled = false;
    bool isTouchIdEnabled = false;

    // !!! do not include these in fromJson/toJson:
    String masterkey;
    String masterkeyInitVector;
    Key key;
    IV iv;
    Encrypter encrypter;
    LocalAuthentication localAuth;
    bool isFaceIdSupported;
    bool isTouchIdSupported;
    bool authenticated;
    // !!! end

    @override
    String toString() => '*Settings()';

    Settings.fromJson(Map<String, dynamic> jsonData) :
        howToCopyPasswordTipHidden =
            jsonData['howToCopyPasswordTipHidden'] ?? false,
        useSpecialSymbolsInGeneratedPasswords =
            jsonData['useSpecialSymbolsInGeneratedPasswords'] ?? false,
        isFaceIdEnabled =
            jsonData['isFaceIdEnabled'] ?? false,
        isTouchIdEnabled =
            jsonData['isTouchIdEnabled'] ?? false;

    Map<String, dynamic> toJson() => {
        'howToCopyPasswordTipHidden':
            howToCopyPasswordTipHidden ?? false,
        'useSpecialSymbolsInGeneratedPasswords':
            useSpecialSymbolsInGeneratedPasswords ?? false,
        'isFaceIdEnabled':
            isFaceIdEnabled ?? false,
        'isTouchIdEnabled':
            isTouchIdEnabled ?? false,
    };
}
