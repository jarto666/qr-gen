import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '/src/poly.dart';

import 'bit_buffer.dart';
import 'ec_type.dart';
import 'extensions/string.dart';
import 'encoding_type.dart';

class QEncodedData {
  final Uint8List words;
  final EncodingType encodingType;
  final int version;
  final ErrorCorrectionLevel errorCorrectionLevel;

  QEncodedData(
      this.words, this.encodingType, this.version, this.errorCorrectionLevel);
}

abstract class QEncoder {
  final Uint8List _data;
  final EncodingType _encodingType;

  final String _originalString;

  QEncoder(this._data, this._encodingType, this._originalString);

  factory QEncoder.create(String data) {
    var encodingMode = data.getEncodingMode();
    switch (encodingMode) {
      case EncodingType.numeric:
        return QNumericEncoder.fromString(data);
      case EncodingType.alphanumeric:
        return QAlphanumericEncoder.fromString(data);
      case EncodingType.kanji:
        return QKanjiEncoder.fromString(data);
      case EncodingType.byte:
      default:
        return QByteEncoder.fromString(data);
    }
  }

  // * Actual [data] encoding
  void _encodeData(BitBuffer bitBuffer);

  QEncodedData encode(ErrorCorrectionLevel minErrorCorrectionLevel) {
    final (version, errorCorrectionLevel) = getVersionAndErrorLevel(
        _encodingType, _data.length,
        minErrorLevel: minErrorCorrectionLevel);
    var lengthBits = getLengthBits(_encodingType, version);
    final dataCodewordsCount =
        _getDataCodewordsCount(version, errorCorrectionLevel);
    final (ecBlockSize, blocks) = ecTable[version - 1][errorCorrectionLevel]!;

    final BitBuffer bitBuffer = BitBuffer();
    bitBuffer
      ..put(_encodingType.value, 4)
      ..put(_data.length, lengthBits); // * Next [length bits] encode [length]

    _encodeData(bitBuffer);

    while (bitBuffer.length % 8 != 0) {
      bitBuffer.putBit(false); // * Fill the rest of the last word with 0
    }

    var wordsLeft = dataCodewordsCount - (bitBuffer.length ~/ 8);
    for (int i = 0; i < wordsLeft; i++) {
      bitBuffer.put(
          i % 2 == 0 ? 236 : 17, 8); // * Fill the rest of words with 237 and 17
    }

    final rawData = bitBuffer.words;

    final data = _reorderData(rawData, blocks);
    final ecData = _getECData(rawData, blocks, ecBlockSize);

    final codewords = Uint8List(data.length + ecData.length);

    codewords.setAll(0, data);
    codewords.setAll(data.length, ecData);

    return QEncodedData(
        codewords, _encodingType, version, errorCorrectionLevel);
  }

  Poly _getECData(List<int> data, int blocks, int ecBlockSize) {
    /** Codewords in data blocks (in group 1) */
    final dataBlockSize = (data.length / blocks).floor();
    /** Blocks in group 1 */
    final group1 = blocks - data.length % blocks;
    final ecData = Uint8List(ecBlockSize * blocks);
    for (var offset = 0; offset < blocks; offset++) {
      final start = offset < group1
          ? dataBlockSize * offset
          : (dataBlockSize + 1) * offset - group1;
      final end = start + dataBlockSize + (offset < group1 ? 0 : 1);
      final dataBlock = data.sublist(start, end);
      final ecCodewords = getEDC(dataBlock, dataBlock.length + ecBlockSize);
      // Interleaving the EC codewords: we place one every `blocks`
      for (var i = 0; i < ecCodewords.length; i++) {
        final codeword = ecCodewords[i];
        ecData[i * blocks + offset] = codeword;
      }
    }
    return Poly.from(ecData);
  }

  List<int> _reorderData(List<int> words, int blocks) {
    /** Codewords in data blocks (in group 1) */
    final blockSize = (words.length / blocks).floor();
    /** Blocks in group 1 */
    final group1 = blocks - words.length % blocks;
    /** Starting index of each block inside `data` */
    final blockStartIndexes = List.generate(
        blocks,
        (index) => index < group1
            ? blockSize * index
            : (blockSize + 1) * index - group1);

    final reordered = Uint8List(words.length);
    for (var i = 0; i < reordered.length; i++) {
      final blockOffset = (i / blocks).floor();
      final blockIndex = (i % blocks) + (blockOffset == blockSize ? group1 : 0);
      final codewordIndex = blockStartIndexes[blockIndex] + blockOffset;
      reordered[i] = words[codewordIndex];
    }

    return reordered;
  }

  int _getAvailableModules(int version) {
    if (version == 1) {
      return 21 * 21 - 3 * 8 * 8 - 2 * 15 - 1 - 2 * 5;
    }
    final alignmentCount = (version / 7).floor() + 2;
    return (pow(version * 4 + 17, 2) -
            3 * 8 * 8 -
            (pow(alignmentCount, 2) - 3) * 5 * 5 -
            2 * (version * 4 + 1) +
            (alignmentCount - 2) * 5 * 2 -
            2 * 15 -
            1 -
            (version > 6 ? 2 * 3 * 6 : 0))
        .toInt();
  }

  int _getDataCodewordsCount(int version, ErrorCorrectionLevel errorLevel) {
    final totalCodewords = _getAvailableModules(version) >> 3;
    final (blocks, ecBlockSize) = ecTable[version - 1][errorLevel]!;
    return totalCodewords - blocks * ecBlockSize;
  }

