import 'dart:collection';

class BitBuffer extends ListMixin<bool> {
  final List<int> _words = <int>[];
  int _length = 0;

  int get _currentWordIndex => _length ~/ 8;

  List<int> get words => _words;

  @override
  void operator []=(int index, bool value) =>
      throw UnsupportedError('cannot change');

  @override
  bool operator [](int index) {
    var wordIndex = index ~/ 8;
    var bitIndexInWord = 7 - index % 8;
    return (_words[wordIndex] >> bitIndexInWord) & 1 == 1;
  }

  @override
  int get length => _length;

  @override
  set length(int value) => throw UnsupportedError('Cannot change');

  int getByte(int index) => _words[index];

  void put(int number, int length) {
    for (var i = 0; i < length; i++) {
      bool bit = (number >> (length - 1 - i)) & 1 == 1;
      putBit(bit);
    }
  }

  void putBit(bool bit) {
    final wordIndex = _currentWordIndex;
    if (wordIndex >= _words.length) {
      _words.add(0);
    }

    if (bit) {
      _words[wordIndex] |= 128 >> (_length % 8);
    }

    _length++;
  }
}
