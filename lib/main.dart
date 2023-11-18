import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset scores when the app starts
  await resetScores();

  runApp(MyApp());
}

Future<void> resetScores() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('playerXWins', 0);
  prefs.setInt('playerOWins', 0);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class LinePainter extends CustomPainter {
  final List<List<String>> board;

  LinePainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0;

    // Check for a winning row
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != '' &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        drawHorizontalLine(canvas, i, paint);
        return;
      }
    }

    // Check for a winning column
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != '' &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        drawVerticalLine(canvas, i, paint);
        return;
      }
    }

    // Check for a winning diagonal (top-left to bottom-right)
    if (board[0][0] != '' &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      drawDiagonalLine(canvas, true, paint);
      return;
    }

    // Check for a winning diagonal (top-right to bottom-left)
    if (board[0][2] != '' &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      drawDiagonalLine(canvas, false, paint);
      return;
    }
  }

  void drawHorizontalLine(Canvas canvas, int row, Paint paint) {
    final startY = row * 100.0 + 50.0;
    final endY = startY;
    canvas.drawLine(
      Offset(0, startY),
      Offset(300, endY),
      paint,
    );
  }

  void drawVerticalLine(Canvas canvas, int column, Paint paint) {
    final startX = column * 100.0 + 50.0;
    final endX = startX;
    canvas.drawLine(
      Offset(startX, 0),
      Offset(endX, 300),
      paint,
    );
  }

  void drawDiagonalLine(
      Canvas canvas, bool isTopLeftToBottomRight, Paint paint) {
    if (isTopLeftToBottomRight) {
      canvas.drawLine(
        Offset(0, 0),
        Offset(300, 300),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(300, 0),
        Offset(0, 300),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _TicTacToeState extends State<TicTacToe> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  bool gameEnded = false;
  int playerXWins = 0;
  int playerOWins = 0;

  @override
  void initState() {
    super.initState();
    // Set the initial player randomly
    currentPlayer = ['X', 'O'][Random().nextInt(2)];
  }

  Future<void> saveStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('playerXWins', playerXWins);
    prefs.setInt('playerOWins', playerOWins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Player $currentPlayer\'s turn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            for (int i = 0; i < 3; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 3; j++)
                    GestureDetector(
                      onTap: () {
                        if (!gameEnded && board[i][j] == '') {
                          setState(() {
                            board[i][j] = currentPlayer;
                            checkWinner(i, j);
                            currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
                          });
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(4.0),
                        padding: EdgeInsets.all(8.0),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: board[i][j] == 'X'
                              ? Colors.blue
                              : (board[i][j] == 'O'
                                  ? Colors.red
                                  : Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            board[i][j],
                            style: TextStyle(
                              fontSize: 40,
                              color: board[i][j] == ''
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            if (gameEnded)
              Column(
                children: [
                  Text(
                    'Player ${currentPlayer == 'X' ? 'O' : 'X'} wins!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      restartGame();
                    },
                    child: Text(
                      'Restart Game',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Player X Wins: $playerXWins'),
                SizedBox(width: 20),
                Text('Player O Wins: $playerOWins'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showTieDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Tied!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                restartGame();
              },
              child: Text('Restart Game'),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      gameEnded = false;
      currentPlayer = 'X';
    });
  }

  void checkWinner(int row, int col) {
    // Check row
    if (board[row].every((element) => element == currentPlayer)) {
      gameEnded = true;
    }

    // Check column
    if (board.every((element) => element[col] == currentPlayer)) {
      gameEnded = true;
    }

    // Check diagonals
    if ((row == col || row + col == 2) &&
        (board[0][0] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][2] == currentPlayer)) {
      gameEnded = true;
    }

    if ((row == 0 && col == 2) ||
        (row == 2 && col == 0) ||
        (row == 1 && col == 1)) {
      if (board[0][2] == currentPlayer &&
          board[1][1] == currentPlayer &&
          board[2][0] == currentPlayer) {
        gameEnded = true;
      }
    }

    // Check for a tie
    if (!gameEnded && !board.any((row) => row.any((cell) => cell == ''))) {
      gameEnded = true;
    }

    if (gameEnded) {
      if (!board.any((row) => row.any((cell) => cell == ''))) {
        // It's a tie, no one gets a point
        showTieDialog(); // Add this line to display a tie message
      } else {
        // Update win count for the player who won
        if (currentPlayer == 'X') {
          playerXWins++;
        } else {
          playerOWins++;
        }
        saveStats();
      }
    }
  }
}
