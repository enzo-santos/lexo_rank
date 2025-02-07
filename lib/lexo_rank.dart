library lexo_rank;

import 'package:lexo_rank/lexo_rank/lexo_integer.dart';
import 'package:lexo_rank/lexo_rank/lexo_magnitude.dart';

import '../numeral_systems/lexo_numeral_system_36.dart';
import '../utils/string_builder.dart';
import 'lexo_rank/lexo_decimal.dart';
import 'lexo_rank/lexo_rank_bucket.dart';

class LexoRank implements Comparable<LexoRank> {
  static const LexoNumeralSystem36 numeralSystem = LexoNumeralSystem36();
  static const LexoDecimal zeroDecimal = LexoDecimal(
    LexoInteger(LexoMagnitude(numeralSystem, [0]), sign: 0),
    scale: 0,
  );
  static const LexoDecimal oneDecimal = LexoDecimal(
    LexoInteger(LexoMagnitude(numeralSystem, [1]), sign: 1),
    scale: 0,
  );
  static const LexoDecimal eightDecimal = LexoDecimal(
    LexoInteger(LexoMagnitude(numeralSystem, [8]), sign: 1),
    scale: 0,
  );
  static const LexoDecimal minDecimal = zeroDecimal;
  static const LexoDecimal maxDecimal = LexoDecimal(
    LexoInteger(
      LexoMagnitude(numeralSystem, [35, 35, 35, 35, 35, 35]),
      sign: 1,
    ),
    scale: 0,
  );
  static const LexoDecimal midDecimal = LexoDecimal(
    LexoInteger(
      LexoMagnitude(numeralSystem, [35, 35, 35, 35, 35, 17]),
      sign: 1,
    ),
    scale: 0,
  );
  static const LexoDecimal initialMinDecimal = LexoDecimal(
    LexoInteger(
      LexoMagnitude(numeralSystem, [0, 0, 0, 0, 0, 1]),
      sign: 1,
    ),
    scale: 0,
  );
  static const LexoDecimal initialMaxDecimal = LexoDecimal(
    LexoInteger(
      LexoMagnitude(numeralSystem, [0, 0, 0, 0, 0, 34]),
      sign: 1,
    ),
    scale: 0,
  );

  factory LexoRank.min({LexoRankBucket bucket = LexoRankBucket.bucket0}) {
    return LexoRank.from(bucket, LexoRank.minDecimal);
  }

  factory LexoRank.middle({LexoRankBucket bucket = LexoRankBucket.bucket0}) {
    final LexoRank minLexoRank = LexoRank.min(bucket: bucket);
    return minLexoRank.genBetween(LexoRank.max(minLexoRank.bucket));
  }

  factory LexoRank.max(LexoRankBucket bucket) {
    return LexoRank.from(bucket, LexoRank.maxDecimal);
  }

  factory LexoRank.initial(LexoRankBucket bucket) {
    return identical(bucket, LexoRankBucket.bucket0)
        ? LexoRank.from(bucket, LexoRank.initialMinDecimal)
        : LexoRank.from(bucket, LexoRank.initialMaxDecimal);
  }

  factory LexoRank.parse(String str) {
    final List<String> parts = str.split('|');
    final LexoRankBucket bucket = LexoRankBucket.from(parts[0]);
    final LexoDecimal decimal =
        LexoDecimal.parse(parts[1], LexoRank.numeralSystem);
    return LexoRank(bucket, decimal);
  }

  factory LexoRank.from(LexoRankBucket bucket, LexoDecimal decimal) {
    if (decimal.system.base != LexoRank.numeralSystem.base) {
      throw AssertionError('Expected different system');
    }
    return LexoRank(bucket, decimal);
  }

  static LexoDecimal between(LexoDecimal oLeft, LexoDecimal oRight) {
    if (oLeft.system.base != oRight.system.base) {
      throw AssertionError('Expected same system');
    }
    LexoDecimal left = oLeft;
    LexoDecimal right = oRight;
    LexoDecimal nLeft;
    if (oLeft.scale < oRight.scale) {
      nLeft = oRight.withScale(oLeft.scale, false);
      if (oLeft.compareTo(nLeft) >= 0) {
        return LexoRank.mid(oLeft, oRight);
      }
      right = nLeft;
    }
    if (oLeft.scale > right.scale) {
      nLeft = oLeft.withScale(right.scale, true);
      if (nLeft.compareTo(right) >= 0) {
        return LexoRank.mid(oLeft, oRight);
      }
      left = nLeft;
    }
    LexoDecimal nRight;
    for (int scale = left.scale; scale > 0; right = nRight) {
      final int nScale1 = scale - 1;
      final LexoDecimal nLeft1 = left.withScale(nScale1, true);
      nRight = right.withScale(nScale1, false);
      final int cmp = nLeft1.compareTo(nRight);
      if (cmp == 0) {
        return LexoRank.checkMid(oLeft, oRight, nLeft1);
      }
      if (nLeft1.compareTo(nRight) > 0) {
        break;
      }
      scale = nScale1;
      left = nLeft1;
    }
    LexoDecimal mid = LexoRank.middleInternal(oLeft, oRight, left, right);
    int nScale;
    for (int mScale = mid.scale; mScale > 0; mScale = nScale) {
      nScale = mScale - 1;
      final LexoDecimal nMid = mid.withScale(nScale);
      if (oLeft.compareTo(nMid) >= 0 || nMid.compareTo(oRight) >= 0) {
        break;
      }
      mid = nMid;
    }
    return mid;
  }

