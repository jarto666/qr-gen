import 'dart:typed_data';

final logarithms = buildLogarithms();

Uint8List buildLogarithms() {
  final list = Uint8List(256);

  for (var e = 1, val = 1; e < 256; e++) {
    val = val > 127 ? ((val << 1) ^ 285) : val << 1;
    list[val] = e % 255;
  }

  return list;
}

class QMath {
  static final Uint8List logs = _buildLogarithms();
  static final Uint8List exps = _buildExponents();

  static Uint8List _buildLogarithms() {
    final list = Uint8List(256);

    for (var e = 1, val = 1; e < 256; e++) {
      val = val > 127 ? ((val << 1) ^ 285) : val << 1;
      list[val] = e % 255;
    }

    return list;
  }

  static Uint8List _buildExponents() {
    final list = Uint8List(256);

    for (var e = 1, val = 1; e < 256; e++) {
      val = val > 127 ? ((val << 1) ^ 285) : val << 1;
      list[e % 255] = val;
    }

    return list;
  }

  static int multiply(int a, int b) {
    return (a != 0 && b != 0) ? exps[(logs[a] + logs[b]) % 255] : 0;
  }

  static int divide(int a, int b) {
    return exps[(logs[a] + logs[b] * 254) % 255];
  }
}
