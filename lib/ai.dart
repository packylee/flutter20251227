import 'dart:math';
import 'game.dart';

class SimpleAI {
  int _difficulty = 3;
  final Random _rng = Random();

  int get difficulty => _difficulty;
  set difficulty(int v) {
    _difficulty = v.clamp(1, 5);
  }

  // backward-compatible method used by UI
  void setDifficulty(int v) => difficulty = v;

  int chooseMove(Game game) {
    var moves = game.legalMoves(-1);
    if (moves.isEmpty) return -1;

    // Evaluate moves: base score = number of flips
    // Add corner preference for higher difficulties
    List<int> corners = [0, Game.size - 1, Game.size * (Game.size - 1), Game.size * Game.size - 1];
    int best = moves.first;
    double bestScore = -1e9;
    for (var m in moves) {
      var flips = game.flipsForMove(m, -1);
      double score = flips.length.toDouble();
      if (corners.contains(m)) score += 100.0;
      // penalty for moves adjacent to corners (likely bad)
      if ([1, Game.size, Game.size + 1].contains(m)) score -= 50;
      // adjust randomness by difficulty
      double noise = 0.0;
      switch (_difficulty) {
        case 1:
          noise = _rng.nextDouble() * 10; // very random
          break;
        case 2:
          noise = _rng.nextDouble() * 6;
          break;
        case 3:
          noise = _rng.nextDouble() * 3;
          break;
        case 4:
          noise = _rng.nextDouble() * 1.5;
          break;
        case 5:
          noise = _rng.nextDouble() * 0.5;
          break;
      }
      score += noise;
      if (score > bestScore) {
        bestScore = score;
        best = m;
      }
    }
    return best;
  }
}
