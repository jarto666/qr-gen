import 'dart:math';
import 'dart:typed_data';
import '/src/ec_type.dart';
import '/src/alignment_pattern.dart';
import '/src/encoders.dart';
import '/src/encoding_type.dart';
import '/src/poly.dart';

import 'qr_mask.dart';

typedef QMatrix = List<List<bool>>;

class QrCode {
  late final QMatrix matrix;

  late final int version;

  late final int maskIndex;

  late final EncodingType encodingType;

  late final ErrorCorrectionLevel errorCorrectionLevel;

  QrCode(String data, ErrorCorrectionLevel minErrorCorrectionLevel) {
    matrix = _build(data, minErrorCorrectionLevel);
  }

  QMatrix _build(String data, ErrorCorrectionLevel minErrorCorrectionLevel) {
    if (data.isEmpty) {
      throw ArgumentError("Empty input", "data");
    }

    final encodedData = QEncoder.create(data).encode(minErrorCorrectionLevel);
    encodingType = encodedData.encodingType;
    version = encodedData.version;
    errorCorrectionLevel = encodedData.errorCorrectionLevel;

    final moduleSequence = _getModuleSequence(version);
    final qrCode = _getNewMatrix(version);

    _placeFixedPatterns(qrCode, version);

    // Fill Codewords
    _fillCodewords(qrCode, moduleSequence, encodedData.words);

    // Masking
    maskIndex = mask(qrCode, moduleSequence);

    _placeVersionModules(qrCode);
    _encodeEclAndMask(qrCode, errorCorrectionLevel);

    return qrCode;
  }

  void _encodeEclAndMask(
      QMatrix qrCode, ErrorCorrectionLevel errorCorrectionLevel) {
    final formatPoly = Poly(15);

    final edcOrder = [
      ErrorCorrectionLevel.medium,
      ErrorCorrectionLevel.low,
      ErrorCorrectionLevel.high,
      ErrorCorrectionLevel.quartile,
    ];
    final errorLevelIndex = edcOrder.indexOf(errorCorrectionLevel);
    formatPoly[0] = errorLevelIndex >> 1;
    formatPoly[1] = errorLevelIndex & 1;
    formatPoly[2] = maskIndex >> 2;
    formatPoly[3] = (maskIndex >> 1) & 1;
    formatPoly[4] = maskIndex & 1;

    final formatDivisor = Poly.from([1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1]);
    final rest = formatPoly.mod(formatDivisor);
    formatPoly.setAll(5, rest);

    final formatMask = Poly.from([1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0]);
    final maskedFormatPoly = formatPoly
        .asMap()
        .entries
        .map((e) => e.value ^ formatMask[e.key])
        .map((e) => e == 1)
        .toList();

    qrCode[8].setAll(0, maskedFormatPoly.sublist(0, 6));
    qrCode[8].setAll(7, maskedFormatPoly.sublist(6, 8));
    qrCode[8].setAll(qrCode.length - 8, maskedFormatPoly.sublist(7));
    qrCode[7][8] = maskedFormatPoly[8];
    var sl7 = maskedFormatPoly.sublist(0, 7);
    for (int i = 0; i < sl7.length; i++) {
      qrCode[qrCode.length - i - 1][8] = sl7[i];
    }
    var sl9 = maskedFormatPoly.sublist(9);
    for (int i = 0; i < sl9.length; i++) {
      qrCode[5 - i][8] = sl9[i];
    }
  }

  static int _getSize(version) {
    return version * 4 + 17;
  }

  static QMatrix _getNewMatrix(version) {
    final size = _getSize(version);
    QMatrix numbers =
        List.generate(size, (_) => List<bool>.filled(size, false));
    return numbers;
  }

  static void _fillArea(
      QMatrix matrix, int row, int column, int width, int height,
      {bool fill = true}) {
    var fillRow = List.generate(width, (index) => fill);
    for (var i = row; i < row + height; i++) {
      matrix[i].setAll(column, fillRow);
    }
  }

  static final _versionDivisor =
      Poly.from([1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1]);
  Poly _getVersionInformation(int version) {
    final poly = Poly.from(
        ('${version.toRadixString(2).padLeft(6, '0')}000000000000')
            .split('')
            .map((e) => int.parse(e))
            .toList());
    poly.setAll(6, poly.mod(_versionDivisor));
    return poly;
  }

  void _placeVersionModules(QMatrix matrix) {
    final size = matrix.length;
    final version = (size - 17) >> 2;
    if (version < 7) {
      return;
    }
    var vinfo = _getVersionInformation(version);
    for (var i = 0; i < vinfo.length; i++) {
      final row = (i / 3).floor();
      final col = i % 3;
      matrix[5 - row][size - 9 - col] = vinfo[i] == 1;
      matrix[size - 11 + col][row] = vinfo[i] == 1;
    }
  }

