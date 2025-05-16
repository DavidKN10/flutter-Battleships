class GameMode {
  int id;
  int status;
  int position;
  int turn;
  String player1;
  String player2;
  List<dynamic> ships;
  List<dynamic> wrecks;
  List<dynamic> shots;
  List<dynamic> sunk;

  GameMode({
    required this.id,
    required this.status,
    required this.position,
    required this.turn,
    required this.player1, 
    required this.player2,
    required this.ships,
    required this.wrecks,
    required this.shots,
    required this.sunk,
  });

  factory GameMode.fromJson(Map<String, dynamic> json) => GameMode(
    id: json["id"],
    status: json["status"],
    position: json["position"],
    turn: json["turn"],
    player1: json["player1"],
    player2: json["player2"] ?? "",
    ships: json["ships"] ?? [],
    wrecks: json["wrecks"] ?? [],
    shots: json["shots"] ?? [],
    sunk: json["sunk"] ?? [],
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "status": status,
      "position": position,
      "turn": turn,
      "player1": player1,
      "player2": player2,
      "ships": ships,
      "wrecks": wrecks,
      "shots": shots,
      "sunk": sunk,
    };
  }
}