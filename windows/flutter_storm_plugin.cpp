#include "flutter_storm_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <vector>

#include "StormLib.h"

using namespace flutter;

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

        METHOD("SFileOpenArchive") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto mpqName = GetStringOrNull(*arguments, "mpqName");
            auto mpqFlags = GetInt64ValueOrNull(*arguments, "mpqFlags");
            ASSERT(mpqName);
            ASSERT(mpqFlags);

            std::wstring wName;
            wName.assign((*mpqName).begin(), (*mpqName).end());

            HANDLE mpqFile;
            bool rs = SFileOpenArchive(wName.c_str(), 0, *mpqFlags, &mpqFile);

            if (rs) {
                result->Success(flutter::EncodableValue((int)mpqInstances.size()));
                mpqInstances.push_back(mpqFile);
                return;
            }

            result->Error("storm_error", "Failed to open MPQ [" + std::to_string(GetLastError()) + "]");
            return;
        }

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

            // if ((*hMpq) < 0 || mpqInstances.size() > (*hMpq) || mpqInstances.at(*hMpq) == nullptr) {
            //    result->Error("storm_error", "The specified mpq handle does not exists");
            //    return;
            // }

            bool rs = SFileCloseArchive(mpqInstances.at(*hMpq));

            if (rs) {
                result->Success(flutter::EncodableValue((int)mpqInstances.size()));
                mpqInstances.erase(mpqInstances.begin() + *hMpq);
                return;
            }

            result->Error("storm_error", "Failed to create MPQ [" + std::to_string(GetLastError()) + "]");
            return;
        }

        METHOD("SFileHasFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetInt64ValueOrNull(*arguments, "hMpq");
            auto fileName = GetStringOrNull(*arguments, "fileName");

            ASSERT(hMpq);
            ASSERT(fileName);


            bool rs = SFileHasFile(mpqInstances.at(*hMpq), (*fileName).c_str());
            result->Success(flutter::EncodableValue(rs));

            return;
        }

        METHOD("SFileCreateFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq     = GetInt64ValueOrNull(*arguments, "hMpq");
            auto fileName = GetStringOrNull(*arguments, "fileName");
            auto fileSize = GetInt64ValueOrNull(*arguments, "fileSize");
            auto dwFlags  = GetInt64ValueOrNull(*arguments, "dwFlags");

            ASSERT(hMpq);
            ASSERT(fileName);
            ASSERT(fileSize);
            ASSERT(dwFlags);

            SYSTEMTIME sysTime;
            GetSystemTime(&sysTime);
            FILETIME t;
            SystemTimeToFileTime(&sysTime, &t);
            ULONGLONG stupidHack = static_cast<uint64_t>(t.dwHighDateTime) << (sizeof(t.dwHighDateTime) * 8) | t.dwLowDateTime;

            HANDLE hFile;
            bool rs = SFileCreateFile(mpqInstances.at(*hMpq), (*fileName).c_str(), stupidHack, *fileSize, 0, *dwFlags, &hFile);

            if (rs) {
                result->Success(flutter::EncodableValue((int)fileInstances.size()));
                fileInstances.push_back(hFile);
                return;
            }

            result->Error("storm_error", "Failed to create file [" + std::to_string(GetLastError()) + "]");
            return;
        }

        METHOD("SFileWriteFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetInt64ValueOrNull(*arguments, "hFile");
            auto pvData = GetU8ListOrNull(*arguments, "pvData");
            auto dwSize = GetInt64ValueOrNull(*arguments, "dwSize");
            auto dwCompression = GetInt64ValueOrNull(*arguments, "dwCompression");

            ASSERT(hFile);
            ASSERT(pvData);
            ASSERT(dwSize);
            ASSERT(dwCompression);

            bool rs = SFileWriteFile(fileInstances.at(*hFile), (*pvData).data(), *dwSize, *dwCompression);

            if (rs) {
                result->Success();
                return;
            }

            result->Error("storm_error", "Failed to write file [" + std::to_string(GetLastError()) + "]");
            return;
        }

        METHOD("SFileRemoveFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetInt64ValueOrNull(*arguments, "hMpq");
            auto fileName = GetStringOrNull(*arguments, "fileName");

            ASSERT(hMpq);
            ASSERT(fileName);

            bool rs = SFileRemoveFile(mpqInstances.at(*hMpq), (*fileName).c_str(), 0);

            if (rs) {
                result->Success();
                return;
            }

            result->Error("storm_error", "Failed to remove file [" + std::to_string(GetLastError()) + "]");
            return;
        }

        METHOD("SFileRenameFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetInt64ValueOrNull(*arguments, "hMpq");
            auto oldFileName = GetStringOrNull(*arguments, "oldFileName");
            auto newFileName = GetStringOrNull(*arguments, "newFileName");

            ASSERT(hMpq);
            ASSERT(oldFileName);
            ASSERT(newFileName);

            bool rs = SFileRenameFile(mpqInstances.at(*hMpq), (*oldFileName).c_str(), (*newFileName).c_str());

            if (rs) {
                result->Success();
                return;
            }

            result->Error("storm_error", "Failed to rename file [" + std::to_string(GetLastError()) + "]");
            return;
        }

        METHOD("SFileFinishFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetInt64ValueOrNull(*arguments, "hFile");

            ASSERT(hFile);

            bool rs = SFileFinishFile(fileInstances.at(*hFile));

            if (rs) {
                result->Success();
                return;
            }

            result->Error("storm_error", "Failed to finish file [" + std::to_string(GetLastError()) + "]");
            return;
        }

        result->NotImplemented();
    }
}