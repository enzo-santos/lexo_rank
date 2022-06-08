import '../lexo_rank.dart';
import 'lexo_integer.dart';

class LexoRankBucket {
  static final LexoRankBucket bucket0 = LexoRankBucket('0');
  static final LexoRankBucket bucket1 = LexoRankBucket('1');
  static final LexoRankBucket bucket2 = LexoRankBucket('2');
  static final List<LexoRankBucket> values = [bucket0, bucket1, bucket2];

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

    throw AssertionError('Unknown bucket: ' + str);
  }

  factory LexoRankBucket.resolve(int bucketId) {
    final List<LexoRankBucket> var1 = LexoRankBucket.values;
    final int var2 = var1.length;
    for (int var3 = 0; var3 < var2; ++var3) {
      final LexoRankBucket bucket = var1[var3];
      if (bucket.equals(LexoRankBucket.from(bucketId.toString()))) {
        return bucket;
      }
    }
    throw AssertionError('No bucket found with id ' + bucketId.toString());
  }

  final LexoInteger value;

  LexoRankBucket(String val)
      : value = LexoInteger.parse(val, LexoRank.numeralSystem);

  String format() {
    return value.format();
  }

  LexoRankBucket next() {
    if (equals(LexoRankBucket.bucket0)) {
      return LexoRankBucket.bucket1;
    }
    if (equals(LexoRankBucket.bucket1)) {
      return LexoRankBucket.bucket2;
    }
    return equals(LexoRankBucket.bucket2)
        ? LexoRankBucket.bucket0
        : LexoRankBucket.bucket2;
  }

  LexoRankBucket prev() {
    if (equals(LexoRankBucket.bucket0)) {
      return LexoRankBucket.bucket2;
    }
    if (equals(LexoRankBucket.bucket1)) {
      return LexoRankBucket.bucket0;
    }
    return equals(LexoRankBucket.bucket2)
        ? LexoRankBucket.bucket1
        : LexoRankBucket.bucket0;
  }

  bool equals(LexoRankBucket other) {
    if (identical(this, other)) {
      return true;
    }
    // if (!other) {
    //   return false;
    //}
    return value.equals(other.value);
  }
}
