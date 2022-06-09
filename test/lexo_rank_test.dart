import 'package:lexo_rank/lexo_rank/lexo_decimal.dart';
import 'package:lexo_rank/lexo_rank/lexo_integer.dart';
import 'package:lexo_rank/lexo_rank/lexo_magnitude.dart';
import 'package:lexo_rank/lexo_rank/lexo_rank_bucket.dart';
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
      expect(LexoRank.max(LexoRankBucket.bucket0).value, '0|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket.bucket1).value, '1|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket.bucket2).value, '2|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket('3')).value, '3|zzzzzz:');
      expect(LexoRank.max(LexoRankBucket('30')).value, '30|zzzzzz:');
    });
    test('initial', () {
      expect(LexoRank.initial(LexoRankBucket.bucket0).value, '0|100000:');
      expect(LexoRank.initial(LexoRankBucket.bucket1).value, '1|y00000:');
      expect(LexoRank.initial(LexoRankBucket.bucket2).value, '2|y00000:');
      expect(LexoRank.initial(LexoRankBucket('3')).value, '3|y00000:');
      expect(LexoRank.initial(LexoRankBucket('30')).value, '30|y00000:');
    });
    group('from', () {
      test('default decimal values', () {
        expect(LexoRank.from(LexoRankBucket.bucket0, LexoRank.zeroDecimal).value,'0|000000:');
        expect(LexoRank.from(LexoRankBucket.bucket1, LexoRank.oneDecimal).value,'1|000001:');
        expect(LexoRank.from(LexoRankBucket.bucket2, LexoRank.eightDecimal).value,'2|000008:');
        expect(LexoRank.from(LexoRankBucket.bucket0, LexoRank.initialMinDecimal).value,'0|100000:');
        expect(LexoRank.from(LexoRankBucket.bucket1, LexoRank.initialMaxDecimal).value,'1|y00000:');
        expect(LexoRank.from(LexoRankBucket.bucket2, LexoRank.maxDecimal).value,'2|zzzzzz:');
        expect(LexoRank.from(LexoRankBucket.bucket0, LexoRank.midDecimal).value,'0|hzzzzz:');
        expect(LexoRank.from(LexoRankBucket.bucket1, LexoRank.minDecimal).value,'1|000000:');
      });
      group('custom decimal values', () {
        final LexoRankBucket bucket = LexoRankBucket('3');
        group('scale equals to 0', () {
          test('smaller than default', () {
            expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoMagnitude(LexoRank.numeralSystem, [5, 4, 3, 2, 1]), sign: 1), scale: 0)).value, '3|012345:');
          });
          test('decimal exactly the decimal default', () {
            expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoMagnitude(LexoRank.numeralSystem, [6, 5, 4, 3, 2, 1]), sign: 1), scale: 0)).value, '3|123456:');
          });
          test('decimal bigger than the decimal default', () {
            expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoMagnitude(LexoRank.numeralSystem, [7, 6, 5, 4, 3, 2, 1]), sign: 1), scale: 0)).value, '3|1234567:');
          });
        });
        test('scale higher than 0', () {
          expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoMagnitude(LexoRank.numeralSystem, [6, 5, 4, 3, 2, 1]), sign: 1), scale: 1)).value, '3|012345:6');
          expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoMagnitude(LexoRank.numeralSystem, [6, 5, 4, 3, 2, 1]), sign: 1), scale: 2)).value, '3|001234:56');
          expect(LexoRank.from(bucket, LexoDecimal(LexoInteger(LexoMagnitude(LexoRank.numeralSystem, [6, 5, 4, 3, 2, 1]), sign: 1), scale: 3)).value, '3|000123:456');
        });
      });
    });
    group('mid', () {
      test('between same numbers', () {
        expect(LexoRank.mid(LexoRank.zeroDecimal, LexoRank.zeroDecimal), LexoRank.zeroDecimal);
        expect(LexoRank.mid(LexoRank.oneDecimal, LexoRank.oneDecimal), LexoRank.oneDecimal);
        expect(LexoRank.mid(LexoRank.initialMaxDecimal, LexoRank.initialMaxDecimal), LexoRank.initialMaxDecimal);
      });
      test('between min and max', () {
        expect(LexoRank.mid(LexoRank.minDecimal, LexoRank.maxDecimal), LexoRank.midDecimal);
      });
      test('between collisions', () {
        expect(LexoRank.mid(LexoRank.zeroDecimal, LexoRank.oneDecimal), LexoDecimal.half(LexoRank.numeralSystem));
      });
    });
  });
}
