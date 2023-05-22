import 'package:flutter/material.dart';

import 'game_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activePlayer = "X";
  bool gameOver = false;
  int turn = 0;
  String result = '';
  Game game = Game();
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
            child: MediaQuery.of(context).orientation == Orientation.portrait
                ? Column(
                    children: [
                      ...firstBlock(),
                      _expanded(context),
                      ...lastBlock() // ... for extract element from the widgets
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...firstBlock(),
                          const SizedBox(
                            height: 20,
                          ),
                          ...lastBlock()
                        ],
                      )),
                      _expanded(context)
                    ],
                  )));
  }

  List<Widget> firstBlock() {
    return [
      SwitchListTile.adaptive(
          title: const Text(
            "Turn on/off two player",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          value: isSwitched,
          onChanged: (bool newValue) {
            setState(() {
              isSwitched = newValue;
            });
          }),
      Text(
        "its $activePlayer turn".toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
        ),
        textAlign: TextAlign.center,
      )
    ];
  }

  List<Widget> lastBlock() {
    return [
      Text(
        '$result',
        style: TextStyle(
          color: Colors.white,
          fontSize: 42,
        ),
        textAlign: TextAlign.center,
      ),
      ElevatedButton.icon(
          onPressed: () {
            setState(() {
              Player.playerX = [];
              Player.playerO = [];
              activePlayer = "X";
              gameOver = false;
              turn = 0;
              result = '';
            });
          },
          label: const Text("Repeat the game"),
          icon: const Icon(Icons.replay),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).splashColor)))
    ];
  }

  Expanded _expanded(BuildContext context) {
    return Expanded(
        child: GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      childAspectRatio: 1.0,
      mainAxisSpacing: 8.0,
      padding: const EdgeInsets.all(16),
      children: List.generate(
          9,
          (index) => InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: gameOver == true ? null : () => _onTap(index),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text(
                    Player.playerX.contains(index)
                        ? 'X'
                        : Player.playerO.contains(index)
                            ? 'O'
                            : '',
                    style: TextStyle(
                        color: Player.playerX.contains(index)
                            ? Colors.blue
                            : Colors.pink,
                        fontSize: 52),
                  ),
                ),
              ))),
    ));
  }

  _onTap(int index) async {
    if ((Player.playerX.isEmpty || !Player.playerX.contains(index)) &&
        (Player.playerO.isEmpty || !Player.playerO.contains(index))) {
      game.playGame(index, activePlayer);
      updateState();

      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlayer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(() {
      activePlayer = (activePlayer == 'X') ? 'O' : 'X';
      turn++;
      String winnerPlayer = game.checkWinner();
      if (winnerPlayer != '') {
        gameOver = true;
        result = '$winnerPlayer is the Winner';
      } else if (!gameOver && turn == 9) {
        result = 'It\s Draw!';
      }
    });
  }
}
