import 'dart:math';

const CHARS = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

const CHARS_WITH_SPECIAL = [
    ...CHARS,
    '!', '@', '#', '\$', '%', '^', '&', '*', '(', ')',
    '_', '+', '=', '_', '~', '<', '>', '?', '/', '|',
];

const SEPS = [];

String generateRandomPassword({
    int length = 20,
    bool useSpecialSymbols = false,
}) {
    final random = Random.secure();

    return useSpecialSymbols ?
        List.generate(length, (index) =>
            CHARS_WITH_SPECIAL[random.nextInt(CHARS_WITH_SPECIAL.length)]).join('') :
        List.generate(length, (index) =>
            CHARS[random.nextInt(CHARS.length)]).join('');
}
