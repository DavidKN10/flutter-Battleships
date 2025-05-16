import 'dart:convert';
import 'package:battleships/models/game.dart';
import 'package:battleships/util/api.dart';
import 'package:battleships/util/session_manager.dart';
import 'package:battleships/views/game_board.dart';
import 'package:flutter/material.dart';

// page that will show the list of compleeted games

bool isLoading = false;
List<Game> games = [];

class CompleteGames extends StatefulWidget {
  CompleteGames({Key? key}) : super(key: key);

  @override
  State<CompleteGames> createState() => _CompleteGamesState();
}

class _CompleteGamesState extends State<CompleteGames> {
  bool isLoggedIn = false;
  List<Game> games = [];

  @override
  void initState() {
    super.initState();

    updateGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Completed Games'),
          backgroundColor: Colors.lightBlue,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                updateGames();
              },
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueGrey.shade700,
                Colors.blueGrey.shade300,
              ],
            ),
          ),
          child: isLoading
              ? Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
              : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                //Prep
                int gameID = games[index].id;
                String gameMsg = '';
                int gameStatus = games[index].status;
                String gameStatusMsg = '';
                int gameTurn = games[index].turn;
                int gamePosition = games[index].position;

                if (gameStatus == 0) {
                  gameMsg = 'Waiting for Opponent';
                  gameStatusMsg = 'Matchmaking';
                } else if (gameStatus == 1) {
                  gameMsg = 'Player1 Won';
                  if (gamePosition == 2) {
                    gameStatusMsg = 'Game Lost';
                  } else {
                    gameStatusMsg = 'Game Won';
                  }
                } else if (gameStatus == 2) {
                  gameMsg = 'Player 2 Won';
                  if (gamePosition == 1) {
                    gameStatusMsg = 'Game Lost';
                  } else {
                    gameStatusMsg = 'Game Won';
                  }
                } else if (gameStatus == 3) {
                  gameMsg =
                  '${games[index].player1} vs ${games[index].player2}';

                  if (gameTurn == gamePosition) {
                    gameStatusMsg = 'My Turn';
                  } else {
                    gameStatusMsg = 'OpponentTurn';
                  }
                }

                String item = '#$gameID $gameMsg';
                return (games[index].status != 3 || games[index].status == 0)
                    ? Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text('$item',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    trailing: Text('$gameStatusMsg',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: gameStatusMsg == 'Game Lost'
                                ? Colors.redAccent
                                : Colors.green)),
                    onTap: () {
                      if (games[index] != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlayBattle(game: games[index])),
                        ).then((value) => {updateGames()});
                      }
                    },
                  ),
                )
                    : Container();
              }),
        ));
  } 

  Future<void> updateGames() async {
    try {
      final token = await SessionManager.getSessionToken();

      String data = jsonEncode(<String, String>{});

      setState(() {
        isLoading = true;
      });

      final response = await ApiHelper.callApiGet('/games', data, token: token);
      final jsonRes = jsonDecode(response.body);

      print(jsonRes);

      if (response.statusCode == 200) {
        // Successful parse games
        List<Game> newGames = [];
        final jsonGames = jsonRes['games'];

        for (var i = 0; i < jsonGames.length; i++) {
          newGames.add(Game.fromJson(jsonGames[i]));
        }

        if (!mounted) return;

        setState(() {
          games = newGames;
        });
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      print('An error occurred: $e');
    }

    setState(() {
      isLoading = false;
    });
  }
}

// Declare a public interface for _CompleteGamesState
abstract class CompleteGamesInterface {
  void updateGames(BuildContext context);
}