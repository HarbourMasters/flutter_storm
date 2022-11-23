#include "flutter_storm_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <vector>
#include "StormLib/src/StormLib.h"

using namespace flutter;

#define METHOD(name) if(method_call.method_name().compare(name) == 0)
#define ASSERT(arg) if(!arg) {                                              \
                        result->Error("argument_error", #arg " is missing"); \
                        return;                                             \
                    }                                                       \

std::vector<HANDLE> mpqInstances;

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

namespace flutter_storm {

    FlutterStormPlugin::FlutterStormPlugin(){}
    FlutterStormPlugin::~FlutterStormPlugin(){}

    void FlutterStormPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "flutter_storm",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<FlutterStormPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    void FlutterStormPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        METHOD("SFileCreateArchive") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());
            
            auto mpqName = GetStringOrNull(*arguments, "mpqName");
            auto mpqFlags = GetInt64ValueOrNull(*arguments, "mpqFlags");
            auto maxFileCount = GetInt64ValueOrNull(*arguments, "maxFileCount");
            ASSERT(mpqName);
            ASSERT(mpqFlags);
            ASSERT(maxFileCount);

            std::wstring wName;
            wName.assign((*mpqName).begin(), (*mpqName).end());

            HANDLE mpqFile;
            bool rs = SFileCreateArchive(wName.c_str(), *mpqFlags, *maxFileCount, &mpqFile);

            if (rs) {
                result->Success(flutter::EncodableValue((int) mpqInstances.size()));
                mpqInstances.push_back(mpqFile);
                return;
            }

            result->Error("storm_error", "Failed to create MPQ [" + std::to_string(GetLastError()) + "]");
            return;
        }

        METHOD("SFileCloseArchive") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetInt64ValueOrNull(*arguments, "hMpq");
            ASSERT(hMpq);

            if (*hMpq < 0 || mpqInstances.size() > *hMpq || mpqInstances.at(*hMpq) == nullptr) {
                result->Error("storm_error", "The specified mpq handle does not exists");
                return;
            }

            bool rs = SFileCloseArchive(mpqInstances.at(*hMpq));

            if (rs) {
                result->Success(flutter::EncodableValue((int)mpqInstances.size()));
                mpqInstances.erase(mpqInstances.begin() + *hMpq);
                return;
            }

            result->Error("storm_error", "Failed to create MPQ [" + std::to_string(GetLastError()) + "]");
            return;
        }

        result->NotImplemented();
    }
}