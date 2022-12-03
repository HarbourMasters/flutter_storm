#include "flutter_storm_plugin.h"

// This must be included before many other Windows headers.
#pragma comment(lib, "rpcrt4.lib")
#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <vector>
#include <unordered_map>

#include "StormLib.h"

using namespace flutter;

#define ERROR_FAILED_TO_OPEN_MPQ 0x20

#define METHOD(name) if(method_call.method_name().compare(name) == 0)
#define ASSERT(arg) if(!arg) {                                               \
                        result->Error("argument_error", #arg " is missing"); \
                        return;                                              \
                    }                                                        \

std::unordered_map<std::string, HANDLE> handles;
std::unordered_map<std::string, SFILE_FIND_DATA> findDataPointers;

#define HAS_HANDLE(key) (handles.find(key) != handles.end())
#define HAS_FILE_PTR(key) (findDataPointers.find(key) != findDataPointers.end())

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

std::string GenerateUUID() {
    UUID uuid;
    UuidCreate(&uuid);
    char* str;
    UuidToStringA(&uuid, (RPC_CSTR*)&str);
    std::string uuidStr(str);
    RpcStringFreeA((RPC_CSTR*)&str);
    return uuidStr;
}

std::string MPQErrorString(DWORD error) {
    switch (error) {
        case ERROR_SUCCESS:
            return "The operation completed successfully.";
        case ERROR_FILE_NOT_FOUND:
            return "The system cannot find the file specified.";
        case ERROR_ACCESS_DENIED:
            return "Access is denied.";
        case ERROR_INVALID_HANDLE:
            return "The handle is invalid.";
        case ERROR_NOT_ENOUGH_MEMORY:
            return "Not enough storage is available to process this command.";
        case ERROR_NOT_SUPPORTED:
            return "The request is not supported.";
        case ERROR_INVALID_PARAMETER:
            return "One of the parameters is incorrect.";
        case ERROR_NEGATIVE_SEEK:
            return "An attempt was made to move the file pointer before the beginning of the file.";
        case ERROR_DISK_FULL:
            return "There is not enough space on the disk.";
        case ERROR_ALREADY_EXISTS:
            return "Cannot create a file when that file already exists.";
        case ERROR_INSUFFICIENT_BUFFER:
            return "The data area passed to a system call is too small.";
        case  ERROR_BAD_FORMAT:
            return "The .mpq archive is corrupt.";
        case ERROR_NO_MORE_FILES:
            return "No more files were found.";
        case ERROR_HANDLE_EOF:
            return "Reached the end of the file.";
        case ERROR_CAN_NOT_COMPLETE:
            return "Cannot complete this function.";
        case ERROR_FILE_CORRUPT:
            return "The file or directory is corrupted and unreadable.";
        case ERROR_AVI_FILE:
            return "The file is an MPQ but an AVI file.";
        case ERROR_UNKNOWN_FILE_KEY:
            return "The system cannot find the key file.";
        case ERROR_CHECKSUM_ERROR:
            return "The crc sector doesn't match.";
        case ERROR_INTERNAL_FILE:
            return "The given operation is not allowed on internal file.";
        case ERROR_BASE_FILE_MISSING:
            return "The file is present as incremental patch file, but base file is missing.";
        case ERROR_MARKED_FOR_DELETE:
            return "The file was marked as \"deleted\" in the MPQ.";
        case ERROR_FILE_INCOMPLETE:
            return "The required file part is missing.";
        case ERROR_UNKNOWN_FILE_NAMES:
            return "A name of at least one file is unknown.";
        case ERROR_CANT_FIND_PATCH_PREFIX:
            return "StormLib was unable to find patch prefix for the patches.";
        case ERROR_FAKE_MPQ_HEADER:
            return "The header at this position is fake header.";
        case ERROR_FAILED_TO_OPEN_MPQ: // TODO: Find a better way to handle this
            return "Failed to open mpq archive it could be corrupted or busy.";
    }
    return "Unknown error [" + std::to_string(error) + "]";
}

