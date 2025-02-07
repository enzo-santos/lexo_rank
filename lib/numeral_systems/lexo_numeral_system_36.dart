import 'lexo_numeral_system.dart';

class LexoNumeralSystem36 implements LexoNumeralSystem {
  static const List<String> digits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];

  const LexoNumeralSystem36();

  @override
  int get base {
    return 36;
  }

  @override
  String get positiveChar {
    return '+';
  }

  @override
  String get negativeChar {
    return '-';
  }

  @override
  String get radixPointChar {
    return ':';
  }

  @override
  int toDigit(String ch) {
    if (ch.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
      return ch.codeUnitAt(0) - 48;
    }
    if (ch.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
      return ch.codeUnitAt(0) - 97 + 10;
    }
    throw AssertionError('Not valid digit: $ch');
  }

  @override
  String toChar(int digit) {
    return digits[digit];
  }
}
