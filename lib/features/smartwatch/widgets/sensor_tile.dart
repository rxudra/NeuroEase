import 'package:flutter/material.dart';
import '../models/sensor_model.dart';

class SensorTile extends StatelessWidget {
  const SensorTile({super.key, required this.sensor});

  final SensorModel sensor;

  @override
  Widget build(BuildContext context) {
    final color = sensor.status == SensorStatus.connected
        ? Colors.green
        : (sensor.status == SensorStatus.disconnected
              ? Colors.red
              : Colors.grey);
    return ListTile(
      leading: Icon(Icons.sensors, color: color),
      title: Text(sensor.name),
      trailing: Text(sensor.status.name),
    );
  }
}
