import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeightTrackingScreen extends StatefulWidget {
  @override
  _WeightTrackingScreenState createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  double _targetWeight = 0;
  double _currentWeight = 0;
  TextEditingController _targetWeightController = TextEditingController();
  TextEditingController _currentWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  void _loadWeightData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetWeight = prefs.getDouble('targetWeight') ?? 0;
      _currentWeight = prefs.getDouble('currentWeight') ?? 0;
      _targetWeightController.text = _targetWeight.toString();
      _currentWeightController.text = _currentWeight.toString();
    });
  }

  void _saveWeightData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('targetWeight', _targetWeight);
    prefs.setDouble('currentWeight', _currentWeight);
  }

  void _updateWeight() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _targetWeight = double.parse(_targetWeightController.text);
        _currentWeight = double.parse(_currentWeightController.text);
        _saveWeightData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _targetWeightController,
                decoration: InputDecoration(labelText: 'Target Weight'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your target weight';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currentWeightController,
                decoration: InputDecoration(labelText: 'Current Weight'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateWeight();
                  }
                },
                child: Text('Update Weight'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Weight Progress'),
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    ColumnSeries<ChartData, String>(
                      dataSource: [
                        ChartData('Current', _currentWeight),
                        ChartData('Target', _targetWeight),
                        ChartData(
                            'Remaining',
                            _targetWeight - _currentWeight > 0
                                ? _targetWeight - _currentWeight
                                : 0),
                      ],
                      xValueMapper: (ChartData data, _) => data.label,
                      yValueMapper: (ChartData data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.label, this.value);
  final String label;
  final double value;
}
