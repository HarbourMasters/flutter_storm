#include "include/flutter_storm/flutter_storm_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_storm_plugin.h"

void FlutterStormPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_storm::FlutterStormPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
