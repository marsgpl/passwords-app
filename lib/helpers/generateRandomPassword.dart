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

String generateRandomPassword({
    int length = 20,
    bool useSpecialSymbols = false,
}) {
    final random = Random.secure();
    final dict = useSpecialSymbols ? CHARS_WITH_SPECIAL : CHARS;
    return List.generate(length, (index) => dict[random.nextInt(dict.length)]).join('');
}
