import 'dart:math';

import '../numeral_systems/lexo_numeral_system.dart';
import 'lexo_helper.dart' as utils;

class LexoMagnitude implements Comparable<LexoMagnitude> {
  final LexoNumeralSystem system;
  final List<int> value;

  const LexoMagnitude(this.system, this.value);

  LexoMagnitude operator +(LexoMagnitude other) {
    final int estimatedSize = max(value.length, other.value.length);
    final List<int> result = List.filled(estimatedSize, 0);
    int carry = 0;
    for (int i = 0; i < estimatedSize; ++i) {
      final int lnum = i < value.length ? value[i] : 0;
      final int rnum = i < other.value.length ? other.value[i] : 0;
      int sum = lnum + rnum + carry;
      for (carry = 0; sum >= system.base; sum -= system.base) {
        ++carry;
      }
      result[i] = sum;
    }
    return LexoMagnitude(system, result).withCarry(carry);
  }

  LexoMagnitude operator -(LexoMagnitude other) {
    final LexoMagnitude complement = other.complement(value.length);
    final LexoMagnitude sum = this + complement;
    sum.value[sum.value.length - 1] = 0;
    return sum + LexoMagnitude(system, [1]);
  }

  LexoMagnitude operator *(LexoMagnitude other) {
    final List<int> result = List.filled(value.length + other.value.length, 0);
    for (int li = 0; li < value.length; ++li) {
      for (int ri = 0; ri < other.value.length; ++ri) {
        final int resultIndex = li + ri;
        for (result[resultIndex] += value[li] * other.value[ri];
            result[resultIndex] >= system.base;
            result[resultIndex] -= system.base) {
          ++result[resultIndex + 1];
        }
      }
    }
    return LexoMagnitude(system, result);
  }

  LexoMagnitude withCarry(int carry) {
    if (carry > 0) {
      final List<int> extendedMag = List.filled(value.length + 1, 0);
      utils.arrayCopy(value, 0, extendedMag, 0, value.length);
      extendedMag[extendedMag.length - 1] = carry;
      return LexoMagnitude(system, extendedMag);
    }
    return this;
  }

  LexoMagnitude complement(int digits) {
    if (digits <= 0) {
      throw AssertionError('Expected at least 1 digit');
    }
    final List<int> nmag = List.filled(digits, system.base - 1);
    for (int i = 0; i < value.length; ++i) {
      nmag[i] = system.base - 1 - value[i];
    }
    return LexoMagnitude(system, nmag);
  }

  @override
  int compareTo(LexoMagnitude other) {
    if (value.length < other.value.length) {
      return -1;
    }
    if (value.length > other.value.length) {
      return 1;
    }
    for (int i = value.length - 1; i >= 0; --i) {
      if (value[i] < other.value[i]) {
        return -1;
      }
      if (value[i] > other.value[i]) {
        return 1;
      }
    }
    return 0;
  }
}
