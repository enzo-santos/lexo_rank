abstract class LexoNumeralSystem {
  int get base;

  String get positiveChar;

  String get negativeChar;

  String get radixPointChar;

  int toDigit(String var1);

  String toChar(int var1);
}
