import 'package:lexo_rank/lexo_rank/lexo_magnitude.dart';

import '../numeral_systems/lexo_numeral_system.dart';
import '../utils/string_builder.dart';
import 'lexo_helper.dart' as utils;

class LexoInteger implements Comparable<LexoInteger> {
  factory LexoInteger.parse(String strFull, LexoNumeralSystem system) {
    String str = strFull;
    int sign = 1;
    if (strFull.indexOf(system.positiveChar) == 0) {
      str = strFull.substring(1);
    } else if (strFull.indexOf(system.negativeChar) == 0) {
      str = strFull.substring(1);
      sign = -1;
    }
    final List<int> magnitude = List.filled(str.length, 0);
    int strIndex = magnitude.length - 1;
    for (int magIndex = 0; strIndex >= 0; ++magIndex) {
      magnitude[magIndex] = system.toDigit(str[strIndex]);
      --strIndex;
    }
    return LexoInteger.make(LexoMagnitude(system, magnitude), sign);
  }

  factory LexoInteger.zero(LexoNumeralSystem sys) {
    return LexoInteger(LexoMagnitude(sys, [0]), sign: 0);
  }

  factory LexoInteger.one(LexoNumeralSystem sys) {
    return LexoInteger(LexoMagnitude(sys, [1]), sign: 1);
  }

  factory LexoInteger.make(LexoMagnitude magnitude, int sign) {
    int actualLength;
    for (actualLength = magnitude.value.length;
        actualLength > 0 && magnitude.value[actualLength - 1] == 0;
        --actualLength) {}
    if (actualLength == 0) {
      return LexoInteger.zero(magnitude.system);
    }
    if (actualLength == magnitude.value.length) {
      return LexoInteger(magnitude, sign: sign);
    }
    final List<int> nmag = List.filled(actualLength, 0);
    utils.arrayCopy(magnitude.value, 0, nmag, 0, actualLength);
    return LexoInteger(LexoMagnitude(magnitude.system, nmag), sign: sign);
  }

  static const int negativeSign = -1;
  static const int zeroSign = 0;
  static const int positiveSign = 1;

  final LexoMagnitude magnitude;
  final int sign;

  const LexoInteger(this.magnitude, {required this.sign});

  LexoNumeralSystem get system => magnitude.system;

  LexoInteger copyWith({int? sign}) {
    return LexoInteger(magnitude, sign: sign ?? this.sign);
  }

  LexoInteger operator +(LexoInteger other) {
    checkSystem(other);
    if (isZero) {
      return other;
    }
    if (other.isZero) {
      return this;
    }
    if (sign != other.sign) {
      LexoInteger pos;
      if (sign == -1) {
        pos = -this;
        final LexoInteger val = pos - other;
        return -val;
      }
      pos = -other;
      return this - pos;
    }
    return LexoInteger.make(magnitude + other.magnitude, sign);
  }

  LexoInteger operator -(LexoInteger other) {
    checkSystem(other);
    if (isZero) {
      return -other;
    }
    if (other.isZero) {
      return this;
    }
    if (sign != other.sign) {
      LexoInteger negate;
      if (sign == -1) {
        negate = -this;
        final LexoInteger sum = negate + other;
        return -sum;
      }
      negate = -other;
      return this + negate;
    }
    final int cmp = magnitude.compareTo(other.magnitude);
    if (cmp == 0) {
      return LexoInteger.zero(system);
    }
    return cmp < 0
        ? LexoInteger.make(other.magnitude - magnitude, sign == -1 ? 1 : -1)
        : LexoInteger.make(magnitude - other.magnitude, sign == -1 ? -1 : 1);
  }

  LexoInteger operator *(LexoInteger other) {
    checkSystem(other);
    if (isZero) {
      return this;
    }
    if (other.isZero) {
      return other;
    }
    if (isOneish) {
      return sign == other.sign
          ? LexoInteger.make(other.magnitude, 1)
          : LexoInteger.make(other.magnitude, -1);
    }
    if (other.isOneish) {
      return sign == other.sign
          ? LexoInteger.make(magnitude, 1)
          : LexoInteger.make(magnitude, -1);
    }
    final LexoMagnitude newMag = magnitude * other.magnitude;
    return sign == other.sign
        ? LexoInteger.make(newMag, 1)
        : LexoInteger.make(newMag, -1);
  }

  LexoInteger operator -() {
    return isZero ? this : LexoInteger.make(magnitude, sign == 1 ? -1 : 1);
  }

  LexoInteger operator <<(int times) {
    if (times == 0) {
      return this;
    }
    if (times < 0) {
      return this >> times.abs();
    }
    final List<int> nmag = List.filled(magnitude.value.length + times, 0);
    utils.arrayCopy(magnitude.value, 0, nmag, times, magnitude.value.length);
    return LexoInteger.make(LexoMagnitude(system, nmag), sign);
  }

  LexoInteger operator >>(int times) {
    if (magnitude.value.length - times <= 0) {
      return LexoInteger.zero(system);
    }
    final List<int> nmag = List.filled(magnitude.value.length - times, 0);
    utils.arrayCopy(magnitude.value, times, nmag, 0, nmag.length);
    return LexoInteger.make(LexoMagnitude(system, nmag), sign);
  }

  LexoInteger operator ~() {
    return complementDigits(magnitude.value.length);
  }

  LexoInteger complementDigits(int digits) {
    return LexoInteger.make(magnitude.complement(digits), sign);
  }

  bool get isZero {
    return sign == 0 && magnitude.value.length == 1 && magnitude.value[0] == 0;
  }

  bool get isOne {
    return sign == 1 && magnitude.value.length == 1 && magnitude.value[0] == 1;
  }

  bool get isOneish {
    return magnitude.value.length == 1 && magnitude.value[0] == 1;
  }

  int getMag(int index) {
    return magnitude.value[index];
  }

  @override
  int compareTo(LexoInteger other) {
    if (identical(this, other)) {
      return 0;
    }
    if (sign == -1) {
      if (other.sign == -1) {
        final int cmp = magnitude.compareTo(other.magnitude);
        if (cmp == -1) {
          return 1;
        }
        return cmp == 1 ? -1 : 0;
      }
      return -1;
    }
    if (sign == 1) {
      return other.sign == 1 ? magnitude.compareTo(other.magnitude) : 1;
    }
    if (other.sign == -1) {
      return 1;
    }
    return other.sign == 1 ? -1 : 0;
  }

  String format() {
    if (isZero) {
      return system.toChar(0);
    }
    final StringBuilder sb = StringBuilder('');
    final List<int> var2 = magnitude.value;
    final int var3 = var2.length;
    for (int var4 = 0; var4 < var3; ++var4) {
      final int digit = var2[var4];
      sb.insert(0, system.toChar(digit));
    }
    if (sign == -1) {
      sb.insert(0, system.negativeChar);
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexoInteger &&
          runtimeType == other.runtimeType &&
          system.base == other.system.base &&
          compareTo(other) == 0;

  @override
  int get hashCode => system.base.hashCode ^ sign.hashCode;

  @override
  String toString() {
    return format();
  }

  void checkSystem(LexoInteger other) {
    if (system.base != other.system.base) {
      throw AssertionError('Expected numbers of same numeral sys');
    }
  }
}
