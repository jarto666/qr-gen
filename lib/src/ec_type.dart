enum ErrorCorrectionLevel {
  low(0.07),
  medium(0.15),
  quartile(0.25),
  high(0.30);

  const ErrorCorrectionLevel(this.value);
  final num value;
}

final ecTable = [
  {
    ErrorCorrectionLevel.low: (7, 1),
    ErrorCorrectionLevel.medium: (10, 1),
    ErrorCorrectionLevel.quartile: (13, 1),
    ErrorCorrectionLevel.high: (17, 1)
  },
  {
    ErrorCorrectionLevel.low: (10, 1),
    ErrorCorrectionLevel.medium: (16, 1),
    ErrorCorrectionLevel.quartile: (22, 1),
    ErrorCorrectionLevel.high: (28, 1)
  },
  {
    ErrorCorrectionLevel.low: (15, 1),
    ErrorCorrectionLevel.medium: (26, 1),
    ErrorCorrectionLevel.quartile: (18, 2),
    ErrorCorrectionLevel.high: (22, 2)
  },
  {
    ErrorCorrectionLevel.low: (20, 1),
    ErrorCorrectionLevel.medium: (18, 2),
    ErrorCorrectionLevel.quartile: (26, 2),
    ErrorCorrectionLevel.high: (16, 4)
  },
  {
    ErrorCorrectionLevel.low: (26, 1),
    ErrorCorrectionLevel.medium: (24, 2),
    ErrorCorrectionLevel.quartile: (18, 4),
    ErrorCorrectionLevel.high: (22, 4)
  },
  {
    ErrorCorrectionLevel.low: (18, 2),
    ErrorCorrectionLevel.medium: (16, 4),
    ErrorCorrectionLevel.quartile: (24, 4),
    ErrorCorrectionLevel.high: (28, 4)
  },
  {
    ErrorCorrectionLevel.low: (20, 2),
    ErrorCorrectionLevel.medium: (18, 4),
    ErrorCorrectionLevel.quartile: (18, 6),
    ErrorCorrectionLevel.high: (26, 5)
  },
  {
    ErrorCorrectionLevel.low: (24, 2),
    ErrorCorrectionLevel.medium: (22, 4),
    ErrorCorrectionLevel.quartile: (22, 6),
    ErrorCorrectionLevel.high: (26, 6)
  },
  {
    ErrorCorrectionLevel.low: (30, 2),
    ErrorCorrectionLevel.medium: (22, 5),
    ErrorCorrectionLevel.quartile: (20, 8),
    ErrorCorrectionLevel.high: (24, 8)
  },
  {
    ErrorCorrectionLevel.low: (18, 4),
    ErrorCorrectionLevel.medium: (26, 5),
    ErrorCorrectionLevel.quartile: (24, 8),
    ErrorCorrectionLevel.high: (28, 8)
  },
  {
    ErrorCorrectionLevel.low: (20, 4),
    ErrorCorrectionLevel.medium: (30, 5),
    ErrorCorrectionLevel.quartile: (28, 8),
    ErrorCorrectionLevel.high: (24, 11)
  },
  {
    ErrorCorrectionLevel.low: (24, 4),
    ErrorCorrectionLevel.medium: (22, 8),
    ErrorCorrectionLevel.quartile: (26, 10),
    ErrorCorrectionLevel.high: (28, 11)
  },
  {
    ErrorCorrectionLevel.low: (26, 4),
    ErrorCorrectionLevel.medium: (22, 9),
    ErrorCorrectionLevel.quartile: (24, 12),
    ErrorCorrectionLevel.high: (22, 16)
  },
  {
    ErrorCorrectionLevel.low: (30, 4),
    ErrorCorrectionLevel.medium: (24, 9),
    ErrorCorrectionLevel.quartile: (20, 16),
    ErrorCorrectionLevel.high: (24, 16)
  },
  {
    ErrorCorrectionLevel.low: (22, 6),
    ErrorCorrectionLevel.medium: (24, 10),
    ErrorCorrectionLevel.quartile: (30, 12),
    ErrorCorrectionLevel.high: (24, 18)
  },
  {
    ErrorCorrectionLevel.low: (24, 6),
    ErrorCorrectionLevel.medium: (28, 10),
    ErrorCorrectionLevel.quartile: (24, 17),
    ErrorCorrectionLevel.high: (30, 16)
  },
  {
    ErrorCorrectionLevel.low: (28, 6),
    ErrorCorrectionLevel.medium: (28, 11),
    ErrorCorrectionLevel.quartile: (28, 16),
    ErrorCorrectionLevel.high: (28, 19)
  },
  {
    ErrorCorrectionLevel.low: (30, 6),
    ErrorCorrectionLevel.medium: (26, 13),
    ErrorCorrectionLevel.quartile: (28, 18),
    ErrorCorrectionLevel.high: (28, 21)
  },
  {
    ErrorCorrectionLevel.low: (28, 7),
    ErrorCorrectionLevel.medium: (26, 14),
    ErrorCorrectionLevel.quartile: (26, 21),
    ErrorCorrectionLevel.high: (26, 25)
  },
  {
    ErrorCorrectionLevel.low: (28, 8),
    ErrorCorrectionLevel.medium: (26, 16),
    ErrorCorrectionLevel.quartile: (30, 20),
    ErrorCorrectionLevel.high: (28, 25)
  },
  {
    ErrorCorrectionLevel.low: (28, 8),
    ErrorCorrectionLevel.medium: (26, 17),
    ErrorCorrectionLevel.quartile: (28, 23),
    ErrorCorrectionLevel.high: (30, 25)
  },
  {
    ErrorCorrectionLevel.low: (28, 9),
    ErrorCorrectionLevel.medium: (28, 17),
    ErrorCorrectionLevel.quartile: (30, 23),
    ErrorCorrectionLevel.high: (24, 34)
  },
  {
    ErrorCorrectionLevel.low: (30, 9),
    ErrorCorrectionLevel.medium: (28, 18),
    ErrorCorrectionLevel.quartile: (30, 25),
    ErrorCorrectionLevel.high: (30, 30)
  },
  {
    ErrorCorrectionLevel.low: (30, 10),
    ErrorCorrectionLevel.medium: (28, 20),
    ErrorCorrectionLevel.quartile: (30, 27),
    ErrorCorrectionLevel.high: (30, 32)
  },
  {
    ErrorCorrectionLevel.low: (26, 12),
    ErrorCorrectionLevel.medium: (28, 21),
    ErrorCorrectionLevel.quartile: (30, 29),
    ErrorCorrectionLevel.high: (30, 35)
  },
  {
    ErrorCorrectionLevel.low: (28, 12),
    ErrorCorrectionLevel.medium: (28, 23),
    ErrorCorrectionLevel.quartile: (28, 34),
    ErrorCorrectionLevel.high: (30, 37)
  },
  {
    ErrorCorrectionLevel.low: (30, 12),
    ErrorCorrectionLevel.medium: (28, 25),
    ErrorCorrectionLevel.quartile: (30, 34),
    ErrorCorrectionLevel.high: (30, 40)
  },
  {
    ErrorCorrectionLevel.low: (30, 13),
    ErrorCorrectionLevel.medium: (28, 26),
    ErrorCorrectionLevel.quartile: (30, 35),
    ErrorCorrectionLevel.high: (30, 42)
  },
  {
    ErrorCorrectionLevel.low: (30, 14),
    ErrorCorrectionLevel.medium: (28, 28),
    ErrorCorrectionLevel.quartile: (30, 38),
    ErrorCorrectionLevel.high: (30, 45)
  },
  {
    ErrorCorrectionLevel.low: (30, 15),
    ErrorCorrectionLevel.medium: (28, 29),
    ErrorCorrectionLevel.quartile: (30, 40),
    ErrorCorrectionLevel.high: (30, 48)
  },
  {
    ErrorCorrectionLevel.low: (30, 16),
    ErrorCorrectionLevel.medium: (28, 31),
    ErrorCorrectionLevel.quartile: (30, 43),
    ErrorCorrectionLevel.high: (30, 51)
  },
  {
    ErrorCorrectionLevel.low: (30, 17),
    ErrorCorrectionLevel.medium: (28, 33),
    ErrorCorrectionLevel.quartile: (30, 45),
    ErrorCorrectionLevel.high: (30, 54)
  },
  {
    ErrorCorrectionLevel.low: (30, 18),
    ErrorCorrectionLevel.medium: (28, 35),
    ErrorCorrectionLevel.quartile: (30, 48),
    ErrorCorrectionLevel.high: (30, 57)
  },
  {
    ErrorCorrectionLevel.low: (30, 19),
    ErrorCorrectionLevel.medium: (28, 37),
    ErrorCorrectionLevel.quartile: (30, 51),
    ErrorCorrectionLevel.high: (30, 60)
  },
  {
    ErrorCorrectionLevel.low: (30, 19),
    ErrorCorrectionLevel.medium: (28, 38),
    ErrorCorrectionLevel.quartile: (30, 53),
    ErrorCorrectionLevel.high: (30, 63)
  },
  {
    ErrorCorrectionLevel.low: (30, 20),
    ErrorCorrectionLevel.medium: (28, 40),
    ErrorCorrectionLevel.quartile: (30, 56),
    ErrorCorrectionLevel.high: (30, 66)
  },
  {
    ErrorCorrectionLevel.low: (30, 21),
    ErrorCorrectionLevel.medium: (28, 43),
    ErrorCorrectionLevel.quartile: (30, 59),
    ErrorCorrectionLevel.high: (30, 70)
  },
  {
    ErrorCorrectionLevel.low: (30, 22),
    ErrorCorrectionLevel.medium: (28, 45),
    ErrorCorrectionLevel.quartile: (30, 62),
    ErrorCorrectionLevel.high: (30, 74)
  },
  {
    ErrorCorrectionLevel.low: (30, 24),
    ErrorCorrectionLevel.medium: (28, 47),
    ErrorCorrectionLevel.quartile: (30, 65),
    ErrorCorrectionLevel.high: (30, 77)
  },
  {
    ErrorCorrectionLevel.low: (30, 25),
    ErrorCorrectionLevel.medium: (28, 49),
    ErrorCorrectionLevel.quartile: (30, 68),
    ErrorCorrectionLevel.high: (30, 81)
  }
];
