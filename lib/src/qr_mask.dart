import 'dart:math';

import '/src/qr_code.dart';

var maskingFunctions = [
  (int row, int col) => (row + col) % 2 == 0,
  (int row, int col) => row % 2 == 0,
  (int row, int col) => col % 3 == 0,
  (int row, int col) => (row + col) % 3 == 0,
  (int row, int col) => ((row / 2).floor() + (col / 3).floor()) % 2 == 0,
  (int row, int col) => (row * col) % 2 + (row * col) % 3 == 0,
  (int row, int col) => ((row * col) % 2 + (row * col) % 3) % 2 == 0,
  (int row, int col) => ((row + col) % 2 + (row * col) % 3) % 2 == 0,
];

int mask(QMatrix qrCode, List<Point<int>> sequence) {
  int bestMaskIndex = 0;
  int minPenalty = 9999999999;

  for (var i = 0; i < maskingFunctions.length; i++) {
    final maskFun = maskingFunctions[i];

    // Mask
    var maskedMatrix =
        QMatrix.generate(qrCode.length, (i) => List.from(qrCode[i]));
    for (var point in sequence) {
      maskedMatrix[point.x][point.y] = maskFun(point.x, point.y)
          ? !maskedMatrix[point.x][point.y]
          : maskedMatrix[point.x][point.y];
    }

    // Calculate penalty
    int penalty = 0;
    penalty += evaluation_1(maskedMatrix);
    penalty += evaluation_2(maskedMatrix);
    penalty += evaluation_3(maskedMatrix);
    penalty += evaluation_4(maskedMatrix);

    if (penalty < minPenalty) {
      bestMaskIndex = i;
    }
  }

  // bestMaskIndex = 6;

  for (var point in sequence) {
    qrCode[point.x][point.y] = maskingFunctions[bestMaskIndex](point.x, point.y)
        ? !qrCode[point.x][point.y]
        : qrCode[point.x][point.y];
  }

  return bestMaskIndex;
}

// * The first rule gives the QR code a penalty for each group of five or more same-colored modules in a row (or column).
// * Penalty += totalConsequtiveBits - 2
int evaluation_1(QMatrix qrCode) {
  var penalty = 0;

  // 2 pointers
  for (var row = 0; row < qrCode.length; row++) {
    int i = 0;
    int j = 0;

    while (i < qrCode.length) {
      while (j < qrCode.length && qrCode[row][i] == qrCode[row][j]) {
        j++;
      }

      final totalConsequtiveBits = j - i;
      if (totalConsequtiveBits >= 5) {
        penalty += (3 + totalConsequtiveBits - 5);
      }

      i = j;
    }
  }

  for (var col = 0; col < qrCode.length; col++) {
    int i = 0;
    int j = 0;

    while (i < qrCode.length) {
      while (j < qrCode.length && qrCode[i][col] == qrCode[j][col]) {
        j++;
      }

      final totalConsequtiveBits = j - i + 1;
      if (totalConsequtiveBits >= 5) {
        penalty += totalConsequtiveBits - 2;
      }

      i = j;
    }
  }

  return penalty;
}

// TODO: Optimize
// * The second rule gives the QR code a penalty for each 2x2 area of same-colored modules in the matrix.
int evaluation_2(QMatrix qrCode) {
  var penalty = 0;

  for (var row = 0; row < qrCode.length - 1; row++) {
    for (var col = 0; col < qrCode.length - 1; col++) {
      if (qrCode[row][col] == qrCode[row + 1][col] &&
          qrCode[row][col] == qrCode[row][col + 1] &&
          qrCode[row][col] == qrCode[row + 1][col + 1]) {
        penalty += 3;
      }
    }
  }

  return penalty;
}

const eval3Condition1 = [
  true,
  false,
  true,
  true,
  true,
  false,
  true,
  false,
  false,
  false,
  false
];
const eval3Condition2 = [
  false,
  false,
  false,
  false,
  true,
  false,
  true,
  true,
  true,
  false,
  true
];

// TODO: Optimize
// * The third penalty rule looks for patterns of dark-light-dark-dark-dark-light-dark that have four light modules on either side.
// * 10111010000 or 00001011101
int evaluation_3(QMatrix qrCode) {
  var penalty = 0;

  for (var row = 0; row < qrCode.length - eval3Condition1.length; row++) {
    for (var col = 0; col < qrCode.length - eval3Condition1.length; col++) {
      // Eval 1
      for (var i = 0; i < eval3Condition1.length; i++) {
        if (qrCode[row][col + i] != eval3Condition1[i]) {
          break;
        }

        if (i == eval3Condition1.length - 1) {
          penalty += 40;
        }
      }
      for (var i = 0; i < eval3Condition1.length; i++) {
        if (qrCode[row + i][col] != eval3Condition1[i]) {
          break;
        }

        if (i == eval3Condition1.length - 1) {
          penalty += 40;
        }
      }

      // Eval 2
      for (var i = 0; i < eval3Condition2.length; i++) {
        if (qrCode[row][col + i] != eval3Condition2[i]) {
          break;
        }

        if (i == eval3Condition2.length - 1) {
          penalty += 40;
        }
      }
      for (var i = 0; i < eval3Condition2.length; i++) {
        if (qrCode[row + i][col] != eval3Condition2[i]) {
          break;
        }

        if (i == eval3Condition2.length - 1) {
          penalty += 40;
        }
      }
    }
  }

  return penalty;
}

// TODO: Optimize
// * The final evaluation condition is based on the ratio of light modules to dark modules.
int evaluation_4(QMatrix qrCode) {
  var penalty = 0;

  final totalModules = qrCode.length * qrCode.length;
  var darkModules = 0;

  for (var i = 0; i < qrCode.length; i++) {
    darkModules += qrCode[i].where((e) => e).length;
  }

  var darkRate = darkModules * 100 / totalModules;
  int rounded =
      darkRate > 50 ? (darkRate / 5).floor() * 5 : (darkRate / 5).ceil() * 5;

  penalty = (rounded - 50).abs() * 2;

  return penalty;
}
