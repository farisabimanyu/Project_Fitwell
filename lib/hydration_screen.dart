import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class HydrationScreen extends StatefulWidget {
  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _glassesOfWater = 0;
  final int _targetGlasses = 8;
  String _lastSavedDate = '';
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    // _notificationService = NotificationService();
    // _scheduleDailyNotifications();
    _loadHydrationData();
  }

  void _scheduleDailyNotifications() {
    // Define the start and end times
    final startHour = 6;
    final endHour = 20;
    final totalHours = endHour - startHour;
    final interval = totalHours ~/ _targetGlasses;

    for (int i = 0; i < _targetGlasses; i++) {
      final notificationTime = startHour + i * interval;
      _notificationService.scheduleDailyNotifications(
        i,
        "Time to drink water",
        "You need to drink ${(i + 1)} glasses of water today!",
        notificationTime,
      );
    }
  }

  void _loadHydrationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _glassesOfWater = prefs.getInt('glassesOfWater') ?? 0;
      _lastSavedDate = prefs.getString('lastSavedDate') ?? '';

      // Reset count if it's a new day
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_lastSavedDate != today) {
        _glassesOfWater = 0;
        _lastSavedDate = today;
        _saveHydrationData();
      }
    });
  }

  void _saveHydrationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('glassesOfWater', _glassesOfWater);
    prefs.setString('lastSavedDate', _lastSavedDate);
  }

  void _incrementWaterCount() {
    setState(() {
      if (_glassesOfWater < _targetGlasses) {
        _glassesOfWater++;
        _saveHydrationData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydration Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/water.gif',
              width: 300.0,
              height: 300.0,
            ),
            SizedBox(height: 20.0),
            Text(
              'Glasses of Water',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            Text(
              '$_glassesOfWater / $_targetGlasses',
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _incrementWaterCount,
              child: Text('Add Glass'),
            ),
          ],
        ),
      ),
    );
  }
}
