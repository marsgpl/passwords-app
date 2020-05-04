import 'package:encrypt/encrypt.dart';

class Settings {
    Settings();

    bool howToCopyPasswordTipHidden = false;
    bool useSpecialSymbolsInGeneratedPasswords = false;

    // !!! do not include these in fromJson/toJson:
    String masterkey;
    String masterkeyInitVector;
    Key key;
    IV iv;
    Encrypter encrypter;
    // !!! end

    @override
    String toString() => '*Settings()';

    Settings.fromJson(Map<String, dynamic> jsonData) :
        howToCopyPasswordTipHidden =
            jsonData['howToCopyPasswordTipHidden'] ?? false,
        useSpecialSymbolsInGeneratedPasswords =
            jsonData['useSpecialSymbolsInGeneratedPasswords'] ?? false;

    Map<String, dynamic> toJson() => {
        'howToCopyPasswordTipHidden':
            howToCopyPasswordTipHidden ?? false,
        'useSpecialSymbolsInGeneratedPasswords':
            useSpecialSymbolsInGeneratedPasswords ?? false,
    };
}
