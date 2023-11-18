// board_widget.dart

import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  final List<List<String>> board;
  final String currentPlayer;
  final Function(int, int) onMove;

  BoardWidget({
    super.key,
    required this.board,
    required this.currentPlayer,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < 3; j++) _buildBoardButton(i, j),
            ],
          ),
      ],
    );
  }

  Widget _buildBoardButton(int i, int j) {
    return GestureDetector(
      onTap: () {
        onMove(i, j);
      },
      child: Container(
        margin: EdgeInsets.all(4.0),
        padding: EdgeInsets.all(8.0),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
          color: board[i][j] == 'X'
              ? Colors.blue
              : (board[i][j] == 'O' ? Colors.red : Colors.white),
        ),
        child: Center(
          child: Text(
            board[i][j],
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w700,
              fontSize: 40,
              color: board[i][j] == '' ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
