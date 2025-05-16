class Game {
  int id;
  String player1;
  String player2;
  int position;
  int status;
  int turn;

  Game ({
    required this.id,
    required this.player1,
    required this.player2,
    required this.position,
    required this.status,
    required this.turn
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json["id"], 
    player1: json["player1"], 
    player2: json["player2"] ?? "", 
    position: json["position"], 
    status: json["status"], 
    turn: json["turn"],
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "player1": player1,
      "player2": player2,
      "position": position,
      "status": status,
      "turn": turn,
    };
  }
}