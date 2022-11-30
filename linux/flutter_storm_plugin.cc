#include "include/flutter_storm/flutter_storm_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <memory>
#include <string>
#include <vector>
#include <optional>
#include <variant>
#include <unordered_map>

#include "StormLib.h"

#define FLUTTER_STORM_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_storm_plugin_get_type(), \
                              FlutterStormPlugin))                                                                                                         \

#define VALUE(arg, type) fl_value_get_##type(fl_value_lookup_string(args, arg));

#define METHOD(name) if(strcmp(method, name) == 0)
#define ASSERT(arg) if(fl_value_get_type(fl_value_lookup_string(args, #arg)) == FL_VALUE_TYPE_NULL) {                                \
                        response = FL_METHOD_RESPONSE(fl_method_error_response_new("argument_error", #arg " is missing", nullptr));  \
                        fl_method_call_respond(method_call, response, nullptr);                                                      \
                        return;                                                                                                      \
                    } \

#define SUCCESS_ARG(data, type) response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_##type(data)))
#define ERROR(error) response = FL_METHOD_RESPONSE(fl_method_error_response_new("storm_error", (error).c_str(), nullptr))

std::unordered_map<std::string, HANDLE> handles;

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
    FlValue* args = fl_method_call_get_args(method_call);

    METHOD("SFileOpenArchive") {
        ASSERT(mpqName);
        ASSERT(mpqFlags);

        std::string mpqName = VALUE("mpqName", string);
        int mpqFlags = VALUE("mpqFlags", int);

        HANDLE mpqFile;
        bool rs = SFileOpenArchive(mpqName.c_str(), 0, mpqFlags, &mpqFile);

        if (rs) {
            SUCCESS_ARG((int)mpqInstances.size(), int);
            mpqInstances.push_back(mpqFile);
        } else {
            ERROR("Failed to open MPQ [" + std::to_string(GetLastError()) + "]");
        }
        fl_method_call_respond(method_call, response, nullptr);
    }

    METHOD("SFileOpenArchive") {

        ASSERT(mpqName);
        ASSERT(mpqFlags);
        ASSERT(maxFileCount);

        std::string mpqName = VALUE("mpqName", string);
        int mpqFlags = VALUE("mpqFlags", int);
        int maxFileCount = VALUE("maxFileCount", int);

        HANDLE mpqFile;
        bool rs = SFileCreateArchive(mpqName.c_str(), mpqFlags, maxFileCount, &mpqFile);

        if (rs) {
            SUCCESS_ARG((int)mpqInstances.size(), int);
            mpqInstances.push_back(mpqFile);
        } else {
            ERROR("Failed to create MPQ [" + std::to_string(GetLastError()) + "]");
        }
        fl_method_call_respond(method_call, response, nullptr);
    }
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