#define FAIL_WITH_ERROR(error) result->Error(std::to_string(error), MPQErrorString(GetLastError()));

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
                std::string uuid = GenerateUUID();
                handles[uuid] = mpqFile;
                result->Success(EncodableValue(uuid));
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
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
                std::string uuid = GenerateUUID();
                handles[uuid] = mpqFile;
                result->Success(EncodableValue(uuid));
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileCloseArchive") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetStringOrNull(*arguments, "hMpq");
            ASSERT(hMpq);

            // check if handle is valid

            if (!HAS_HANDLE(*hMpq)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hMpq];

            bool rs = SFileCloseArchive(handle);

            if (rs) {
                handles.erase(*hMpq);
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileHasFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetStringOrNull(*arguments, "hMpq");
            auto fileName = GetStringOrNull(*arguments, "fileName");

            ASSERT(hMpq);
            ASSERT(fileName);

            // check if handle is valid

            if (!HAS_HANDLE(*hMpq)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hMpq];

            bool rs = SFileHasFile(handle, (*fileName).c_str());
            result->Success(EncodableValue(rs));
            return;
        }

        METHOD("SFileCreateFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq     = GetStringOrNull(*arguments, "hMpq");
            auto fileName = GetStringOrNull(*arguments, "fileName");
            auto fileSize = GetInt64ValueOrNull(*arguments, "fileSize");
            auto dwFlags  = GetInt64ValueOrNull(*arguments, "dwFlags");

            ASSERT(hMpq);
            ASSERT(fileName);
            ASSERT(fileSize);
            ASSERT(dwFlags);

            // check if handle is valid

            if (!HAS_HANDLE(*hMpq)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hMpq];

            SYSTEMTIME sysTime;
            GetSystemTime(&sysTime);
            FILETIME t;
            SystemTimeToFileTime(&sysTime, &t);
            ULONGLONG stupidHack = static_cast<uint64_t>(t.dwHighDateTime) << (sizeof(t.dwHighDateTime) * 8) | t.dwLowDateTime;

            HANDLE hFile;
            bool rs = SFileCreateFile(handle, (*fileName).c_str(), stupidHack, *fileSize, 0, *dwFlags, &hFile);

            if (rs) {
                std::string uuid = GenerateUUID();
                handles[uuid] = hFile;
                result->Success(EncodableValue(uuid));
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileCloseFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetStringOrNull(*arguments, "hFile");
            ASSERT(hFile);

            // check if handle is valid

            if (!HAS_HANDLE(*hFile)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hFile];


            bool rs = SFileCloseFile(handle);

            if (rs) {
                handles.erase(*hFile);
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileWriteFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetStringOrNull(*arguments, "hFile");
            auto pvData = GetU8ListOrNull(*arguments, "pvData");
            auto dwSize = GetInt64ValueOrNull(*arguments, "dwSize");
            auto dwCompression = GetInt64ValueOrNull(*arguments, "dwCompression");

            ASSERT(hFile);
            ASSERT(pvData);
            ASSERT(dwSize);
            ASSERT(dwCompression);

            // check if handle is valid

            if (!HAS_HANDLE(*hFile)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hFile];

            bool rs = SFileWriteFile(handle, (*pvData).data(), *dwSize, *dwCompression);

            if (rs) {
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileRemoveFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetStringOrNull(*arguments, "hMpq");
            auto fileName = GetStringOrNull(*arguments, "fileName");

            ASSERT(hMpq);
            ASSERT(fileName);

            // check if handle is valid

            if (!HAS_HANDLE(*hMpq)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hMpq];

            bool rs = SFileRemoveFile(handle, (*fileName).c_str(), 0);

            if (rs) {
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileRenameFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetStringOrNull(*arguments, "hMpq");
            auto oldFileName = GetStringOrNull(*arguments, "oldFileName");
            auto newFileName = GetStringOrNull(*arguments, "newFileName");

            ASSERT(hMpq);
            ASSERT(oldFileName);
            ASSERT(newFileName);

            // check if handle is valid

            if (!HAS_HANDLE(*hMpq)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hMpq];


            bool rs = SFileRenameFile(handle, (*oldFileName).c_str(), (*newFileName).c_str());

            if (rs) {
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileFinishFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetStringOrNull(*arguments, "hFile");
            ASSERT(hFile);

            // check if handle is valid

            if (!HAS_HANDLE(*hFile)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hFile];

            bool rs = SFileFinishFile(handle);

            if (rs) {
                handles.erase(*hFile);
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileFindFirstFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetStringOrNull(*arguments, "hMpq");
            auto szMask = GetStringOrNull(*arguments, "szMask");
            auto lpFindFileData = GetStringOrNull(*arguments, "lpFindFileData");
            ASSERT(hMpq);
            ASSERT(szMask);
            ASSERT(lpFindFileData);

            // check if handle is valid
            if (!HAS_HANDLE(*hMpq) || !HAS_FILE_PTR(*lpFindFileData)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            SFILE_FIND_DATA* findData = &findDataPointers[*lpFindFileData];

            HANDLE handle = handles[*hMpq];
            HANDLE fHandle = SFileFindFirstFile(handle, (*szMask).c_str(), findData, NULL);

            if (fHandle != nullptr) {
                std::string uuid = GenerateUUID();
                handles[uuid] = fHandle;
                result->Success(EncodableValue(uuid));
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileFindNextFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFind = GetStringOrNull(*arguments, "hFind");
            auto lpFindFileData = GetStringOrNull(*arguments, "lpFindFileData");
            ASSERT(hFind);
            ASSERT(lpFindFileData);

            // check if handle is valid
            if (!HAS_HANDLE(*hFind) || !HAS_FILE_PTR(*lpFindFileData)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            SFILE_FIND_DATA* findData = &findDataPointers[*lpFindFileData];

            HANDLE handle = handles[*hFind];
            bool rs = SFileFindNextFile(handle, findData);

            if (rs) {
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileFindClose") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFind = GetStringOrNull(*arguments, "hFind");
            ASSERT(hFind);

            // check if handle is valid
            if (!HAS_HANDLE(*hFind)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hFind];
            bool rs = SFileFindClose(handle);

            if (rs) {
                handles.erase(*hFind);
                result->Success();
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileOpenFileEx") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hMpq = GetStringOrNull(*arguments, "hMpq");
            auto szFileName = GetStringOrNull(*arguments, "szFileName");
            auto dwSearchScope = GetInt64ValueOrNull(*arguments, "dwSearchScope");
            ASSERT(hMpq);
            ASSERT(szFileName);
            ASSERT(dwSearchScope);

            // check if handle is valid
            if (!HAS_HANDLE(*hMpq)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE fHandle = nullptr;
            HANDLE handle = handles[*hMpq];
            SFileOpenFileEx(handle, (*szFileName).c_str(), *dwSearchScope, &fHandle);
            if (fHandle != nullptr) {
                std::string uuid = GenerateUUID();
                handles[uuid] = fHandle;
                result->Success(EncodableValue(uuid));
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileGetFileSize") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetStringOrNull(*arguments, "hFile");
            ASSERT(hFile);

            // check if handle is valid
            if (!HAS_HANDLE(*hFile)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hFile];
            DWORD size = SFileGetFileSize(handle, 0);

            if (size != SFILE_INVALID_SIZE) {
                result->Success(EncodableValue(size));
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        METHOD("SFileReadFile") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto hFile = GetStringOrNull(*arguments, "hFile");
            auto dwToRead = GetInt64ValueOrNull(*arguments, "dwToRead");
            ASSERT(hFile);
            ASSERT(dwToRead);

            // check if handle is valid
            if (!HAS_HANDLE(*hFile)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            HANDLE handle = handles[*hFile];
            DWORD countBytes;
            char* lpBuffer = new char[*dwToRead];

            bool rs = SFileReadFile(handle, lpBuffer, *dwToRead, &countBytes, NULL);

            if (rs) {
                EncodableValue bytes = EncodableValue(std::vector<uint8_t>(lpBuffer, lpBuffer + countBytes));
                result->Success(bytes);
                return;
            }

            FAIL_WITH_ERROR(GetLastError());
            return;
        }

        // Custom methods

        METHOD("SFileFindCreateDataPointer") {
            SFILE_FIND_DATA findData = {};
            std::string uuid = GenerateUUID();
            findDataPointers[uuid.c_str()] = findData;
            result->Success(EncodableValue(uuid));
            return;
        }

        METHOD("SFileFindGetDataForDataPointer") {
            const auto* arguments =
                std::get_if<flutter::EncodableMap>(method_call.arguments());

            auto lpFindFileData = GetStringOrNull(*arguments, "lpFindFileData");
            ASSERT(lpFindFileData);

            // check if handle is valid
            if (!HAS_FILE_PTR(*lpFindFileData)) {
                FAIL_WITH_ERROR(ERROR_INVALID_HANDLE);
                return;
            }

            SFILE_FIND_DATA* findData = &findDataPointers[*lpFindFileData];
            result->Success(EncodableValue(findData->cFileName));
            return;
        }

        result->NotImplemented();
    }
}