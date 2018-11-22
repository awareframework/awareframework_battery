#import "AwareframeworkBatteryPlugin.h"
#import <awareframework_battery/awareframework_battery-Swift.h>

@implementation AwareframeworkBatteryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwareframeworkBatteryPlugin registerWithRegistrar:registrar];
}
@end
