import 'package:flutter/material.dart';
import 'screens/tic_tac_toe_screen.dart';
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
      title: 'Tic Tac Toe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: TicTacToe(),
      debugShowCheckedModeBanner: false,
    );
  }
}
