import 'package:flutter/material.dart';
import 'package:awareframework_battery/awareframework_battery.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  BatterySensor sensor;
  BatterySensorConfig config;

  @override
  void initState() {
    super.initState();

    config = BatterySensorConfig()
      ..debug = true;

    sensor = new BatterySensor.init(config);

    sensor.start();
  }

  @override
  Widget build(BuildContext context) {


    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin Example App'),
          ),
          body: new BatteryCard(sensor: sensor,)
      ),
    );
  }
}
