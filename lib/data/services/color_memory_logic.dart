import 'dart:math';

import 'package:plane_messenger/data/models/color_memory_state.dart';

class ColorMemoryLogic {
  /// Returns a packed 0xRRGGBB int with constrained HSV (H=0-360, S=0.4-1.0, V=0.3-0.9).
  static int generateRandomColor({Random? random}) {
    final rng = random ?? Random();
    final h = rng.nextDouble() * 360.0;
    final s = 0.4 + rng.nextDouble() * 0.6;
    final v = 0.3 + rng.nextDouble() * 0.6;
    return _hsvToRgb(h, s, v);
  }

  /// CIEDE2000 perceptual color distance between two packed RGB ints.
  static double colorDistance(int color1, int color2) {
    final lab1 = _rgbToLab(color1);
    final lab2 = _rgbToLab(color2);
    return _deltaE00(lab1, lab2);
  }

  static double scoreFromDistance(double dE) {
    return 10.0 / (1.0 + pow(dE / 25.25, 1.55));
  }

  /// Returns 'x', 'o', or 'draw'. Draw if within 0.5 dE tolerance.
  static String roundWinner(double xDist, double oDist) {
    final diff = xDist - oDist;
    if (diff.abs() < 0.5) return 'draw';
    return diff < 0 ? 'x' : 'o';
  }

  /// Dealer is player X for rounds 1,3; player O for round 2.
  static bool dealerIsPlayerX(int round) => round != 2;

  static ColorMemoryState initialState() {
    return const ColorMemoryState(
      currentRound: 1,
      xRoundsWon: 0,
      oRoundsWon: 0,
      rounds: [],
    );
  }

  static int _hsvToRgb(double h, double s, double v) {
    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;

    double r, g, b;
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }

    final ri = ((r + m) * 255).round().clamp(0, 255);
    final gi = ((g + m) * 255).round().clamp(0, 255);
    final bi = ((b + m) * 255).round().clamp(0, 255);
    return (ri << 16) | (gi << 8) | bi;
  }

  static List<double> _rgbToLab(int rgb) {
    var r = ((rgb >> 16) & 0xFF) / 255.0;
    var g = ((rgb >> 8) & 0xFF) / 255.0;
    var b = (rgb & 0xFF) / 255.0;

    r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
    g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
    b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

    var x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375;
    var y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750;
    var z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041;

    x /= 0.95047;
    y /= 1.00000;
    z /= 1.08883;

    x = x > 0.008856 ? pow(x, 1.0 / 3.0).toDouble() : (7.787 * x) + 16.0 / 116.0;
    y = y > 0.008856 ? pow(y, 1.0 / 3.0).toDouble() : (7.787 * y) + 16.0 / 116.0;
    z = z > 0.008856 ? pow(z, 1.0 / 3.0).toDouble() : (7.787 * z) + 16.0 / 116.0;

    final l = (116.0 * y) - 16.0;
    final a = 500.0 * (x - y);
    final bLab = 200.0 * (y - z);

    return [l, a, bLab];
  }

  static double _deltaE00(List<double> lab1, List<double> lab2) {
    final l1 = lab1[0], a1 = lab1[1], b1 = lab1[2];
    final l2 = lab2[0], a2 = lab2[1], b2 = lab2[2];

    final c1 = sqrt(a1 * a1 + b1 * b1);
    final c2 = sqrt(a2 * a2 + b2 * b2);
    final cAvg = (c1 + c2) / 2.0;

    final cAvg7 = pow(cAvg, 7);
    final g = 0.5 * (1 - sqrt(cAvg7 / (cAvg7 + pow(25, 7))));

    final a1p = a1 * (1 + g);
    final a2p = a2 * (1 + g);

    final c1p = sqrt(a1p * a1p + b1 * b1);
    final c2p = sqrt(a2p * a2p + b2 * b2);

    var h1p = atan2(b1, a1p) * 180.0 / pi;
    if (h1p < 0) h1p += 360.0;
    var h2p = atan2(b2, a2p) * 180.0 / pi;
    if (h2p < 0) h2p += 360.0;

    final dLp = l2 - l1;
    final dCp = c2p - c1p;

    double dhp;
    if (c1p * c2p == 0) {
      dhp = 0;
    } else if ((h2p - h1p).abs() <= 180) {
      dhp = h2p - h1p;
    } else if (h2p - h1p > 180) {
      dhp = h2p - h1p - 360;
    } else {
      dhp = h2p - h1p + 360;
    }

    final dHp = 2 * sqrt(c1p * c2p) * sin(dhp * pi / 360.0);

    final lAvg = (l1 + l2) / 2.0;
    final cAvgP = (c1p + c2p) / 2.0;

    double hAvgP;
    if (c1p * c2p == 0) {
      hAvgP = h1p + h2p;
    } else if ((h1p - h2p).abs() <= 180) {
      hAvgP = (h1p + h2p) / 2.0;
    } else if (h1p + h2p < 360) {
      hAvgP = (h1p + h2p + 360) / 2.0;
    } else {
      hAvgP = (h1p + h2p - 360) / 2.0;
    }

    final t = 1 -
        0.17 * cos((hAvgP - 30) * pi / 180) +
        0.24 * cos(2 * hAvgP * pi / 180) +
        0.32 * cos((3 * hAvgP + 6) * pi / 180) -
        0.20 * cos((4 * hAvgP - 63) * pi / 180);

    final lAvg50sq = (lAvg - 50) * (lAvg - 50);
    final sl = 1 + 0.015 * lAvg50sq / sqrt(20 + lAvg50sq);
    final sc = 1 + 0.045 * cAvgP;
    final sh = 1 + 0.015 * cAvgP * t;

    final cAvgP7 = pow(cAvgP, 7);
    final rc = 2 * sqrt(cAvgP7 / (cAvgP7 + pow(25, 7)));
    final dTheta = 30 * exp(-pow((hAvgP - 275) / 25, 2));
    final rt = -sin(2 * dTheta * pi / 180) * rc;

    final dE = sqrt(pow(dLp / sl, 2) +
        pow(dCp / sc, 2) +
        pow(dHp / sh, 2) +
        rt * (dCp / sc) * (dHp / sh));

    return dE;
  }
}
