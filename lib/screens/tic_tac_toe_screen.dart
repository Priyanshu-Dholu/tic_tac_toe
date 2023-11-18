import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/components/board.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  bool gameEnded = false;
  int playerXWins = 0;
  int playerOWins = 0;
  Color winBackgroundColor = Color.fromARGB(255, 255, 255, 2);

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
        title: Container(
          child: const Text(
            'Tic Tac Toe',
            style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        backgroundColor: Colors.deepOrange,
        centerTitle: true, // Center the title
      ),
      body: Stack(
        children: [
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(
                  'Player $currentPlayer\'s turn',
                  style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                BoardWidget(
                  board: board,
                  currentPlayer: currentPlayer,
                  onMove: (i, j) {
                    if (!gameEnded && board[i][j] == '') {
                      setState(() {
                        board[i][j] = currentPlayer;
                        checkWinner(i, j);
                        currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
                      });
                    }
                  },
                ),
                const SizedBox(height: 20)
              ])),
          if (gameEnded)
            Center(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Blurred Menu Content
                      TextButton(
                        onPressed: () {
                          restartGame();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Restart Game',
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: winBackgroundColor ?? Colors.transparent,
                          borderRadius: BorderRadius.circular(
                              8), // Optional: Set border radius
                        ),
                        child: Text(
                          'Player ${currentPlayer == 'X' ? 'O' : 'X'} Wins 🎉!',
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Player Stats
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Player X Wins: $playerXWins',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 87, 140, 214),
                    ),
                  ),
                  Text(
                    'Player O Wins: $playerOWins',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 245, 121, 38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showTieDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Tied!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                restartGame();
              },
              child: const Text('Restart Game'),
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
          winBackgroundColor = Color.fromARGB(255, 87, 140, 214);
        } else {
          playerOWins++;
          winBackgroundColor = Color.fromARGB(255, 245, 121, 38);
        }
        saveStats();
      }
    }
  }
}