  static LexoDecimal middleInternal(
    LexoDecimal lbound,
    LexoDecimal rbound,
    LexoDecimal left,
    LexoDecimal right,
  ) {
    final LexoDecimal mid = LexoRank.mid(left, right);
    return LexoRank.checkMid(lbound, rbound, mid);
  }

  static LexoDecimal checkMid(
    LexoDecimal lbound,
    LexoDecimal rbound,
    LexoDecimal mid,
  ) {
    if (lbound.compareTo(mid) >= 0) {
      return LexoRank.mid(lbound, rbound);
    }
    return mid.compareTo(rbound) >= 0 ? LexoRank.mid(lbound, rbound) : mid;
  }

  static LexoDecimal mid(LexoDecimal left, LexoDecimal right) {
    final LexoDecimal sum = left + right;
    final LexoDecimal mid = sum * LexoDecimal.half(left.system);
    final int scale = left.scale > right.scale ? left.scale : right.scale;
    if (mid.scale > scale) {
      final LexoDecimal roundDown = mid.withScale(scale, false);
      if (roundDown.compareTo(left) > 0) {
        return roundDown;
      }
      final LexoDecimal roundUp = mid.withScale(scale, true);
      if (roundUp.compareTo(right) < 0) {
        return roundUp;
      }
    }
    return mid;
  }

  static String formatDecimal(LexoDecimal decimal) {
    final String formatVal = decimal.format();
    final StringBuilder val = StringBuilder(formatVal);
    int partialIndex = formatVal.indexOf(LexoRank.numeralSystem.radixPointChar);
    final String zero = LexoRank.numeralSystem.toChar(0);
    if (partialIndex < 0) {
      partialIndex = formatVal.length;
      val.append(LexoRank.numeralSystem.radixPointChar);
    }
    while (partialIndex < 6) {
      val.insert(0, zero);
      ++partialIndex;
    }
    while (val.str[val.str.length - 1] == zero) {
      val.length = val.length - 1;
    }
    return val.toString();
  }

  final String value;
  final LexoRankBucket bucket;
  final LexoDecimal decimal;

  LexoRank(this.bucket, this.decimal)
      : value = '${bucket.format()}|${LexoRank.formatDecimal(decimal)}';

  LexoRank genPrev() {
    if (isMax) {
      return LexoRank(bucket, LexoRank.initialMaxDecimal);
    }
    final LexoInteger floorInteger = decimal.floor();
    final LexoDecimal floorDecimal = LexoDecimal.from(floorInteger);
    LexoDecimal nextDecimal = floorDecimal - LexoRank.eightDecimal;
    if (nextDecimal.compareTo(LexoRank.minDecimal) <= 0) {
      nextDecimal = LexoRank.between(LexoRank.minDecimal, decimal);
    }
    return LexoRank(bucket, nextDecimal);
  }

  LexoRank genNext() {
    if (isMin) {
      return LexoRank(bucket, LexoRank.initialMinDecimal);
    }
    final LexoInteger ceilInteger = decimal.ceil();
    final LexoDecimal ceilDecimal = LexoDecimal.from(ceilInteger);
    LexoDecimal nextDecimal = ceilDecimal + LexoRank.eightDecimal;
    if (nextDecimal.compareTo(LexoRank.maxDecimal) >= 0) {
      nextDecimal = LexoRank.between(decimal, LexoRank.maxDecimal);
    }
    return LexoRank(bucket, nextDecimal);
  }

  LexoRank genBetween(LexoRank other) {
    if (bucket != other.bucket) {
      throw AssertionError('Between works only within the same bucket');
    }
    final int cmp = decimal.compareTo(other.decimal);
    if (cmp > 0) {
      return LexoRank(bucket, LexoRank.between(other.decimal, decimal));
    }
    if (cmp == 0) {
      throw AssertionError('Try to rank between issues with same rank '
          'this=${toString()} '
          'other=$other '
          'this.decimal=$decimal '
          'other.decimal=${other.decimal}');
    }
    return LexoRank(bucket, LexoRank.between(decimal, other.decimal));
  }

  LexoRank inNextBucket() {
    return LexoRank.from(bucket.next(), decimal);
  }

  LexoRank inPrevBucket() {
    return LexoRank.from(bucket.prev(), decimal);
  }

  bool get isMin {
    return decimal == LexoRank.minDecimal;
  }

  bool get isMax {
    return decimal == LexoRank.maxDecimal;
  }

  String format() {
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexoRank &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value;
  }

  @override
  int compareTo(LexoRank other) {
    if (identical(this, other)) {
      return 0;
    }
    return value.compareTo(other.value);
  }
}
