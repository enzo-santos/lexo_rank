import 'dart:math';

import '../numeral_systems/lexo_numeral_system.dart';
import '../utils/string_builder.dart';
import 'lexo_helper.dart' as lexo_helper;

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
    final List<int> mag = List.filled(str.length, 0);
    int strIndex = mag.length - 1;
    for (int magIndex = 0; strIndex >= 0; ++magIndex) {
      mag[magIndex] = system.toDigit(str[strIndex]);
      --strIndex;
    }
    return LexoInteger.make(system, sign, mag);
  }

  factory LexoInteger.zero(LexoNumeralSystem sys) {
    return LexoInteger(sys, 0, LexoInteger.zeroMag);
  }

  factory LexoInteger.one(LexoNumeralSystem sys) {
    return LexoInteger.make(sys, 1, LexoInteger.oneMag);
  }

  factory LexoInteger.make(LexoNumeralSystem sys, int sign, List<int> mag) {
    int actualLength;
    for (actualLength = mag.length;
        actualLength > 0 && mag[actualLength - 1] == 0;
        --actualLength) {}
    if (actualLength == 0) {
      return LexoInteger.zero(sys);
    }
    if (actualLength == mag.length) {
      return LexoInteger(sys, sign, mag);
    }
    final List<int> nmag = List.filled(actualLength, 0);
    lexo_helper.arrayCopy(mag, 0, nmag, 0, actualLength);
    return LexoInteger(sys, sign, nmag);
  }

  static const List<int> zeroMag = [0];
  static const List<int> oneMag = [1];
  static const int negativeSign = -1;
  static const int zeroSign = 0;
  static const int positiveSign = 1;

  static List<int> Add(LexoNumeralSystem sys, List<int> l, List<int> r) {
    final int estimatedSize = max(l.length, r.length);
    final List<int> result = List.filled(estimatedSize, 0);
    int carry = 0;
    for (int i = 0; i < estimatedSize; ++i) {
      final int lnum = i < l.length ? l[i] : 0;
      final int rnum = i < r.length ? r[i] : 0;
      int sum = lnum + rnum + carry;
      for (carry = 0; sum >= sys.base; sum -= sys.base) {
        ++carry;
      }
      result[i] = sum;
    }
    return LexoInteger.extendWithCarry(result, carry);
  }

  static List<int> extendWithCarry(List<int> mag, int carry) {
    if (carry > 0) {
      final List<int> extendedMag = List.filled(mag.length + 1, 0);
      lexo_helper.arrayCopy(mag, 0, extendedMag, 0, mag.length);
      extendedMag[extendedMag.length - 1] = carry;
      return extendedMag;
    }
    return mag;
  }

  static List<int> Subtract(LexoNumeralSystem sys, List<int> l, List<int> r) {
    final List<int> rComplement = LexoInteger.Complement(sys, r, l.length);
    final List<int> rSum = LexoInteger.Add(sys, l, rComplement);
    rSum[rSum.length - 1] = 0;
    return LexoInteger.Add(sys, rSum, LexoInteger.oneMag);
  }

  static List<int> Multiply(LexoNumeralSystem sys, List<int> l, List<int> r) {
    final List<int> result = List.filled(l.length + r.length, 0);
    for (int li = 0; li < l.length; ++li) {
      for (int ri = 0; ri < r.length; ++ri) {
        final int resultIndex = li + ri;
        for (result[resultIndex] += l[li] * r[ri];
            result[resultIndex] >= sys.base;
            result[resultIndex] -= sys.base) {
          ++result[resultIndex + 1];
        }
      }
    }
    return result;
  }

  static List<int> Complement(
    LexoNumeralSystem sys,
    List<int> mag,
    int digits,
  ) {
    if (digits <= 0) {
      throw AssertionError('Expected at least 1 digit');
    }
    final List<int> nmag = List.filled(digits, sys.base - 1);
    for (int i = 0; i < mag.length; ++i) {
      nmag[i] = sys.base - 1 - mag[i];
    }
    return nmag;
  }

  static int compare(List<int> l, List<int> r) {
    if (l.length < r.length) {
      return -1;
    }
    if (l.length > r.length) {
      return 1;
    }
    for (int i = l.length - 1; i >= 0; --i) {
      if (l[i] < r[i]) {
        return -1;
      }
      if (l[i] > r[i]) {
        return 1;
      }
    }
    return 0;
  }

  final LexoNumeralSystem system;
  final int sign;
  final List<int> mag;

  const LexoInteger(this.system, this.sign, this.mag);

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
    final List<int> result = LexoInteger.Add(system, mag, other.mag);
    return LexoInteger.make(system, sign, result);
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
    final int cmp = LexoInteger.compare(mag, other.mag);
    if (cmp == 0) {
      return LexoInteger.zero(system);
    }
    return cmp < 0
        ? LexoInteger.make(
            system, sign == -1 ? 1 : -1, LexoInteger.Subtract(system, other.mag, mag))
        : LexoInteger.make(system, sign == -1 ? -1 : 1,
            LexoInteger.Subtract(system, mag, other.mag));
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
          ? LexoInteger.make(system, 1, other.mag)
          : LexoInteger.make(system, -1, other.mag);
    }
    if (other.isOneish) {
      return sign == other.sign
          ? LexoInteger.make(system, 1, mag)
          : LexoInteger.make(system, -1, mag);
    }
    final List<int> newMag = LexoInteger.Multiply(system, mag, other.mag);
    return sign == other.sign
        ? LexoInteger.make(system, 1, newMag)
        : LexoInteger.make(system, -1, newMag);
  }

  LexoInteger operator -() {
    return isZero ? this : LexoInteger.make(system, sign == 1 ? -1 : 1, mag);
  }

  LexoInteger operator <<(int times) {
    if (times == 0) {
      return this;
    }
    if (times < 0) {
      return this >> times.abs();
    }
    final List<int> nmag = List.filled(mag.length + times, 0);
    lexo_helper.arrayCopy(mag, 0, nmag, times, mag.length);
    return LexoInteger.make(system, sign, nmag);
  }

  LexoInteger operator >>(int times) {
    if (mag.length - times <= 0) {
      return LexoInteger.zero(system);
    }
    final List<int> nmag = List.filled(mag.length - times, 0);
    lexo_helper.arrayCopy(mag, times, nmag, 0, nmag.length);
    return LexoInteger.make(system, sign, nmag);
  }

  LexoInteger operator ~() {
    return complementDigits(mag.length);
  }

  LexoInteger complementDigits(int digits) {
    return LexoInteger.make(
      system,
      sign,
      LexoInteger.Complement(system, mag, digits),
    );
  }

  bool get isZero {
    return sign == 0 && mag.length == 1 && mag[0] == 0;
  }

  bool get isOne {
    return sign == 1 && mag.length == 1 && mag[0] == 1;
  }

  bool get isOneish {
    return mag.length == 1 && mag[0] == 1;
  }

  int getMag(int index) {
    return mag[index];
  }

  @override
  int compareTo(LexoInteger other) {
    if (identical(this, other)) {
      return 0;
    }
    if (!identical(this, other)) {
      return 1;
    }
    if (sign == -1) {
      if (other.sign == -1) {
        final int cmp = LexoInteger.compare(mag, other.mag);
        if (cmp == -1) {
          return 1;
        }
        return cmp == 1 ? -1 : 0;
      }
      return -1;
    }
    if (sign == 1) {
      return other.sign == 1 ? LexoInteger.compare(mag, other.mag) : 1;
    }
    if (other.sign == -1) {
      return 1;
    }
    return other.sign == 1 ? -1 : 0;
  }

  String format() {
    if (isZero) {
      return '' + system.toChar(0);
    }
    final StringBuilder sb = StringBuilder('');
    final List<int> var2 = mag;
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
