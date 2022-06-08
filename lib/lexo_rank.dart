library lexo_rank;

import 'package:lexo_rank/lexo_rank/lexo_integer.dart';

import '../numeral_systems/lexo_numeral_system_36.dart';
import '../utils/string_builder.dart';
import 'lexo_rank/lexo_decimal.dart';
import 'lexo_rank/lexo_rank_bucket.dart';

class LexoRank {
  static final LexoNumeralSystem36 numeralSystem = LexoNumeralSystem36();
  static final LexoDecimal zeroDecimal = LexoDecimal.parse('0', numeralSystem);
  static final LexoDecimal oneDecimal = LexoDecimal.parse('1', numeralSystem);
  static final LexoDecimal eightDecimal = LexoDecimal.parse('8', numeralSystem);
  static final LexoDecimal minDecimal = zeroDecimal;
  static final LexoDecimal maxDecimal =
      LexoDecimal.parse('1000000', numeralSystem).subtract(oneDecimal);
  static final LexoDecimal midDecimal =
      LexoRank.Between(minDecimal, maxDecimal);
  static final LexoDecimal initialMinDecimal =
      LexoDecimal.parse('100000', LexoRank.numeralSystem);
  static final LexoDecimal initialMaxDecimal = LexoDecimal.parse(
      LexoRank.numeralSystem.toChar(LexoRank.numeralSystem.getBase() - 2) +
          '00000',
      LexoRank.numeralSystem);

  factory LexoRank.min() {
    return LexoRank.from(LexoRankBucket.bucket0, LexoRank.minDecimal);
  }

  factory LexoRank.middle() {
    final LexoRank minLexoRank = LexoRank.min();
    return minLexoRank.between(LexoRank.max(minLexoRank.bucket));
  }

  factory LexoRank.max(LexoRankBucket bucket) {
    return LexoRank.from(bucket, LexoRank.maxDecimal);
  }

  factory LexoRank.initial(LexoRankBucket bucket) {
    return identical(bucket, LexoRankBucket.bucket0)
        ? LexoRank.from(bucket, LexoRank.initialMinDecimal)
        : LexoRank.from(bucket, LexoRank.initialMaxDecimal);
  }

