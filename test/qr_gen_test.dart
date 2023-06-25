import 'package:qr_gen/qr_gen.dart';
import 'package:test/test.dart';

void main() {
  test('creates QR code successfully', () {
    final qrCode = QrCode("Sample text!", ErrorCorrectionLevel.quartile);

    expect(qrCode.version, 2);
    expect(qrCode.encodingType, EncodingType.byte);
    expect(qrCode.maskIndex, 7);
    expect(qrCode.matrix.length, 25);
  });
}
