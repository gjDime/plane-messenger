import 'dart:convert';

/// State for a single round in a Color Memory game.
class ColorMemoryRound {
  final int targetColor; // packed 0xRRGGBB
  final int? xGuess;
  final int? oGuess;
  final double? xDistance;
  final double? oDistance;
  final bool xReady;
  final bool oReady;

  const ColorMemoryRound({
    required this.targetColor,
    this.xGuess,
    this.oGuess,
    this.xDistance,
    this.oDistance,
    this.xReady = false,
    this.oReady = false,
  });

  bool get isComplete => xGuess != null && oGuess != null;

  /// Returns 'x', 'o', or 'draw' based on distances. Null if round incomplete.
  String? get winner {
    if (xDistance == null || oDistance == null) return null;
    final diff = xDistance! - oDistance!;
    if (diff.abs() < 0.5) return 'draw';
    return diff < 0 ? 'x' : 'o'; // lower distance = closer guess = winner
  }

  ColorMemoryRound copyWith({
    int? targetColor,
    int? xGuess,
    int? oGuess,
    double? xDistance,
    double? oDistance,
    bool? xReady,
    bool? oReady,
  }) {
    return ColorMemoryRound(
      targetColor: targetColor ?? this.targetColor,
      xGuess: xGuess ?? this.xGuess,
      oGuess: oGuess ?? this.oGuess,
      xDistance: xDistance ?? this.xDistance,
      oDistance: oDistance ?? this.oDistance,
      xReady: xReady ?? this.xReady,
      oReady: oReady ?? this.oReady,
    );
  }

  Map<String, dynamic> toJson() => {
        'targetColor': targetColor,
        if (xGuess != null) 'xGuess': xGuess,
        if (oGuess != null) 'oGuess': oGuess,
        if (xDistance != null) 'xDistance': xDistance,
        if (oDistance != null) 'oDistance': oDistance,
        if (xReady) 'xReady': true,
        if (oReady) 'oReady': true,
      };

  factory ColorMemoryRound.fromJson(Map<String, dynamic> json) {
    return ColorMemoryRound(
      targetColor: json['targetColor'] as int,
      xGuess: json['xGuess'] as int?,
      oGuess: json['oGuess'] as int?,
      xDistance: (json['xDistance'] as num?)?.toDouble(),
      oDistance: (json['oDistance'] as num?)?.toDouble(),
      xReady: json['xReady'] as bool? ?? false,
      oReady: json['oReady'] as bool? ?? false,
    );
  }
}

/// Full state for a Color Memory game (best of 3 rounds).
class ColorMemoryState {
  final int currentRound; // 1-indexed
  final int xRoundsWon;
  final int oRoundsWon;
  final List<ColorMemoryRound> rounds;

  const ColorMemoryState({
    required this.currentRound,
    required this.xRoundsWon,
    required this.oRoundsWon,
    required this.rounds,
  });

  bool get isMatchOver => xRoundsWon >= 2 || oRoundsWon >= 2;

  String? get matchWinner {
    if (xRoundsWon >= 2) return 'x';
    if (oRoundsWon >= 2) return 'o';
    return null;
  }

  ColorMemoryRound? get currentRoundData {
    if (currentRound < 1 || currentRound > rounds.length) return null;
    return rounds[currentRound - 1];
  }

  ColorMemoryState copyWith({
    int? currentRound,
    int? xRoundsWon,
    int? oRoundsWon,
    List<ColorMemoryRound>? rounds,
  }) {
    return ColorMemoryState(
      currentRound: currentRound ?? this.currentRound,
      xRoundsWon: xRoundsWon ?? this.xRoundsWon,
      oRoundsWon: oRoundsWon ?? this.oRoundsWon,
      rounds: rounds ?? this.rounds,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentRound': currentRound,
        'xRoundsWon': xRoundsWon,
        'oRoundsWon': oRoundsWon,
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };

  factory ColorMemoryState.fromJson(Map<String, dynamic> json) {
    return ColorMemoryState(
      currentRound: json['currentRound'] as int,
      xRoundsWon: json['xRoundsWon'] as int,
      oRoundsWon: json['oRoundsWon'] as int,
      rounds: (json['rounds'] as List)
          .map((r) => ColorMemoryRound.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  String serialize() => jsonEncode(toJson());

  static ColorMemoryState? deserialize(String data) {
    if (data.isEmpty) return null;
    return ColorMemoryState.fromJson(
        jsonDecode(data) as Map<String, dynamic>);
  }
}
