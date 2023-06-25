import 'dart:convert';

import '../encoding_type.dart';

extension StringExtensions on String {
  static final _numericRE = RegExp(r'^\d*$');
  static final _alphanumericRE = RegExp(r'^[\dA-Z $%*+\-./:]*$');
  static final _latin1RE = RegExp(r'^[\x00-\xff]*$');
  static final _kanjiRE = RegExp(
      r'^[\p{Script_Extensions=Han}\p{Script_Extensions=Hiragana}\p{Script_Extensions=Katakana}]*$');

  EncodingType getEncodingMode() {
    if (_numericRE.hasMatch(this)) {
      return EncodingType.numeric;
    }

    if (_alphanumericRE.hasMatch(this)) {
      return EncodingType.alphanumeric;
    }

    if (_latin1RE.hasMatch(this)) {
      return EncodingType.byte;
    }

    if (_kanjiRE.hasMatch(this)) {
      return EncodingType.kanji;
    }

    return EncodingType.byte; // TODO: Ideally should be ECI
  }

  int toByteFirst() {
    final latin1Encoder = latin1.encoder;
    return latin1Encoder.convert(this[0])[0];
  }
}
