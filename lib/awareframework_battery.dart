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
    /// Set sensor method & event channels
    super.setMethodChannel(_batteryMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> onBatteryChanged(String id) {
     return super.getBroadcastStream(_onBatteryChangedChannel, "on_battery_changed", id).map((dynamic event) => Map<String,dynamic>.from(event));
  }

  Stream<dynamic> onBatteryLow(String id) {
    return super.getBroadcastStream(_onBatteryLowChannel,"on_battery_low",id);
  }

  Stream<dynamic> onBatteryCharging(String id) {
    return super.getBroadcastStream(_onBatteryChargingChannel,"on_battery_charging",id);
  }

  Stream<dynamic> onBatteryDischarging(String id) {
    return super.getBroadcastStream(_onBatteryDischargingChannel,"on_battery_discharging", id);
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
  BatteryCard({Key key, @required this.sensor, this.cardId = "battery_card_id"}) : super(key: key);

  BatterySensor sensor;
  String cardId;

  @override
  BatteryCardState createState() => new BatteryCardState();
}


class BatteryCardState extends State<BatteryCard> {

  String batteryLevel = "";
  String condition = "";


  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onBatteryChanged(widget.cardId).listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          batteryLevel = event['level'].toString();
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });

    /** onBatteryCharging event */
    widget.sensor.onBatteryCharging(widget.cardId+"_charging").listen((event) {
      setState((){
        // event
        condition = "charging";
      });
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    });

    /** onBatteryDischarging event */
    widget.sensor.onBatteryDischarging(widget.cardId+"_discharging").listen((event) {
      setState((){
        // event
        condition = "discharging";
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
          child: new Text("Battery Level: $batteryLevel\nCondition: $condition")
        ),
      title: "Battery",
      sensor: widget.sensor
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.sensor.cancelBroadcastStream(widget.cardId);
    widget.sensor.cancelBroadcastStream(widget.cardId+"_charging");
    widget.sensor.cancelBroadcastStream(widget.cardId+"_discharging");
    super.dispose();
  }

}
