import Cocoa
import FlutterMacOS

public class FlutterStormPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    FLEStormPlugin.register(with: registrar)
  }
}
