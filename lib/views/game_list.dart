import 'dart:convert';
import 'package:battleships/views/home_controller.dart';
import 'package:battleships/models/game.dart';
import 'package:battleships/util/api.dart';
import 'package:battleships/util/session_manager.dart';
import 'package:battleships/views/game_board.dart';
import 'package:flutter/material.dart';

// game and matchmaking implementation

bool isLoading = false;
List<Game> games = [];

class OnGames extends StatefulWidget {
  final HomePageController controller;

  const OnGames({Key? key, required this.controller}) : super(key: key);

  @override
  State<OnGames> createState() => _OnGamesState(controller: controller);
}

class _OnGamesState extends State<OnGames> {
  final HomePageController controller;
  _OnGamesState({required this.controller}) {
    controller.updateGames = updateGames;
  }

  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    controller.context = context;
    updateGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.lightBlue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: games.isEmpty
              ? const Center(
            child: Text(
              'No games available.',
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
              : ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              int gameID = game.id;
              String gameMsg = '';
              String battleStatusMsg = '';

              if (game.status == 0) {
                gameMsg = 'Waiting for Opponent';
                battleStatusMsg = 'Matchmaking';
              } else if (game.status == 1) {
                gameMsg = 'Player1 Won';
                battleStatusMsg =
                (game.position == 2) ? 'Game Lost :(' : 'Game Won :)';
              } else if (game.status == 2) {
                gameMsg = 'Player2 Won';
                battleStatusMsg =
                (game.position == 1) ? 'Game Lost :(' : 'Game Won :)';
              } else if (game.status == 3) {
                gameMsg = '${game.player1} vs ${game.player2}';
                battleStatusMsg = (game.turn == game.position)
                    ? 'Your Turn'
                    : 'Opponent\'s Turn';
              }

              return (game.status == 0 || game.status == 3)
                  ? Dismissible(
                key: Key('$gameID'),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                onDismissed: (direction) {
                  _deleteGame(context, game.id, index);
                },
                child: Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      '#$gameID $gameMsg',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      battleStatusMsg,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: (battleStatusMsg.contains('Won'))
                            ? Colors.green
                            : (battleStatusMsg.contains('Lost'))
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ),
                    trailing: (game.turn == game.position)
                        ? Icon(Icons.play_arrow,
                        color: Colors.green.shade700)
                        : null,
                    onTap: () {
                      if (game.status != 0 &&
                          (game.turn == game.position)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlayBattle(game: game)),
                        ).then((value) => updateGames());
                      }
                    },
                  ),
                ),
              )
                  : Container();
            },
          ),
        ),
      ),
    );
  }

  Future<void> updateGames() async {
    try {
      final token = await SessionManager.getSessionToken();

      final response = await ApiHelper.callApiGet('/games', '', token: token);
      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
      print('An error occurred: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteGame(BuildContext context, int id, int index) async {
    try {
      final token = await SessionManager.getSessionToken();

      final response =
      await ApiHelper.callApiDelete('/games/$id', '', token: token);

      if (response.statusCode == 200) {
        setState(() {
          games.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleting game failed!')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}