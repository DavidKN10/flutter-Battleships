import 'package:battleships/views/home_controller.dart';
import 'package:battleships/models/game.dart';
import 'package:flutter/material.dart';
import 'package:battleships/util/session_manager.dart';
import 'package:battleships/views/game_list.dart';
import 'package:battleships/views/login.dart';
import 'package:battleships/views/completed_game.dart';
import 'package:battleships/views/new_game.dart';

// home page

bool isLoading = false;

Game gameDemo = Game(
  id: 4,
  player1: "test1", 
  player2: "test1", 
  position: 1, 
  status: 1, 
  turn: 1
);

class FirstPage extends StatefulWidget{
  const FirstPage({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FirstPage> {
  int _selectedIndex = 0;
  String sessionUser = '';

  final HomePageController myController = HomePageController();

  void _changeSelection(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _getUser();
  }

  Future<void> _getUser() async {
    final user = await SessionManager.getSessionUser();
    if (mounted) {
      setState(() {
        sessionUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battleships"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              myController.updateGames();
            },
          ),
        ],
      ),
      drawer:MyDrawer(
        sessionUser: sessionUser,
        selected: _selectedIndex,
        changeSelection: _changeSelection,
        controller: myController
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade700,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: switch(_selectedIndex) {
          0 => OnGames(controller: myController),
          1 => const NewGameAI(aiOpponent: ''),
          2 => const NewGameAI(aiOpponent: 'random'),
          3 => CompleteGames(),
          _ => OnGames(controller: myController)
        },
      ),
    );
  }
}

// hamburger menu for the different option
class MyDrawer extends StatelessWidget {
  final String sessionUser;
  final int selected;
  final void Function(int index) changeSelection;
  final HomePageController controller;

  const MyDrawer({
    required this.sessionUser,
    required this.selected,
    required this.changeSelection,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade800,
              Colors.blueGrey.shade400,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Battleships",
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Logged in as $sessionUser",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text("New Game", style: TextStyle(color: Colors.white)),
              selected: selected == 1,
              onTap: () {
                changeSelection(0);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewGameAI(aiOpponent: '')),
                ).then((value) => {controller.updateGames()});
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer, color: Colors.white),
              title: const Text("New Game (AI)", style: TextStyle(color: Colors.white)),
              selected: selected == 2,
              onTap: () {
                changeSelection(0);
                Navigator.pop(context);
                _setAI(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer, color: Colors.white),
              title: const Text("Show Completed Games", style: TextStyle(color: Colors.white)),
              selected: selected == 3,
              onTap: () {
                changeSelection(0);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompleteGames()),
                ).then((value) => {controller.updateGames()});
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              selected: selected == 4,
              onTap: () {
                _doLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _doLogout(context) async {
    // get rid of session token
    await SessionManager.clearSession();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ));
  }

  void _setAI(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Select an Option",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold)),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildOptionItem("Random", context, "random"),
                _buildOptionItem("Perfect", context, "perfect"),
                _buildOptionItem("One Ship (A1)", context, "oneship"),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildOptionItem(String option, BuildContext context, String aiOppnent) {
    return ListTile(
      title: Text(option, style: TextStyle(color: Colors.black87)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewGameAI(aiOpponent: aiOppnent)),
        ).then((value) => {controller.updateGames()});
      },
    );
  }
}