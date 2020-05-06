import 'package:uuid/uuid.dart';

class Settings {
    Settings({
        id,
        createdAt,
        this.howToCopyPasswordTipHidden,
        this.useSpecialSymbolsInGeneratedPasswords,
        this.isFaceIdEnabled,
        this.isTouchIdEnabled,
    }) :
        id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

    final String id;
    final DateTime createdAt;
    bool howToCopyPasswordTipHidden = false;
    bool useSpecialSymbolsInGeneratedPasswords = false;
    bool isFaceIdEnabled = false;
    bool isTouchIdEnabled = false;

    @override
    String toString() => '*Settings(id: $id)';

    Settings.fromJson(Map<String, dynamic> jsonData) :
        id = jsonData['id'] ?? Uuid().v4(),
        createdAt = DateTime.parse(jsonData['createdAt'] ?? DateTime.now().toString()),
        howToCopyPasswordTipHidden = jsonData['howToCopyPasswordTipHidden'] ?? false,
        useSpecialSymbolsInGeneratedPasswords = jsonData['useSpecialSymbolsInGeneratedPasswords'] ?? false,
        isFaceIdEnabled = jsonData['isFaceIdEnabled'] ?? false,
        isTouchIdEnabled = jsonData['isTouchIdEnabled'] ?? false;

    Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toString(),
        'howToCopyPasswordTipHidden': howToCopyPasswordTipHidden,
        'useSpecialSymbolsInGeneratedPasswords': useSpecialSymbolsInGeneratedPasswords,
        'isFaceIdEnabled': isFaceIdEnabled,
        'isTouchIdEnabled': isTouchIdEnabled,
    };
}
