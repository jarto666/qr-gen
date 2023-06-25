Dart QR Codes generation library

# How to use
Install library from pub.dev
```dart
TODO: WIP
```

Import the library in your project
```dart
import 'package:qr_gen/qr_gen.dart';
```

To create a qrCode instance:
```dart
final qrCode = QrCode({STRING_TEXT}, {MINIMUM_ERROR_CORRECTION_LEVEL});
// final qrCode = QrCode("Sample text!", ErrorCorrectionLevel.quartile);
```

Flutter example usage with image package:
```dart
// Get QR code matrix (List<List<bool>> - true = dark module, false - light module)
final qr = qrCode.matrix;
// Create Image instance to paint QR code on
final image = img.Image(width: qr.length, height: qr.length);
for (int i = 0; i < qr.length; i++) {
  for (int j = 0; j < qr.length; j++) {
    if (qr.isDark(i, j)) {
      image.setPixelRgb(j, i, 0, 0, 0);
    } else {
      image.setPixelRgb(j, i, 255, 255, 255);
    }
  }
}

var resizedImage = img.copyResize(image, width: 200);
final png = img.encodePng(resizedImage);
Image imageWidget; = Image.memory(png);
```
