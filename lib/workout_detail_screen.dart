import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutTitle;
  final String difficultyLevel;
  final VoidCallback markComplete;

  WorkoutDetailScreen(
      {required this.workoutTitle,
      required this.difficultyLevel,
      required this.markComplete});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Timer? _timer;
  int _start = 0;
  bool _isRunning = false;
  List<int> _durations = [];
  List<int> _weights = [];
  String _lastSavedDate = '';

  @override
  void initState() {
    super.initState();
    _initializeWeights();
    _loadWorkoutData();
  }

  void _initializeWeights() {
    switch (widget.difficultyLevel) {
      case 'Advanced':
        _weights = [30, 20, 15, 10];
        break;
      case 'Intermediate':
        _weights = [20, 15, 10, 5];
        break;
      case 'Beginner':
        _weights = [10, 7, 5, 3];
        break;
      default:
        _weights = [];
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _start = 0;
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _start++;
      });
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _durations.add(_start);
      _isRunning = false;
      _saveWorkoutData();
    });
  }

  void _nextWeight() {
    if (_durations.length < _weights.length) {
      _startTimer();
    } else {
      setState(() {
        widget.markComplete();
        _markWorkoutComplete();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Workout completed!')));
    }
  }

  void _loadWorkoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _durations = prefs
              .getStringList('${widget.workoutTitle}_durations')
              ?.map(int.parse)
              .toList() ??
          [];
      _lastSavedDate = prefs.getString('lastSavedDate') ?? '';

      // Reset completion status if it's a new day
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_lastSavedDate != today) {
        _durations = [];
        _lastSavedDate = today;
        _saveWorkoutData();
      }
    });
  }

  void _saveWorkoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.workoutTitle}_durations',
        _durations.map((e) => e.toString()).toList());
    prefs.setString('lastSavedDate', _lastSavedDate);
  }

  void _markWorkoutComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('${widget.workoutTitle}_completed', true);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Workout: ${widget.workoutTitle}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              'Difficulty Level: ${widget.difficultyLevel}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Current Weight: ${_durations.length < _weights.length ? _weights[_durations.length] : 'Completed'} kg',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Time: $_start seconds',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            _isRunning
                ? ElevatedButton(
                    onPressed: _stopTimer,
                    child: Text('Stop'),
                  )
                : ElevatedButton(
                    onPressed: _nextWeight,
                    child: Text(_durations.length < _weights.length
                        ? 'Start Next Weight'
                        : 'Workout Completed'),
                  ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _durations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Weight: ${_weights[index]} kg'),
                    trailing: Text('Duration: ${_durations[index]} seconds'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
