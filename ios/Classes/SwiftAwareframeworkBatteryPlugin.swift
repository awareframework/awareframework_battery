import Flutter
import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_battery
import com_awareframework_ios_sensor_core
import awareframework_core

public class SwiftAwareframeworkBatteryPlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler, BatteryObserver{
    
    var batterySensor:BatterySensor?
    
    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        if self.sensor == nil {
            if let config = call.arguments as? Dictionary<String,Any>{
                let json = JSON.init(config)
                self.batterySensor = BatterySensor.init(BatterySensor.Config(json))
            }else{
                self.batterySensor = BatterySensor.init(BatterySensor.Config())
            }
            self.batterySensor?.CONFIG.sensorObserver = self
            return self.batterySensor
        }else{
            return nil
        }
    }


    public override init() {
        super.init()
        super.initializationCallEventHandler = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftAwareframeworkBatteryPlugin()
        super.setMethodChannel(with: registrar, instance: instance, channelName: "awareframework_battery/method")
        super.setEventChannels(with: registrar,
                               instance: instance,
                               channelNames: [
                                "awareframework_battery/event",
                                "awareframework_battery/event_on_battery_changed",
                                "awareframework_battery/event_on_battery_low",
                                "awareframework_battery/event_on_battery_charging",
                                "awareframework_battery/event_on_battery_discharging"
                                ])
    }

    public func onBatteryChanged(data: BatteryData) {
        for handler in self.streamHandlers {
            if handler.eventName == "on_battery_changed" {
                handler.eventSink(data.toDictionary())
            }
        }
    }
    
    public func onBatteryLow() {
        for handler in self.streamHandlers {
            if handler.eventName == "on_battery_low" {
                handler.eventSink(nil)
            }
        }
    }
    
    public func onBatteryCharging() {
        for handler in self.streamHandlers {
            if handler.eventName == "on_battery_charging" {
                handler.eventSink(nil)
            }
        }
    }
    
    public func onBatteryDischarging() {
        for handler in self.streamHandlers {
            if handler.eventName == "on_battery_discharging" {
                handler.eventSink(nil)
            }
        }
    }
}
