import 'package:lexo_rank/lexoRank/lexoDecimal.dart';
import 'package:lexo_rank/lexoRank/lexoInteger.dart';
import 'package:lexo_rank/lexoRank/lexoRankBucket.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:test/test.dart';

void main() {
  group('LexoRank', () {
    test('min', () {
      expect(LexoRank.min().value, '0|000000:');
    });
    test('middle', () {
      expect(LexoRank.middle().value, '0|hzzzzz:');
    });
    test('max', () {
      expect(LexoRank.max(LexoRankBucket.BUCKET_0).value, '0|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket.BUCKET_1).value, '1|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket.BUCKET_2).value, '2|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket('3')).value, '3|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket('30')).value, '30|zzzzzz:');
    });
    test('initial', () {
      expect(LexoRank.initial(LexoRankBucket.BUCKET_0).value, '0|100000:');
      expect(LexoRank.initial(LexoRankBucket.BUCKET_1).value, '1|y00000:');
      expect(LexoRank.initial(LexoRankBucket.BUCKET_2).value, '2|y00000:');
      expect(LexoRank.initial(LexoRankBucket('3')).value, '3|y00000:');
      expect(LexoRank.initial(LexoRankBucket('30')).value, '30|y00000:');
    });
    group('from', () {
      test('default decimal values', () {
        expect(LexoRank.from(LexoRankBucket.BUCKET_0, LexoRank.ZERO_DECIMAL).value,'0|000000:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_1, LexoRank.ONE_DECIMAL).value,'1|000001:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_2, LexoRank.EIGHT_DECIMAL).value,'2|000008:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_0, LexoRank.INITIAL_MIN_DECIMAL).value,'0|100000:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_1, LexoRank.INITIAL_MAX_DECIMAL).value,'1|y00000:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_2, LexoRank.MAX_DECIMAL).value,'2|zzzzzz:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_0, LexoRank.MID_DECIMAL).value,'0|hzzzzz:');
        expect(LexoRank.from(LexoRankBucket.BUCKET_1, LexoRank.MIN_DECIMAL).value,'1|000000:');
      });
      group('custom decimal values', () {
        final LexoRankBucket bucket = LexoRankBucket('3');
        group('scale equals to 0', () {
          test('smaller than default', () {
            expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoRank.NUMERAL_SYSTEM, 1, [5, 4, 3, 2, 1]), 0)).value,'3|012345:');
          });
          test('decimal exactly the decimal default', () {
            expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoRank.NUMERAL_SYSTEM, 1, [6, 5, 4, 3, 2, 1]), 0)).value,'3|123456:');
          });
          test('decimal bigger than the decimal default', () {
            expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoRank.NUMERAL_SYSTEM, 1, [7, 6, 5, 4, 3, 2, 1]), 0)).value,'3|1234567:');
          });
        });
        test('scale higher than 0', () {
          expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoRank.NUMERAL_SYSTEM, 1, [6, 5, 4, 3, 2, 1]), 1)).value,'3|012345:6');
          expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoRank.NUMERAL_SYSTEM, 1, [6, 5, 4, 3, 2, 1]), 2)).value,'3|001234:56');
          expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoRank.NUMERAL_SYSTEM, 1, [6, 5, 4, 3, 2, 1]), 3)).value,'3|000123:456');
        });
      });
    });
    group('mid', () {
      test('between same numbers', () {
        expect(LexoRank.mid(LexoRank.ZERO_DECIMAL, LexoRank.ZERO_DECIMAL).equals(LexoRank.ZERO_DECIMAL), isTrue);
        expect(LexoRank.mid(LexoRank.ONE_DECIMAL, LexoRank.ONE_DECIMAL).equals(LexoRank.ONE_DECIMAL), isTrue);
        expect(LexoRank.mid(LexoRank.INITIAL_MAX_DECIMAL, LexoRank.INITIAL_MAX_DECIMAL).equals(LexoRank.INITIAL_MAX_DECIMAL), isTrue);
      });
      test('between min and max', () {
        expect(LexoRank.mid(LexoRank.MIN_DECIMAL, LexoRank.MAX_DECIMAL).equals(LexoRank.MID_DECIMAL), isTrue);
      });
      test('between collisions', () {
        expect(LexoRank.mid(LexoRank.ZERO_DECIMAL, LexoRank.ONE_DECIMAL).equals(LexoDecimal.half(LexoRank.NUMERAL_SYSTEM)), isTrue);
      });
    });
  });
}
