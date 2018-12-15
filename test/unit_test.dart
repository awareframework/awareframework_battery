import 'package:test/test.dart';

import 'package:awareframework_battery/awareframework_battery.dart';

void main(){
  test("test sensor config", (){
    var config = BatterySensorConfig();

    expect(config.debug, false);
    expect(config.deviceId, "");

  });
}