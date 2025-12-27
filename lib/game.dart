// Minimal Reversi game engine used by main.dart
class Game {
  static const int size = 8;
  late List<int> board; // 1 = black, -1 = white, 0 = empty
  int currentPlayer = 1; // 1 = black (human), -1 = white (AI)

  // history stores snapshots of board after each move (deep copies)
  final List<List<int>> _history = [];

  Game() {
    reset();
  }

  void reset() {
    board = List<int>.filled(size * size, 0);
    // starting position
    int mid = size ~/ 2;
    board[_idx(mid - 1, mid - 1)] = -1;
    board[_idx(mid, mid)] = -1;
    board[_idx(mid - 1, mid)] = 1;
    board[_idx(mid, mid - 1)] = 1;
    currentPlayer = 1;
    _history.clear();
    _history.add(List<int>.from(board));
  }

  int _idx(int r, int c) => r * size + c;

  bool _inBounds(int r, int c) => r >= 0 && r < size && c >= 0 && c < size;

  List<int> flipsForMove(int idx, int player) {
    if (idx < 0 || idx >= size * size) return [];
    if (board[idx] != 0) return [];
    int r = idx ~/ size;
    int c = idx % size;
    List<int> flips = [];
    List<List<int>> dirs = [
      [ -1, -1 ], [ -1, 0 ], [ -1, 1 ],
      [ 0, -1 ],           [ 0, 1 ],
      [ 1, -1 ], [ 1, 0 ], [ 1, 1 ],
    ];
    for (var d in dirs) {
      int rr = r + d[0];
      int cc = c + d[1];
      List<int> thisDir = [];
      while (_inBounds(rr, cc) && board[_idx(rr, cc)] == -player) {
        thisDir.add(_idx(rr, cc));
        rr += d[0];
        cc += d[1];
      }
      if (_inBounds(rr, cc) && board[_idx(rr, cc)] == player && thisDir.isNotEmpty) {
        flips.addAll(thisDir);
      }
    }
    return flips;
  }

  List<int> legalMoves(int player) {
    var res = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == 0 && flipsForMove(i, player).isNotEmpty) res.add(i);
    }
    return res;
  }

  bool makeMove(int idx, int player) {
    if (player != currentPlayer) return false;
    var flips = flipsForMove(idx, player);
    if (flips.isEmpty) return false;
    board[idx] = player;
    for (var f in flips) board[f] = player;
    _history.add(List<int>.from(board));
    currentPlayer = -player;
    return true;
  }

  bool isGameOver() {
    if (board.every((v) => v != 0)) return true;
    if (legalMoves(1).isEmpty && legalMoves(-1).isEmpty) return true;
    return false;
  }

  Map<String, int> score() {
    int b = 0, w = 0;
    for (var v in board) {
      if (v == 1) b++;
      if (v == -1) w++;
    }
    return {'black': b, 'white': w};
  }

  bool undoTwoMoves() {
    // need at least initial + 2 moves snapshots to revert two moves
    if (_history.length < 3) return false;
    _history.removeLast(); // undo last move (AI)
    _history.removeLast(); // undo previous move (human)
    var prev = List<int>.from(_history.last);
    board = prev;
    currentPlayer = 1; // after undo, it's human's turn
    return true;
  }
}