  int _getCapacity(
      int version, ErrorCorrectionLevel errorLevel, EncodingType encodingMode) {
    final dataCodewordsCount = _getDataCodewordsCount(version, errorLevel);
    final lengthBits = getLengthBits(encodingMode, version);
    final int availableBits = (dataCodewordsCount << 3) - lengthBits - 4;
    switch (encodingMode) {
      case EncodingType.numeric:
        {
          final remainderBits = availableBits % 10;
          return (availableBits / 10).floor() * 3 +
              (remainderBits > 6
                  ? 2
                  : remainderBits > 3
                      ? 1
                      : 0);
        }

      case EncodingType.alphanumeric:
        return (availableBits / 11).floor() * 2 +
            (availableBits % 11 > 5 ? 1 : 0);

      case EncodingType.kanji:
        return (availableBits / 13).floor();

      case EncodingType.byte:
      default:
        return availableBits >> 3;
    }
  }

  static const _edcOrder = [
    ErrorCorrectionLevel.high,
    ErrorCorrectionLevel.quartile,
    ErrorCorrectionLevel.medium,
    ErrorCorrectionLevel.low,
  ];

  (int version, ErrorCorrectionLevel errorCorrectionLevel)
      getVersionAndErrorLevel(EncodingType encodingMode, int contentLength,
          {ErrorCorrectionLevel minErrorLevel = ErrorCorrectionLevel.low}) {
    // The error levels we're going to consider
    final errorLevels =
        _edcOrder.sublist(0, _edcOrder.indexOf(minErrorLevel) + 1);
    for (var version = 1; version <= 40; version++) {
      // You can iterate over strings in JavaScript 😁
      for (var errorLevel in errorLevels) {
        final capacity = _getCapacity(version, errorLevel, encodingMode);
        if (capacity >= contentLength) {
          return (version, errorLevel);
        }
      }
    }

    return (-1, ErrorCorrectionLevel.low);
  }
}

class QByteEncoder extends QEncoder {
  QByteEncoder.fromString(String data)
      : super(utf8.encoder.convert(data), EncodingType.byte, data);

  @override
  void _encodeData(BitBuffer bitBuffer) {
    for (var element in _data) {
      bitBuffer.put(element, 8);
    }
  }
}

// TODO: Not implemented yet
class QEciEncoder extends QEncoder {
  QEciEncoder.fromString(String data)
      : super(utf8.encoder.convert(data), EncodingType.eci, data);

  @override
  void _encodeData(BitBuffer bitBuffer) {
    throw UnimplementedError();
  }
}

// TODO: Doesn't work for specific input lengths. To fix.
class QNumericEncoder extends QEncoder {
  QNumericEncoder.fromString(String data)
      : super(Uint8List.fromList(data.codeUnits.map((e) => e - 0x30).toList()),
            EncodingType.numeric, data);

  static const _bitWidths = [0, 4, 7, 10];

  @override
  void _encodeData(BitBuffer bitBuffer) {
    // for (var i = 0; i < _originalString.length; i += 3) {
    //   final chunk =
    //       _originalString.substring(i, min(i + 3, _originalString.length));
    //   final bitLength = _bitWidths[chunk.length];
    //   final value = int.parse(chunk);
    //   bitBuffer.put(value, bitLength);
    // }

    final leftOver = _data.length % 3;

    final efficientGrab = _data.length - leftOver;
    for (var i = 0; i < efficientGrab; i += 3) {
      final encoded = _data[i] * 100 + _data[i + 1] * 10 + _data[i + 2];
      bitBuffer.put(encoded, 10);
    }
    if (leftOver > 1) {
      // 2 bytes
      bitBuffer.put(_data[_data.length - 2] * 10 + _data[_data.length - 1], 7);
    } else if (leftOver > 0) {
      // 1 byte
      bitBuffer.put(_data.last, 4);
    }
  }
}

// TODO: Doesn't work for specific input lengths. To fix.
class QAlphanumericEncoder extends QEncoder {
  QAlphanumericEncoder.fromString(String data)
      : super(utf8.encoder.convert(data), EncodingType.alphanumeric, data);

  static const alphaNumTable = r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:';

  static final encodeArray = () {
    final array = List<int?>.filled(91, null);
    for (var i = 0; i < alphaNumTable.length; i++) {
      final char = alphaNumTable.codeUnitAt(i);
      array[char] = i;
    }
    return array;
  }();

  @override
  void _encodeData(BitBuffer bitBuffer) {
    final leftOver = _originalString.length % 2;

    final efficientGrab = _originalString.length - leftOver;
    for (var i = 0; i < efficientGrab; i += 2) {
      final encoded = encodeArray[_originalString.codeUnitAt(i)]! * 45 +
          encodeArray[_originalString.codeUnitAt(i + 1)]!;
      bitBuffer.put(encoded, 11);
    }
    if (leftOver > 0) {
      // N*5 + 1 = 6
      bitBuffer.put(
          encodeArray[_originalString.codeUnitAt(_originalString.length - 1)]!,
          6);
    }
  }
}

// TODO: Not implemented yet
class QKanjiEncoder extends QEncoder {
  QKanjiEncoder.fromString(String data)
      : super(utf8.encoder.convert(data), EncodingType.kanji, data);

  @override
  void _encodeData(BitBuffer bitBuffer) {
    throw UnimplementedError();
  }
}
