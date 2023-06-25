import '../../qr_gen.dart';

extension QMatrixExtensions on QMatrix {
  bool isDark(int x, int y) => this[x][y];
}
