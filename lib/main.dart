import 'package:flutter/material.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChessBoard(),
    );
  }
}

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  static const int boardSize = 8;

  // Board state: 2D list of piece codes, empty string = empty square
  List<List<String>> board = [
    ['bR','bN','bB','bQ','bK','bB','bN','bR'],
    ['bP','bP','bP','bP','bP','bP','bP','bP'],
    ['','','','','','','',''],
    ['','','','','','','',''],
    ['','','','','','','',''],
    ['','','','','','','',''],
    ['wP','wP','wP','wP','wP','wP','wP','wP'],
    ['wR','wN','wB','wQ','wK','wB','wN','wR'],
  ];

  int? selectedX;
  int? selectedY;

  List<List<bool>> possibleMoves = List.generate(boardSize, (_) => List.filled(boardSize, false));

  bool whiteTurn = true;

  void resetPossibleMoves() {
    for (var row in possibleMoves) {
      for (int i = 0; i < row.length; i++) {
        row[i] = false;
      }
    }
  }

  void calculatePossibleMoves(int x, int y) {
    resetPossibleMoves();
    String piece = board[y][x];
    if (piece == '') return;

    if (piece.endsWith('P')) {
      // Pawn moves: one step forward if empty
      int direction = piece.startsWith('w') ? -1 : 1;
      int newY = y + direction;
      if (newY >= 0 && newY < boardSize && board[newY][x] == '') {
        possibleMoves[newY][x] = true;
      }
      // TODO: Add captures and initial two-step move if you want
    }

    // Other piece moves can be added here later
  }

  void movePiece(int fromX, int fromY, int toX, int toY) {
    setState(() {
      board[toY][toX] = board[fromY][fromX];
      board[fromY][fromX] = '';
      selectedX = null;
      selectedY = null;
      resetPossibleMoves();
      whiteTurn = !whiteTurn;
    });
  }

  void selectSquare(int x, int y) {
    String piece = board[y][x];
    if (piece == '') {
      // Tap empty square: move if possible
      if (selectedX != null && selectedY != null && possibleMoves[y][x]) {
        movePiece(selectedX!, selectedY!, x, y);
      } else {
        setState(() {
          selectedX = null;
          selectedY = null;
          resetPossibleMoves();
        });
      }
    } else {
      // Tap piece: select if own piece on current turn
      if ((whiteTurn && piece.startsWith('w')) || (!whiteTurn && piece.startsWith('b'))) {
        setState(() {
          selectedX = x;
          selectedY = y;
          calculatePossibleMoves(x, y);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Demo - ${whiteTurn ? "White" : "Black"} to move'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            itemCount: boardSize * boardSize,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize),
            itemBuilder: (context, index) {
              final int x = index % boardSize;
              final int y = index ~/ boardSize;
              final bool isLightSquare = (x + y) % 2 == 0;
              final piece = board[y][x];
              final isSelected = selectedX == x && selectedY == y;
              final canMoveHere = possibleMoves[y][x];

              Color baseColor =
                  isLightSquare ? Colors.brown[200]! : Colors.brown[700]!;

              if (isSelected) {
                baseColor = Colors.green;
              } else if (canMoveHere) {
                baseColor = Colors.lightGreen;
              }

              return GestureDetector(
                onTap: () => selectSquare(x, y),
                child: Container(
                  color: baseColor,
                  child: piece != ''
                      ? Center(
                          child: Text(
                            piece,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: piece.startsWith('w')
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
