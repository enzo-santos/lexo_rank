import '../numeral_systems/lexo_numeral_system.dart';
import '../utils/string_builder.dart';
import 'lexo_integer.dart';

class LexoDecimal implements Comparable<LexoDecimal> {
  factory LexoDecimal.half(LexoNumeralSystem sys) {
    final int mid = (sys.base / 2).round() | 0;
    return LexoDecimal.make(LexoInteger.make(sys, 1, [mid]), 1);
  }

  factory LexoDecimal.parse(String str, LexoNumeralSystem system) {
    final int partialIndex = str.indexOf(system.radixPointChar);
    if (str.lastIndexOf(system.radixPointChar) != partialIndex) {
      throw AssertionError('More than one ' + system.radixPointChar);
    }
    if (partialIndex < 0) {
      return LexoDecimal.make(LexoInteger.parse(str, system), 0);
    }
    final String intStr =
        str.substring(0, partialIndex) + str.substring(partialIndex + 1);
    return LexoDecimal.make(
        LexoInteger.parse(intStr, system), str.length - 1 - partialIndex);
  }

  factory LexoDecimal.from(LexoInteger integer) {
    return LexoDecimal.make(integer, 0);
  }

  factory LexoDecimal.make(LexoInteger integer, int sig) {
    if (integer.isZero) {
      return LexoDecimal(integer, 0);
    }
    int zeroCount = 0;
    for (int i = 0; i < sig && integer.getMag(i) == 0; ++i) {
      ++zeroCount;
    }
    final LexoInteger newInteger = integer >> zeroCount;
    final int newSig = sig - zeroCount;
    return LexoDecimal(newInteger, newSig);
  }

  final LexoInteger mag;
  final int scale;

  const LexoDecimal(this.mag, this.scale);

  LexoNumeralSystem get system {
    return mag.system;
  }

  LexoDecimal operator +(LexoDecimal other) {
    LexoInteger tmag = mag;
    int tsig = scale;
    LexoInteger omag = other.mag;
    int osig;
    for (osig = other.scale; tsig < osig; ++tsig) {
      tmag <<= 1;
    }
    while (tsig > osig) {
      omag <<= 1;
      ++osig;
    }
    return LexoDecimal.make(tmag + omag, tsig);
  }

  LexoDecimal operator -(LexoDecimal other) {
    LexoInteger thisMag = mag;
    int thisSig = scale;
    LexoInteger otherMag = other.mag;
    int otherSig;
    for (otherSig = other.scale; thisSig < otherSig; ++thisSig) {
      thisMag <<= 1;
    }
    while (thisSig > otherSig) {
      otherMag <<= 1;
      ++otherSig;
    }
    return LexoDecimal.make(thisMag - otherMag, thisSig);
  }

  LexoDecimal operator *(LexoDecimal other) {
    return LexoDecimal.make(mag * other.mag, scale + other.scale);
  }

  LexoInteger floor() {
    return mag >> scale;
  }

  LexoInteger ceil() {
    if (isExact) {
      return mag;
    }
    final LexoInteger f = floor();
    return f + LexoInteger.one(f.system);
  }

  bool get isExact {
    if (scale == 0) {
      return true;
    }
    for (int i = 0; i < scale; ++i) {
      if (mag.getMag(i) != 0) {
        return false;
      }
    }
    return true;
  }

  LexoDecimal withScale(int nsig, [bool ceiling = false]) {
    if (nsig >= scale) {
      return this;
    }
    if (nsig < 0) {
      nsig = 0;
    }
    final int diff = scale - nsig;
    LexoInteger nmag = mag >> diff;
    if (ceiling) {
      nmag += LexoInteger.one(nmag.system);
    }
    return LexoDecimal.make(nmag, nsig);
  }

  @override
  int compareTo(LexoDecimal other) {
    if (identical(this, other)) {
      return 0;
    }
    // if (!other) {
    //   return 1;
    // }
    LexoInteger tMag = mag;
    LexoInteger oMag = other.mag;
    if (scale > other.scale) {
      oMag = oMag << (scale - other.scale);
    } else if (scale < other.scale) {
      tMag = tMag << (other.scale - scale);
    }
    return tMag.compareTo(oMag);
  }

  String format() {
    final intStr = mag.format();
    if (scale == 0) {
      return intStr;
    }
    final StringBuilder sb = StringBuilder(intStr);
    final String head = sb.str[0];
    final bool specialHead =
        head == mag.system.positiveChar || head == mag.system.negativeChar;
    if (specialHead) {
      sb.remove(0, 1);
    }
    while (sb.length < scale + 1) {
      sb.insert(0, mag.system.toChar(0));
    }
    sb.insert(sb.length - scale, mag.system.radixPointChar);
    if (sb.length - scale == 0) {
      sb.insert(0, mag.system.toChar(0));
    }
    if (specialHead) {
      sb.insert(0, head);
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexoDecimal &&
          runtimeType == other.runtimeType &&
          mag == other.mag &&
          scale == other.scale;

  @override
  int get hashCode => mag.hashCode ^ scale.hashCode;

  @override
  String toString() {
    return format();
  }
}
