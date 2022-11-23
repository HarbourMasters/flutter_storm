#include "include/flutter_storm/flutter_storm_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <memory>
#include <string>
#include <vector>

#include "StormLib.h"

using namespace flutter;

#define FLUTTER_STORM_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_storm_plugin_get_type(), \
                              FlutterStormPlugin))

#define METHOD(name) if(method_call.method_name().compare(name) == 0)
#define ASSERT(arg) if(!arg) {                                               \
                        result->Error("argument_error", #arg " is missing"); \
                        return;                                              \
                    }                                                        \

std::vector<HANDLE> mpqInstances;
std::vector<HANDLE> fileInstances;

const EncodableValue* ValueOrNull(const EncodableMap & map, const char* key) {
    auto it = map.find(EncodableValue(key));
    if (it == map.end()) {
        return nullptr;
    }
    return &(it->second);
}

// Looks for |key| in |map|, returning the associated int64 value if it is
// present, or std::nullopt if not.
std::optional<int64_t> GetInt64ValueOrNull(const EncodableMap & map, const char* key) {
    auto value = ValueOrNull(map, key);
    if (!value) {
        return std::nullopt;
    }

    if (std::holds_alternative<int32_t>(*value)) {
        return static_cast<int64_t>(std::get<int32_t>(*value));
    }
    auto val64 = std::get_if<int64_t>(value);
    if (!val64) {
        return std::nullopt;
    }
    return *val64;
}

std::optional<std::string> GetStringOrNull(const EncodableMap& map, const char* key) {
    auto value = ValueOrNull(map, key);
    if (!value) {
        return std::nullopt;
    }

    auto str = std::get_if<std::string>(value);
    if (!str) {
        return std::nullopt;
    }
    return *str;
}

std::optional<std::vector<uint8_t>> GetU8ListOrNull(const EncodableMap& map, const char* key) {
    auto value = ValueOrNull(map, key);
    if (!value) {
        return std::nullopt;
    }

    auto list = std::get_if<std::vector<uint8_t>>(value);
    if (!list) {
        return std::nullopt;
    }
    return *list;
}

struct _FlutterStormPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FlutterStormPlugin, flutter_storm_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void flutter_storm_plugin_handle_method_call(
    FlutterStormPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_storm_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_storm_plugin_parent_class)->dispose(object);
}

static void flutter_storm_plugin_class_init(FlutterStormPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_storm_plugin_dispose;
}

static void flutter_storm_plugin_init(FlutterStormPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlutterStormPlugin* plugin = FLUTTER_STORM_PLUGIN(user_data);
  flutter_storm_plugin_handle_method_call(plugin, method_call);
}

void flutter_storm_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterStormPlugin* plugin = FLUTTER_STORM_PLUGIN(
      g_object_new(flutter_storm_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "flutter_storm",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
