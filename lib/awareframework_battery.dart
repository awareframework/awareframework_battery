import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// init sensor
class BatterySensor extends AwareSensorCore {
  static const MethodChannel _batteryMethod = const MethodChannel('awareframework_battery/method');
  static const EventChannel  _batteryStream  = const EventChannel('awareframework_battery/event');

  /// Init Battery Sensor with BatterySensorConfig
  BatterySensor(BatterySensorConfig config):this.convenience(config);
  BatterySensor.convenience(config) : super(config){
    /// Set sensor method & event channels
    super.setSensorChannels(_batteryMethod, _batteryStream);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onBatteryChanged {
     return super.receiveBroadcastStream("on_battery_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }

  Stream<Null> get onBatteryLow {
    return super.receiveBroadcastStream("on_battery_low");
  }

  Stream<Null> get onBatteryCharging {
    return super.receiveBroadcastStream("on_battery_charging");
  }

  Stream<Null> get onBatteryDischarging {
    return super.receiveBroadcastStream("on_battery_discharging");
  }
}

class BatterySensorConfig extends AwareSensorConfig{
  BatterySensorConfig();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// Make an AwareWidget
class BatteryCard extends StatefulWidget {
  BatteryCard({Key key, @required this.sensor}) : super(key: key);

  BatterySensor sensor;

  @override
  BatteryCardState createState() => new BatteryCardState();
}


class BatteryCardState extends State<BatteryCard> {

  Map<String,dynamic> data;

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onBatteryChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          data = event;
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }


  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          width: MediaQuery.of(context).size.width*0.8,
          child: new Text(data.toString())
        ),
      title: "Battery",
      sensor: widget.sensor
    );
  }

}