  static List<Point<int>> _getModuleSequence(version) {
    final matrix = _getNewMatrix(version);
    final size = matrix.length;

    // Finder patterns + divisors
    _fillArea(matrix, 0, 0, 9, 9);
    _fillArea(matrix, 0, size - 8, 8, 9);
    _fillArea(matrix, size - 8, 0, 9, 8);

    // Alignment patterns
    var alignmentLocationsTemplate = alignmentPatterns[version]!;
    for (var x in alignmentLocationsTemplate) {
      for (var y in alignmentLocationsTemplate) {
        if (!_alignmentOverlaps(matrix, Point(x, y))) {
          _fillArea(matrix, x - 2, y - 2, 5, 5);
        }
      }
    }

    // Timing patterns
    _fillArea(matrix, 6, 9, version * 4, 1);
    _fillArea(matrix, 9, 6, 1, version * 4);

    // Dark module
    matrix[size - 8][8] = true;

    // Version info
    if (version > 6) {
      _fillArea(matrix, 0, size - 11, 3, 6);
      _fillArea(matrix, size - 11, 0, 6, 3);
    }

    var rowStep = -1;
    var row = size - 1;
    var column = size - 1;
    var sequence = List<Point<int>>.empty(growable: true);
    var index = 0;
    while (column >= 0) {
      if (!matrix[row][column]) {
        sequence.add(Point(row, column));
      }
      // Checking the parity of the index of the current module
      if (index & 1 == 1) {
        row += rowStep;
        if (row == -1 || row == size) {
          rowStep = -rowStep;
          row += rowStep;
          column -= column == 7 ? 2 : 1;
        } else {
          column++;
        }
      } else {
        column--;
      }
      index++;
    }

    return sequence;
  }

  static void _placeFixedPatterns(QMatrix qrCode, int version) {
    final size = qrCode.length;

    // * Fill finders (until alignments are set)
    var leftTopFinder = Point<int>(0, 0);
    _fillArea(qrCode, leftTopFinder.x, leftTopFinder.y, 8, 8);

    var rightTopFinder = Point<int>(0, size - 7);
    _fillArea(qrCode, rightTopFinder.x, rightTopFinder.y - 1, 8, 8);

    var leftBottomFinder = Point<int>(size - 7, 0);
    _fillArea(qrCode, leftBottomFinder.x - 1, leftBottomFinder.y, 8, 8);

    // Alignment (only for v2+)
    var alignmentLocationsTemplate = alignmentPatterns[version]!;
    for (var x in alignmentLocationsTemplate) {
      for (var y in alignmentLocationsTemplate) {
        if (!_alignmentOverlaps(qrCode, Point(x, y))) {
          _fillArea(qrCode, x - 2, y - 2, 5, 5);
          _fillArea(qrCode, x - 1, y - 1, 3, 3, fill: false);
          _fillArea(qrCode, x, y, 1, 1);
        }
      }
    }

    // Separators
    _fillArea(qrCode, 7, 0, 8, 1, fill: false);
    _fillArea(qrCode, 0, 7, 1, 7, fill: false);
    _fillArea(qrCode, size - 8, 0, 8, 1, fill: false);
    _fillArea(qrCode, 0, size - 8, 1, 7, fill: false);
    _fillArea(qrCode, 7, size - 8, 8, 1, fill: false);
    _fillArea(qrCode, size - 7, 7, 1, 7, fill: false);

    // Fill rest of finders
    _fillFinders(qrCode);

    // Fill Timing patterns
    for (int x = 8; x < size - 7; x += 2) {
      qrCode[x][6] = true;
      qrCode[6][x] = true;
      qrCode[x + 1][6] = false;
      qrCode[6][x + 1] = false;
    }

    qrCode[6][size - 7] = true;
    qrCode[size - 7][6] = true;
    // Set dark module
    // qrCode[4 * version + 9][8] = true;
    qrCode[size - 8][8] = true;
  }

  static void _fillCodewords(
      QMatrix qrCode, List<Point<int>> sequence, Uint8List codewords) {
    int index = 0;
    for (var codeword in codewords) {
      for (int i = 7; i >= 0; i--) {
        var bit = codeword >> i & 1 == 1;
        final x = sequence[index].x;
        final y = sequence[index].y;
        qrCode[x][y] = bit;
        index++;
      }
    }
  }

  static void _fillFinders(QMatrix qrCode) {
    var leftTopFinder = Point(0, 0);
    _fillArea(qrCode, leftTopFinder.x, leftTopFinder.y, 8, 8, fill: false);
    _fillArea(qrCode, leftTopFinder.x, leftTopFinder.y, 7, 7);
    _fillArea(qrCode, leftTopFinder.x + 1, leftTopFinder.y + 1, 5, 5,
        fill: false);
    _fillArea(qrCode, leftTopFinder.x + 2, leftTopFinder.y + 2, 3, 3);

    var rightTopFinder = Point(0, qrCode.length - 7);
    _fillArea(qrCode, rightTopFinder.x, rightTopFinder.y - 1, 8, 8,
        fill: false);
    _fillArea(qrCode, rightTopFinder.x, rightTopFinder.y, 7, 7);
    _fillArea(qrCode, rightTopFinder.x + 1, rightTopFinder.y + 1, 5, 5,
        fill: false);
    _fillArea(qrCode, rightTopFinder.x + 2, rightTopFinder.y + 2, 3, 3);

    var leftBottomFinder = Point(qrCode.length - 7, 0);
    _fillArea(qrCode, leftBottomFinder.x - 1, leftBottomFinder.y, 8, 8,
        fill: false);
    _fillArea(qrCode, leftBottomFinder.x, leftBottomFinder.y, 7, 7);
    _fillArea(qrCode, leftBottomFinder.x + 1, leftBottomFinder.y + 1, 5, 5,
        fill: false);
    _fillArea(qrCode, leftBottomFinder.x + 2, leftBottomFinder.y + 2, 3, 3);
  }

  static bool _alignmentOverlaps(QMatrix matrix, Point a) {
    for (int row = a.x.floor() - 2; row <= a.x + 2; row++) {
      for (int col = a.y.floor() - 2; col <= a.y + 2; col++) {
        if (matrix[row][col]) {
          return true;
        }
      }
    }

    return false;
  }
}