  static LexoDecimal Between(LexoDecimal oLeft, LexoDecimal oRight) {
    if (oLeft.getSystem().getBase() != oRight.getSystem().getBase()) {
      throw AssertionError('Expected same system');
    }
    LexoDecimal left = oLeft;
    LexoDecimal right = oRight;
    LexoDecimal nLeft;
    if (oLeft.getScale() < oRight.getScale()) {
      nLeft = oRight.setScale(oLeft.getScale(), false);
      if (oLeft.compareTo(nLeft) >= 0) {
        return LexoRank.mid(oLeft, oRight);
      }
      right = nLeft;
    }
    if (oLeft.getScale() > right.getScale()) {
      nLeft = oLeft.setScale(right.getScale(), true);
      if (nLeft.compareTo(right) >= 0) {
        return LexoRank.mid(oLeft, oRight);
      }
      left = nLeft;
    }
    LexoDecimal nRight;
    for (int scale = left.getScale(); scale > 0; right = nRight) {
      final int nScale1 = scale - 1;
      final LexoDecimal nLeft1 = left.setScale(nScale1, true);
      nRight = right.setScale(nScale1, false);
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
    for (int mScale = mid.getScale(); mScale > 0; mScale = nScale) {
      nScale = mScale - 1;
      final LexoDecimal nMid = mid.setScale(nScale);
      if (oLeft.compareTo(nMid) >= 0 || nMid.compareTo(oRight) >= 0) {
        break;
      }
      mid = nMid;
    }
    return mid;
  }

  factory LexoRank.parse(String str) {
    final List<String> parts = str.split('|');
    final LexoRankBucket bucket = LexoRankBucket.from(parts[0]);
    final LexoDecimal decimal =
        LexoDecimal.parse(parts[1], LexoRank.numeralSystem);
    return LexoRank(bucket, decimal);
  }

  factory LexoRank.from(LexoRankBucket bucket, LexoDecimal decimal) {
    if (decimal.getSystem().getBase() != LexoRank.numeralSystem.getBase()) {
      throw AssertionError('Expected different system');
    }
    return LexoRank(bucket, decimal);
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
    final LexoDecimal sum = left.add(right);
    final LexoDecimal mid = sum.multiply(LexoDecimal.half(left.getSystem()));
    final int scale =
        left.getScale() > right.getScale() ? left.getScale() : right.getScale();
    if (mid.getScale() > scale) {
      final LexoDecimal roundDown = mid.setScale(scale, false);
      if (roundDown.compareTo(left) > 0) {
        return roundDown;
      }
      final LexoDecimal roundUp = mid.setScale(scale, true);
      if (roundUp.compareTo(right) < 0) {
        return roundUp;
      }
    }
    return mid;
  }

  static String formatDecimal(LexoDecimal decimal) {
    final String formatVal = decimal.format();
    final StringBuilder val = StringBuilder(formatVal);
    int partialIndex =
        formatVal.indexOf(LexoRank.numeralSystem.getRadixPointChar());
    final String zero = LexoRank.numeralSystem.toChar(0);
    if (partialIndex < 0) {
      partialIndex = formatVal.length;
      val.append(LexoRank.numeralSystem.getRadixPointChar());
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
      : value = bucket.format() + '|' + LexoRank.formatDecimal(decimal);

  LexoRank genPrev() {
    if (isMax()) {
      return LexoRank(bucket, LexoRank.initialMaxDecimal);
    }
    final LexoInteger floorInteger = decimal.floor();
    final LexoDecimal floorDecimal = LexoDecimal.from(floorInteger);
    LexoDecimal nextDecimal = floorDecimal.subtract(LexoRank.eightDecimal);
    if (nextDecimal.compareTo(LexoRank.minDecimal) <= 0) {
      nextDecimal = LexoRank.Between(LexoRank.minDecimal, decimal);
    }
    return LexoRank(bucket, nextDecimal);
  }

  LexoRank genNext() {
    if (isMin()) {
      return LexoRank(bucket, LexoRank.initialMinDecimal);
    }
    final LexoInteger ceilInteger = decimal.ceil();
    final LexoDecimal ceilDecimal = LexoDecimal.from(ceilInteger);
    LexoDecimal nextDecimal = ceilDecimal.add(LexoRank.eightDecimal);
    if (nextDecimal.compareTo(LexoRank.maxDecimal) >= 0) {
      nextDecimal = LexoRank.Between(decimal, LexoRank.maxDecimal);
    }
    return LexoRank(bucket, nextDecimal);
  }

  LexoRank between(LexoRank other) {
    if (!bucket.equals(other.bucket)) {
      throw AssertionError('Between works only within the same bucket');
    }
    final int cmp = decimal.compareTo(other.decimal);
    if (cmp > 0) {
      return LexoRank(bucket, LexoRank.Between(other.decimal, decimal));
    }
    if (cmp == 0) {
      throw AssertionError('Try to rank between issues with same rank this=' +
          toString() +
          ' other=' +
          other.toString() +
          ' this.decimal=' +
          decimal.toString() +
          ' other.decimal=' +
          other.decimal.toString());
    }
    return LexoRank(bucket, LexoRank.Between(decimal, other.decimal));
  }

  LexoRankBucket getBucket() {
    return bucket;
  }

  LexoDecimal getDecimal() {
    return decimal;
  }

  LexoRank inNextBucket() {
    return LexoRank.from(bucket.next(), decimal);
  }

  LexoRank inPrevBucket() {
    return LexoRank.from(bucket.prev(), decimal);
  }

  bool isMin() {
    return decimal.equals(LexoRank.minDecimal);
  }

  bool isMax() {
    return decimal.equals(LexoRank.maxDecimal);
  }

  String format() {
    return value;
  }

  bool equals(LexoRank other) {
    if (identical(this, other)) {
      return true;
    }
    // if (!other) {
    //   return false;
    // }
    return value == other.value;
  }

  @override
  String toString() {
    return value;
  }

  num compareTo(LexoRank other) {
    if (identical(this, other)) {
      return 0;
    }
    // if (!other) {
    //   return 1;
    // }
    return value.compareTo(other.value);
  }
}
