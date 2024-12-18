import 'package:flutter/material.dart';
import 'workout_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  final String workoutType;
  final String difficultyLevel;

  ExerciseSelectionScreen(
      {required this.workoutType, required this.difficultyLevel});

  @override
  _ExerciseSelectionScreenState createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  late List<Exercise> exercises;
  String _lastSavedDate = '';
  Map<String, bool> _completionStatus = {};

  @override
  void initState() {
    super.initState();
    exercises = _getExercises(widget.workoutType);
    _loadCompletionStatus();
  }

  void _loadCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSavedDate = prefs.getString('lastSavedDate') ?? '';

      // Reset completion status if it's a new day
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_lastSavedDate != today) {
        _completionStatus = {};
        _lastSavedDate = today;
        _saveCompletionStatus();
      } else {
        exercises.forEach((exercise) {
          _completionStatus[exercise.name] =
              prefs.getBool(exercise.name) ?? false;
        });
      }
    });
  }

  void _saveCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastSavedDate', _lastSavedDate);
    exercises.forEach((exercise) {
      prefs.setBool(exercise.name, _completionStatus[exercise.name] ?? false);
    });
    if (_completionStatus.values.any((status) => status == true)) {
      prefs.setBool(widget.workoutType, true);
    }
  }

  void _markExerciseComplete(String exerciseName) {
    setState(() {
      _completionStatus[exerciseName] = true;
      _saveCompletionStatus();
    });
  }

  List<Exercise> _getExercises(String workoutType) {
    switch (workoutType) {
      case 'Arms and Shoulders':
        return [
          Exercise(name: 'Bicep Curl', gifUrl: 'assets/bicep_curl.gif'),
          Exercise(name: 'Shoulder Press', gifUrl: 'assets/shoulder_press.gif'),
        ];
      case 'Back and Chest':
        return [
          Exercise(name: 'Chest Press', gifUrl: 'assets/chest_press.gif'),
          Exercise(name: 'Dumbbell Flyes', gifUrl: 'assets/dumbbell_flyes.gif'),
        ];
      case 'Abs':
        return [
          Exercise(name: 'Russian Twists', gifUrl: 'assets/russian_twists.gif'),
        ];
      case 'Legs':
        return [
          Exercise(name: 'Squats', gifUrl: 'assets/dumbbell_squats.gif'),
          Exercise(
              name: 'Calf Raise', gifUrl: 'assets/dumbbell_calf_raise.gif'),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Exercise'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          Exercise exercise = exercises[index];
          return ExerciseCard(
            exercise: exercise,
            workoutType: widget.workoutType,
            difficultyLevel: widget.difficultyLevel,
            isCompleted: _completionStatus[exercise.name] ?? false,
            markComplete: _markExerciseComplete,
          );
        },
      ),
    );
  }
}

class Exercise {
  final String name;
  final String gifUrl;

  Exercise({required this.name, required this.gifUrl});
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String workoutType;
  final String difficultyLevel;
  final bool isCompleted;
  final Function(String) markComplete;

  ExerciseCard({
    required this.exercise,
    required this.workoutType,
    required this.difficultyLevel,
    required this.isCompleted,
    required this.markComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
              ],
            ),
            SizedBox(height: 10.0),
            Image.asset(
              exercise.gifUrl,
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(
                      workoutTitle:
                          '$workoutType - $difficultyLevel - ${exercise.name}',
                      difficultyLevel: difficultyLevel,
                      markComplete: () => markComplete(exercise.name),
                    ),
                  ),
                );
              },
              child: Text('Select Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
