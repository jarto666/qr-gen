import 'dart:math';

// IDEA: change to class with static consts
enum EncodingType {
  numeric(1),
  alphanumeric(2),
  byte(4),
  kanji(8),
  eci(7);

  const EncodingType(this.value);
  final int value;
}

enum EncodingVersionGroup { upTo9, upTo26, upTo40 }

/// EncodingMode	Version[1-9]	  Version[10-26]    Version[27-40]
/// Numeric	      10	            12	              14
/// Alphanumeric	9	              11	              13
/// Byte/ECI      8	              16	              16
/// Kanji	        8	              10	              12
const Map<EncodingType, Map<EncodingVersionGroup, int>> lengthBits = {
  EncodingType.numeric: {
    EncodingVersionGroup.upTo9: 10,
    EncodingVersionGroup.upTo26: 12,
    EncodingVersionGroup.upTo40: 14,
  },
  EncodingType.alphanumeric: {
    EncodingVersionGroup.upTo9: 9,
    EncodingVersionGroup.upTo26: 11,
    EncodingVersionGroup.upTo40: 13,
  },
  EncodingType.byte: {
    EncodingVersionGroup.upTo9: 8,
    EncodingVersionGroup.upTo26: 16,
    EncodingVersionGroup.upTo40: 16,
  },
  EncodingType.eci: {
    EncodingVersionGroup.upTo9: 8,
    EncodingVersionGroup.upTo26: 16,
    EncodingVersionGroup.upTo40: 16,
  },
  EncodingType.kanji: {
    EncodingVersionGroup.upTo9: 8,
    EncodingVersionGroup.upTo26: 10,
    EncodingVersionGroup.upTo40: 12,
  },
};

double logBase(num x, num base) => log(x) / log(base);
double log2(num x) => logBase(x, 2);

int getLengthBits(EncodingType mode, int version) {
  final versionGroup = version > 26
      ? EncodingVersionGroup.upTo40
      : version > 9
          ? EncodingVersionGroup.upTo26
          : EncodingVersionGroup.upTo9;
  return lengthBits[mode]![versionGroup]!;
}
