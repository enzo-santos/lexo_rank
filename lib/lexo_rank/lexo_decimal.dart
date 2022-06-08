import '../numeral_systems/lexo_numeral_system.dart';
import '../utils/string_builder.dart';
import 'lexo_integer.dart';

class LexoDecimal {
  factory LexoDecimal.half(LexoNumeralSystem sys) {
    final int mid = (sys.getBase() / 2).round() | 0;
    return LexoDecimal.make(LexoInteger.make(sys, 1, [mid]), 1);
  }

  factory LexoDecimal.parse(String str, LexoNumeralSystem system) {
    final int partialIndex = str.indexOf(system.getRadixPointChar());
    if (str.lastIndexOf(system.getRadixPointChar()) != partialIndex) {
      throw AssertionError('More than one ' + system.getRadixPointChar());
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
    if (integer.isZero()) {
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
  final int sig;

  const LexoDecimal(this.mag, this.sig);

  LexoNumeralSystem getSystem() {
    return mag.getSystem();
  }

  LexoDecimal add(LexoDecimal other) {
    LexoInteger tmag = mag;
    int tsig = sig;
    LexoInteger omag = other.mag;
    int osig;
    for (osig = other.sig; tsig < osig; ++tsig) {
      tmag <<= 1;
    }
    while (tsig > osig) {
      omag <<= 1;
      ++osig;
    }
    return LexoDecimal.make(tmag + omag, tsig);
  }

  LexoDecimal subtract(LexoDecimal other) {
    LexoInteger thisMag = mag;
    int thisSig = sig;
    LexoInteger otherMag = other.mag;
    int otherSig;
    for (otherSig = other.sig; thisSig < otherSig; ++thisSig) {
      thisMag <<= 1;
    }
    while (thisSig > otherSig) {
      otherMag <<= 1;
      ++otherSig;
    }
    return LexoDecimal.make(thisMag - otherMag, thisSig);
  }

  LexoDecimal multiply(LexoDecimal other) {
    return LexoDecimal.make(mag * other.mag, sig + other.sig);
  }

  LexoInteger floor() {
    return mag >> sig;
  }

  LexoInteger ceil() {
    if (isExact()) {
      return mag;
    }
    final LexoInteger f = floor();
    return f + LexoInteger.one(f.getSystem());
  }

  bool isExact() {
    if (sig == 0) {
      return true;
    }
    for (int i = 0; i < sig; ++i) {
      if (mag.getMag(i) != 0) {
        return false;
      }
    }
    return true;
  }

  int getScale() {
    return sig;
  }

  LexoDecimal setScale(int nsig, [bool ceiling = false]) {
    if (nsig >= sig) {
      return this;
    }
    if (nsig < 0) {
      nsig = 0;
    }
    final int diff = sig - nsig;
    LexoInteger nmag = mag >> diff;
    if (ceiling) {
      nmag += LexoInteger.one(nmag.getSystem());
    }
    return LexoDecimal.make(nmag, nsig);
  }

  int compareTo(LexoDecimal other) {
    if (identical(this, other)) {
      return 0;
    }
    // if (!other) {
    //   return 1;
    // }
    LexoInteger tMag = mag;
    LexoInteger oMag = other.mag;
    if (sig > other.sig) {
      oMag = oMag << (sig - other.sig);
    } else if (sig < other.sig) {
      tMag = tMag << (other.sig - sig);
    }
    return tMag.compareTo(oMag);
  }

  String format() {
    final intStr = mag.format();
    if (sig == 0) {
      return intStr;
    }
    final StringBuilder sb = StringBuilder(intStr);
    final String head = sb.str[0];
    final bool specialHead = head == mag.getSystem().getPositiveChar() ||
        head == mag.getSystem().getNegativeChar();
    if (specialHead) {
      sb.remove(0, 1);
    }
    while (sb.length < sig + 1) {
      sb.insert(0, mag.getSystem().toChar(0));
    }
    sb.insert(sb.length - sig, mag.getSystem().getRadixPointChar());
    if (sb.length - sig == 0) {
      sb.insert(0, mag.getSystem().toChar(0));
    }
    if (specialHead) {
      sb.insert(0, head);
    }
    return sb.toString();
  }

  bool equals(LexoDecimal other) {
    if (identical(this, other)) {
      return true;
    }
    // if (!other) {
    //   return false;
    // }
    return mag == other.mag && sig == other.sig;
  }

  @override
  String toString() {
    return format();
  }
}
