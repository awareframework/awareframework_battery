import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';

/// The Battery measures the acceleration applied to the sensor
/// built-in into the device, including the force of gravity.
///
/// Your can initialize this class by the following code.
/// ```dart
/// var sensor = BatterySensor();
/// ```
///
/// If you need to initialize the sensor with configurations,
/// you can use the following code instead of the above code.
/// ```dart
/// var config =  BatterySensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
///
/// var sensor = BatterySensor.init(config);
/// ```
///
/// Each sub class of AwareSensor provides the following method for controlling
/// the sensor:
/// - `start()`
/// - `stop()`
/// - `enable()`
/// - `disable()`
/// - `sync()`
/// - `setLabel(String label)`
///
/// `Stream<BatteryData>` allow us to monitor the sensor update
/// events as follows:
///
/// ```dart
/// sensor.onDataChanged.listen((data) {
///   print(data)
/// }
/// ```
///
/// In addition, this package support data visualization function on Cart Widget.
/// You can generate the Cart Widget by following code.
/// ```dart
/// var card = BatteryCard(sensor: sensor);
/// ```
class BatterySensor extends AwareSensor {
  static const MethodChannel _batteryMethod = const MethodChannel('awareframework_battery/method');
//  static const EventChannel  _batteryStream  = const EventChannel('awareframework_battery/event');

  static const EventChannel  _onBatteryChangedChannel   = const EventChannel('awareframework_battery/event_on_battery_changed');
  static const EventChannel  _onBatteryLowChannel       = const EventChannel('awareframework_battery/event_on_battery_low');
  static const EventChannel  _onBatteryChargingChannel  = const EventChannel('awareframework_battery/event_on_battery_charging');
  static const EventChannel  _onBatteryDischargingChannel  = const EventChannel('awareframework_battery/event_on_battery_discharging');

  static StreamController<BatteryData> onBatteryChangedStreamController     = StreamController<BatteryData>();
  static StreamController<dynamic> onBatteryLowStreamController        = StreamController<dynamic>();
  static StreamController<dynamic> onBatteryChargingStreamController   = StreamController<dynamic>();
  static StreamController<dynamic> onBatteryDischargingStreamController = StreamController<dynamic>();

  BatteryData data = BatteryData();

  /// Init Battery Sensor without a configuration file
  ///
  /// ```dart
  /// var sensor = BatterySensor.init(null);
  /// ```
  BatterySensor():this.init(null);

  /// Init Battery Sensor with BatterySensorConfig
  ///
  /// ```dart
  /// var config =  BatterySensorConfig();
  /// config
  ///   ..debug = true
  ///   ..frequency = 100;
  ///
  /// var sensor = BatterySensor.init(config);
  /// ```
  BatterySensor.init(config) : super(config){
    super.setMethodChannel(_batteryMethod);
  }

  /// An event channel for monitoring sensor events.
  ///
  /// `Stream<BatteryData>` allow us to monitor the sensor update
  /// events as follows:
  ///
  /// ```dart
  /// sensor.onDataChanged.listen((data) {
  ///   print(data)
  /// }
  ///
  Stream<BatteryData> get onBatteryChanged {
    onBatteryChangedStreamController.close();
    onBatteryChangedStreamController = StreamController<BatteryData>();
     return onBatteryChangedStreamController.stream;
  }

  Stream<dynamic> get onBatteryLow {
    return initStreamController(onBatteryLowStreamController).stream;
  }

  Stream<dynamic> get onBatteryCharging {
    return initStreamController(onBatteryChargingStreamController).stream;
  }

  Stream<dynamic> get onBatteryDischarging {
    return initStreamController(onBatteryDischargingStreamController).stream;
  }

  StreamController<dynamic> initStreamController(StreamController<dynamic> controller){
    controller.close();
    controller = StreamController<dynamic>();
    return controller;
  }

  @override
  Future<Null> start(){
    super.getBroadcastStream(_onBatteryChangedChannel, "on_battery_changed").map(
            (dynamic event) => BatteryData.from(Map<String,dynamic>.from(event))
    ).listen((event){
      data = event;
      if(!onBatteryChangedStreamController.isClosed){
        onBatteryChangedStreamController.add(event);
      }
    });

    super.getBroadcastStream(_onBatteryLowChannel,"on_battery_low").listen((event){
      if(!onBatteryLowStreamController.isClosed){
        onBatteryLowStreamController.add(event);
      }
    });

    super.getBroadcastStream(_onBatteryChargingChannel,"on_battery_charging").listen((event){
      if(!onBatteryChargingStreamController.isClosed){
        onBatteryChargingStreamController.add(event);
      }
    });

    super.getBroadcastStream(_onBatteryDischargingChannel,"on_battery_discharging").listen((event){
      if(!onBatteryDischargingStreamController.isClosed){
        onBatteryDischargingStreamController.add(event);
      }
    });
    return super.start();
  }

  @override
  Future<Null> stop() {
    super.cancelBroadcastStream("on_battery_changed");
    super.cancelBroadcastStream("on_battery_low");
    super.cancelBroadcastStream("on_battery_charging");
    super.cancelBroadcastStream("on_battery_discharging");
    return super.stop();
  }
}

/// A configuration class of BatterySensor
///
/// You can initialize the class by following code.
///
/// ```dart
/// var config =  BatterySensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
/// ```
class BatterySensorConfig extends AwareSensorConfig{
  BatterySensorConfig();
  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// A data model of BatterySensor
///
/// This class converts sensor data that is Map<String,dynamic> format, to a
/// sensor data object.
///
class BatteryData extends AwareData {
  int status = 0;
  int level = 0;
  int scale = 0;

  BatteryData():this.from(null);

  BatteryData.from(Map<String,dynamic> data):super.from(data){
    if (data != null){
      status = data["status"] ?? 0;
      level = data["level"] ?? 0;
      scale = data["sacle"] ?? 0;
    }
  }

}

///
/// A Card Widget of Battery Sensor
///
/// You can generate a Cart Widget by following code.
/// ```dart
/// var card = BatteryCard(sensor: sensor);
/// ```
class BatteryCard extends StatefulWidget {
  BatteryCard({Key key, @required this.sensor}) : super(key: key);

  final BatterySensor sensor;

  @override
  BatteryCardState createState() => new BatteryCardState();
}


class BatteryCardState extends State<BatteryCard> {

  String batteryLevel = "";
  String condition = "";

  @override
  void initState() {

    super.initState();

    if(mounted){
      setState((){
        updateBatteryLevelChangeContent(widget.sensor.data);
      });
    }
    /// battery level change events
    widget.sensor.onBatteryChanged.listen((event) {
      if(event!=null){
        if(mounted){
          setState((){
            updateBatteryLevelChangeContent(event);
          });
        }else{
          updateBatteryLevelChangeContent(event);
        }
      }
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });


    /// onBatteryCharging events
    widget.sensor.onBatteryCharging.listen((event) {
      if(mounted){
        setState((){
          updateBatteryChargeEventContent("charging");
        });
      }else{
        updateBatteryChargeEventContent("charging");
      }
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    });

    /// onBatteryDischarging events
    widget.sensor.onBatteryDischarging.listen((event) {
      if(mounted){
        setState((){
          updateBatteryChargeEventContent("discharging");
        });
      }else{
        updateBatteryChargeEventContent("discharging");
      }
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    });

    print(widget.sensor);
  }

  void updateBatteryChargeEventContent(String event){
    condition = event;
  }

  void updateBatteryLevelChangeContent(BatteryData data){
    DateTime.fromMicrosecondsSinceEpoch(data.timestamp);
    batteryLevel = data.level.toString();
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
}
