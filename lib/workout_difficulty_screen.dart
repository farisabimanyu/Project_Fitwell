import 'package:flutter/material.dart';
import 'exercise_selection_screen.dart';

class WorkoutDifficultyScreen extends StatelessWidget {
  final String workoutType;

  WorkoutDifficultyScreen({required this.workoutType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Difficulty'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          DifficultyLevelCard(
            level: 'Beginner',
            workoutType: workoutType,
          ),
          DifficultyLevelCard(
            level: 'Intermediate',
            workoutType: workoutType,
          ),
          DifficultyLevelCard(
            level: 'Advanced',
            workoutType: workoutType,
          ),
        ],
      ),
    );
  }
}

class DifficultyLevelCard extends StatelessWidget {
  final String level;
  final String workoutType;

  DifficultyLevelCard({required this.level, required this.workoutType});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              level,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseSelectionScreen(
                        workoutType: workoutType, difficultyLevel: level),
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
