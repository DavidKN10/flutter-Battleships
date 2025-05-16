import 'dart:convert';
import 'package:battleships/models/game_mode.dart';
import 'package:battleships/models/game.dart';
import 'package:battleships/util/session_manager.dart';
import 'package:battleships/util/api.dart';
import 'package:flutter/material.dart';

late GameMode gameMode;
bool isLoading = true;
bool firstTimePlay = false;

class PlayBattle extends StatefulWidget {
  Game game;
  PlayBattle ({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  State<PlayBattle> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayBattle> {
  bool isLoggedIn = false;
  int _isSelected = 0;

  final List<int> _inActiveList = [0, 1, 2, 3, 4, 5, 6, 12, 18, 24, 30];

  Map<int, String> lables = {
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "A",
    12: "B",
    18: "C",
    24: "D",
    30: "E",
  };

  Map<String, int> moves = {
    "A1": 7,
    "A2": 8,
    "A3": 9,
    "A4": 10,
    "A5": 11,
    "B1": 13,
    "B2": 14,
    "B3": 15,
    "B4": 16,
    "B5": 17,
    "C1": 19,
    "C2": 20,
    "C3": 21,
    "C4": 22,
    "C5": 23,
    "D1": 25,
    "D2": 26,
    "D3": 27,
    "D4": 28,
    "D5": 29,
    "E1": 31,
    "E2": 32,
    "E3": 33,
    "E4": 34,
    "E5": 35,
  };
  Map<dynamic, dynamic> movesIndex = {};

  @override
  void initState() {
    super.initState();
    movesIndex = ApiHelper.inverse(moves);

    _getGameMode(context, widget.game.id);

    if (widget.game.status == 3) {
      firstTimePlay = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (firstTimePlay) ? const Text('Play Game') : const Text('Game History'),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                _getGameMode(context, widget.game.id);
              },
            )
          ],
          backgroundColor: Colors.lightBlue,
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
          child: isLoading || gameMode == null
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : Column(children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  List<Widget> gameIcons = [];
                  Widget gridIcon = Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: gameIcons,
                  );

                  // anchor icon for the ships you placed
                  if (gameMode.ships.contains(movesIndex[index])) {
                    gameIcons.add(const Icon(Icons.anchor, color: Colors.blueAccent));
                  }

                  // flood icon will replace the anchor icon if your ship is sunk
                  if (gameMode.wrecks.contains(movesIndex[index])) {
                    gameIcons.add(const Icon(
                      Icons.flood,
                      color: Colors.lightBlue,
                    ));
                  }

                  // x icon if your shot misses an enemy ship
                  if (gameMode.shots.contains(movesIndex[index]) &&
                      !gameMode.sunk.contains(movesIndex[index])) {
                    gameIcons.add(Icon(
                      Icons.close,
                      color: Colors.redAccent,
                    ));
                  }

                  // if you sink an enemy, this icon will show
                  if (gameMode.sunk.contains(movesIndex[index])) {
                    gameIcons.add(const Icon(
                      Icons.local_fire_department,
                      color: Colors.orangeAccent,
                    ));
                  }

                  // this icon will show when you select a spot before shooting
                  if (_isSelected == index) {
                    gameIcons.add(const Icon(
                      Icons.my_location,
                      color: Colors.black87,
                    ));
                  }

                  return Card(
                    color: Colors.white,
                    elevation: !_inActiveList.contains(index) ? 8 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: (!_inActiveList.contains(index) &&
                                !gameMode.sunk.contains(movesIndex[index]) &&
                                !gameMode.shots.contains(movesIndex[index]) &&
                                !gameMode.ships.contains(movesIndex[index]) &&
                                !gameMode.wrecks.contains(movesIndex[index]) &&
                                gameMode.status == 3)
                                ? () {
                              setState(() {
                                _isSelected = index;
                              });
                            }
                                : null,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (_inActiveList.contains(index))
                                      ? (index != 0)
                                      ? Text('${lables[index]}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ))
                                      : Container()
                                      : gridIcon,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                style:  ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 60, 78, 247) ),
                onPressed: () {
                  if (_isSelected != 0) {
                    _playShot(context, widget.game.id, movesIndex[_isSelected]);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No shot selected!')),
                    );
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ]),
        ));
  }

  Future<void> _getGameMode(BuildContext context, int id, {showLoading = true}) async {
    try{
      final token = await SessionManager.getSessionToken();
      String data = jsonEncode(<String, String>{});

      if (showLoading) {
        setState(() {
          isLoading = true;
        });
      }

      final response = await ApiHelper.callApiGet("/games/$id", data, token: token);
      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonRes["status"] == 2 && firstTimePlay) {
          _showDialog("Sorry", "You Lost!", () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            firstTimePlay = false;
            Navigator.pop(context);
          });
        }

        GameMode newGameMode = GameMode.fromJson(jsonRes);
        setState(() {
          gameMode = newGameMode;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fetching games failed")),
        );
      }
    } catch (e) {
      print("An error occurred: $e");
    }

    if (showLoading) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _playShot(BuildContext context, int id, String move) async {
    setState(() {
      _isSelected = 0;
    });

    try {
      final token = await SessionManager.getSessionToken();
      String data =jsonEncode(<String, String>{"shot": move});
      final response = await ApiHelper.callApiPut("/games/$id", data, token: token);
      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String message = jsonRes["sunk_ship"] ? "Success enemy ship sunk!" : "Failed to hit enemy ship!";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Move added: $message")),
        );

        if (jsonRes["won"]) {
          _showDialog("Congratulations", "You won!", () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            firstTimePlay = false;
            Navigator.pop(context);
          });
        }

        if (jsonRes["sunk_ship"]) {
          setState(() {
            gameMode.sunk.add(move);
          });
        }
        
        _getGameMode(context, id, showLoading: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Move not added")),
        );
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void _showDialog(String t, String s, Function f) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(t, style: TextStyle(color: Colors.blueGrey.shade800, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Text(s, style: const TextStyle(color: Colors.black87),),
          ),
        );
      },
    ).then((value) {
      f();
    });
  }
}
