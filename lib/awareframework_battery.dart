import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';

/// init sensor
class BatterySensor extends AwareSensorCore {
  static const MethodChannel _batteryMethod = const MethodChannel('awareframework_battery/method');
  static const EventChannel  _batteryStream  = const EventChannel('awareframework_battery/event');

  static const EventChannel  _onBatteryChangedChannel   = const EventChannel('awareframework_battery/event_on_battery_changed');
  static const EventChannel  _onBatteryLowChannel       = const EventChannel('awareframework_battery/event_on_battery_low');
  static const EventChannel  _onBatteryChargingChannel  = const EventChannel('awareframework_battery/event_on_battery_charging');
  static const EventChannel  _onBatteryDischargingChannel  = const EventChannel('awareframework_battery/event_on_battery_discharging');

  /// Init Battery Sensor with BatterySensorConfig
  BatterySensor(BatterySensorConfig config):this.convenience(config);
  BatterySensor.convenience(config) : super(config){
    super.setMethodChannel(_batteryMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onBatteryChanged {
     return super.getBroadcastStream(_onBatteryChangedChannel, "on_battery_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }

  Stream<dynamic> get onBatteryLow {
    return super.getBroadcastStream(_onBatteryLowChannel,"on_battery_low");
  }

  Stream<dynamic> get onBatteryCharging {
    return super.getBroadcastStream(_onBatteryChargingChannel,"on_battery_charging");
  }

  Stream<dynamic> get onBatteryDischarging {
    return super.getBroadcastStream(_onBatteryDischargingChannel,"on_battery_discharging");
  }

  @override
  void cancelAllEventChannels() {
    super.cancelBroadcastStream("on_battery_changed");
    super.cancelBroadcastStream("on_battery_low");
    super.cancelBroadcastStream("on_battery_charging");
    super.cancelBroadcastStream("on_battery_discharging");
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

  final BatterySensor sensor;

  String batteryLevel = "";
  String condition = "";

  @override
  BatteryCardState createState() => new BatteryCardState();
}


class BatteryCardState extends State<BatteryCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onBatteryChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          widget.batteryLevel = event['level'].toString();
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });

    /** onBatteryCharging event */
    widget.sensor.onBatteryCharging.listen((event) {
      setState((){
        widget.condition = "charging";
      });
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    });

    /** onBatteryDischarging event */
    widget.sensor.onBatteryDischarging.listen((event) {
      setState((){
        // event
        widget.condition = "discharging";
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
          child: new Text("Battery Level: ${widget.batteryLevel}\nCondition: ${widget.condition}")
        ),
      title: "Battery",
      sensor: widget.sensor
    );
  }

  @override
  void dispose() {
    widget.sensor.cancelAllEventChannels();
    super.dispose();
  }

}
