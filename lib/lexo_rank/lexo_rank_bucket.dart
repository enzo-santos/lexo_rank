import 'package:lexo_rank/lexo_rank/lexo_magnitude.dart';

import '../lexo_rank.dart';
import 'lexo_integer.dart';

class LexoRankBucket {
  static const LexoRankBucket bucket0 = LexoRankBucket._(
    LexoInteger(
      LexoMagnitude(LexoRank.numeralSystem, [0]),
      sign: 0,
    ),
  );
  static const LexoRankBucket bucket1 = LexoRankBucket._(
    LexoInteger(
      LexoMagnitude(LexoRank.numeralSystem, [1]),
      sign: 1,
    ),
  );
  static const LexoRankBucket bucket2 = LexoRankBucket._(
    LexoInteger(
      LexoMagnitude(LexoRank.numeralSystem, [2]),
      sign: 1,
    ),
  );
  static const List<LexoRankBucket> values = [bucket0, bucket1, bucket2];

  factory LexoRankBucket.max() {
    return LexoRankBucket.values[LexoRankBucket.values.length - 1];
  }

  factory LexoRankBucket.from(String str) {
    final LexoInteger val = LexoInteger.parse(str, LexoRank.numeralSystem);
    final List<LexoRankBucket> var2 = LexoRankBucket.values;
    final int var3 = var2.length;
    for (int var4 = 0; var4 < var3; ++var4) {
      final LexoRankBucket bucket = var2[var4];
      if (bucket.value.sign == val.sign) {
        return bucket;
      }
    }

    throw AssertionError('Unknown bucket: $str');
  }

  factory LexoRankBucket.resolve(int bucketId) {
    final List<LexoRankBucket> var1 = LexoRankBucket.values;
    final int var2 = var1.length;
    for (int var3 = 0; var3 < var2; ++var3) {
      final LexoRankBucket bucket = var1[var3];
      if (bucket == LexoRankBucket.from(bucketId.toString())) {
        return bucket;
      }
    }
    throw AssertionError('No bucket found with id $bucketId');
  }

  final LexoInteger value;

  const LexoRankBucket._(this.value);

  LexoRankBucket(String value)
      : value = LexoInteger.parse(value, LexoRank.numeralSystem);

  String format() {
    return value.format();
  }

  LexoRankBucket next() {
    if (this == LexoRankBucket.bucket0) {
      return LexoRankBucket.bucket1;
    }
    if (this == LexoRankBucket.bucket1) {
      return LexoRankBucket.bucket2;
    }
    return this == LexoRankBucket.bucket2
        ? LexoRankBucket.bucket0
        : LexoRankBucket.bucket2;
  }

  LexoRankBucket prev() {
    if (this == LexoRankBucket.bucket0) {
      return LexoRankBucket.bucket2;
    }
    if (this == LexoRankBucket.bucket1) {
      return LexoRankBucket.bucket0;
    }
    return this == LexoRankBucket.bucket2
        ? LexoRankBucket.bucket1
        : LexoRankBucket.bucket0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexoRankBucket &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
