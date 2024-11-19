// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller>
    with SingleTickerProviderStateMixin {
  final Random _randomizer = Random();
  List<int> _diceResults = [1];
  int _numberOfDice = 1;
  late AnimationController _controller;
  late Animation<double> _animation;
  double _shakeThreshold = 12.0;
  StreamSubscription? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if ((event.x.abs() > _shakeThreshold ||
          event.y.abs() > _shakeThreshold ||
          event.z.abs() > _shakeThreshold)) {
        rollDice();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void rollDice() {
    _controller.reset();
    _controller.forward();

    setState(() {
      _diceResults =
          List.generate(_numberOfDice, (_) => _randomizer.nextInt(6) + 1);
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _numberOfDice = index + 1;
      _diceResults = List.filled(_numberOfDice, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: ClipRRect(
          child: AppBar(
            title: const Text(
              "Dicer",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(2, 136, 209, 1),
            elevation: 10,
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(199, 255, 255, 255), // Fresh green
                const Color.fromRGBO(2, 136, 209, 1), // Vibrant blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value,
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _diceResults.map((result) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        'assets/images/dice-$result.png',
                        width: 90,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(
                      255, 194, 81, 40), // Dark green button
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 40.0),
                ),
                onPressed: rollDice,
                child: const Text('Roll Dice'),
              ),
              const SizedBox(height: 20),
              Text(
                "You can Also Shake the phone to roll!",
                style: TextStyle(
                    color: const Color.fromARGB(255, 240, 240, 240),
                    fontSize: 18),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _numberOfDice - 1,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '1 Dice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '2 Dice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '3 Dice',
          ),
        ],
        backgroundColor: const Color(0xFF0288D1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 5, // Shadow for depth
      ),
    );
  }
}
