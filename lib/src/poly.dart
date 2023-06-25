import 'dart:collection';
import 'dart:typed_data';

import '/src/utils/math.dart';

class Poly extends ListMixin<int> {
  final Uint8List _args;

  int get size => _args.length;

  Uint8List get args => _args;

  Poly(int size) : _args = Uint8List(size);

  Poly.from(List<int> args) : _args = Uint8List.fromList(args);

  Poly multiply(Poly other) {
    var product = Uint8List(size + other.size - 1);

    for (var i = 0; i < product.length; i++) {
      var coeff = 0;
      for (var ai = 0; ai <= i; ai++) {
        final bi = i - ai;
        if (ai < size && bi < other.size) {
          coeff ^= QMath.multiply(this[ai], other[bi]);
        }
      }
      product[i] = coeff;
    }

    return Poly.from(product);
  }

  Poly mod(Poly divisor) {
    final resultLength = length - divisor.length + 1;
    var rest = Poly.from(args);
    for (var count = 0; count < resultLength; count++) {
      if (rest[0] != 0) {
        final factor = QMath.divide(rest[0], divisor[0]);
        var subtr = Poly(rest.length);
        subtr.setAll(0, divisor.multiply(Poly.from([factor])));
        rest = Poly.from(
            rest.asMap().entries.map((e) => e.value ^ subtr[e.key]).toList());
        rest = Poly.from(rest.sublist(1));
      } else {
        rest = Poly.from(rest.sublist(1));
      }
    }
    return rest;
  }

  int degree() {
    for (int i = size - 1; i >= 0; --i) {
      if (this[i] != 0) return i;
    }
    return 0;
  }

  @override
  int get length => _args.length;

  @override
  set length(int value) => throw UnsupportedError('Cannot change');

  @override
  operator [](int index) {
    return _args[index];
  }

  @override
  void operator []=(int index, value) {
    _args[index] = value;
  }
}

Poly getGeneratorPoly(int degree) {
  var lastPoly = Poly.from([1]);
  for (var index = 0; index < degree; index++) {
    lastPoly = lastPoly.multiply(Poly.from([1, QMath.exps[index]]));
  }
  return lastPoly;
}

Poly getEDC(List<int> data, int totalCodewords) {
  final degree = totalCodewords - data.length;
  final messagePoly = Poly(totalCodewords);
  messagePoly.setAll(0, data);
  return messagePoly.mod(getGeneratorPoly(degree));
}
