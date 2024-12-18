import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_difficulty_screen.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Map<String, bool> _completionStatus = {};

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }

  void _loadCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _completionStatus['Arms and Shoulders'] =
          prefs.getBool('Arms and Shoulders') ?? false;
      _completionStatus['Back and Chest'] =
          prefs.getBool('Back and Chest') ?? false;
      _completionStatus['Abs'] = prefs.getBool('Abs') ?? false;
      _completionStatus['Legs'] = prefs.getBool('Legs') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Workout'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          WorkoutTypeCard(
            title: 'Arms and Shoulders',
            description: 'Exercises for your arms and shoulders.',
            isCompleted: _completionStatus['Arms and Shoulders'] ?? false,
          ),
          WorkoutTypeCard(
            title: 'Back and Chest',
            description: 'Exercises for your back and chest.',
            isCompleted: _completionStatus['Back and Chest'] ?? false,
          ),
          WorkoutTypeCard(
            title: 'Abs',
            description: 'Exercises for your abdomen.',
            isCompleted: _completionStatus['Abs'] ?? false,
          ),
          WorkoutTypeCard(
            title: 'Legs',
            description: 'Exercises for your legs.',
            isCompleted: _completionStatus['Legs'] ?? false,
          ),
        ],
      ),
    );
  }
}

class WorkoutTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;

  WorkoutTypeCard(
      {required this.title,
      required this.description,
      required this.isCompleted});

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
                  title,
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
            Text(
              description,
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkoutDifficultyScreen(workoutType: title),
                  ),
                );
              },
              child: Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}
