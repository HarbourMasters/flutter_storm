//
//  FLEFlutterPlugin.mm
//  flutter_storm
//
//  Created by David Chavez on 06.11.20.
//

#import "FLEStormPlugin.h"
#include "../StormLib/src/StormLib.h"

#include <vector>

namespace {
NSString *const kChannelName = @"flutter_storm";
NSString *const kFileOpenArchive = @"SFileOpenArchive";
NSString *const kFileCreateArchive = @"SFileCreateArchive";
NSString *const kFileCloseArchive = @"SFileCloseArchive";
NSString *const kFileHasFile = @"SFileHasFile";
NSString *const kFileCreateFile = @"SFileCreateFile";
NSString *const kFileWriteFile = @"SFileWriteFile";
NSString *const kFileCloseFile = @"SFileCloseFile";
NSString *const kFileRemoveFile = @"SFileRemoveFile";
NSString *const kFileRenameFile = @"SFileRenameFile";
NSString *const kFileFinishFile = @"SFileFinishFile";
}

@interface FLEStormPlugin ()
@end

@implementation FLEStormPlugin {
  // The channel used to communicate with Flutter.
  FlutterMethodChannel *_channel;

  // A reference to the registrar holding the NSView used by the plugin. Holding a reference
  // since the view might be nil at the time the plugin is created.
  id<FlutterPluginRegistrar> _registrar;
  
  // Array to hold all open archives (void *)
  std::vector<HANDLE> _archives;

  // Array to hold all open files
  std::vector<HANDLE> _files;
}

+ (void)registerWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:kChannelName
                                                              binaryMessenger:registrar.messenger];
    FLEStormPlugin *instance = [[FLEStormPlugin alloc] initWithChannel:channel
                                                                     registrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(id<FlutterPluginRegistrar>)registrar {
  self = [super init];
  if (self) {
    _channel = channel;
    _registrar = registrar;
  }
  return self;
}

/**
 * Handles platform messages generated by the Flutter framework on the platform channel.
 */
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    id methodResult = nil;

    if ([call.method isEqualToString:kFileOpenArchive]) {
        NSDictionary *args = call.arguments;

        NSString *mpqName = args[@"mpqName"];
        NSNumber *mpqFlags = args[@"mpqFlags"];
        
        HANDLE mpqHandle;
        bool success = SFileOpenArchive([mpqName UTF8String], [mpqFlags unsignedIntValue], 0, &mpqHandle);
        if (success) {
            _archives.push_back(mpqHandle);
            methodResult = [NSNumber numberWithUnsignedLongLong:(unsigned long long)mpqHandle];
        } else {
            methodResult = [NSNumber numberWithUnsignedLongLong:0];
        }
    } else if ([call.method isEqualToString:kFileCreateArchive]) {
        NSDictionary *args = call.arguments;

        NSString *mpqName = args[@"mpqName"];
        NSNumber *mpqFlags = args[@"mpqFlags"];
        NSNumber *maxFileCount = args[@"maxFileCount"];

        HANDLE mpqHandle;
        bool success = SFileCreateArchive([mpqName UTF8String], [mpqFlags unsignedIntValue], [maxFileCount unsignedIntValue], &mpqHandle);
        if (success) {
            _archives.push_back(mpqHandle);
            methodResult = [NSNumber numberWithUnsignedLongLong:(unsigned long long)_archives.size() - 1];
        } else {
            methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
        }
    } else if ([call.method isEqualToString:kFileCloseArchive]) {
        NSDictionary *args = call.arguments;
        NSNumber *mpqHandle = args[@"hMpq"];

        // check mpqHandle is valid
        if ([mpqHandle unsignedLongLongValue] >= _archives.size()) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_INVALID_HANDLE];
        } else {
            bool success = SFileCloseArchive(_archives[[mpqHandle unsignedLongLongValue]]);
            if (success) {
                _archives.erase(_archives.begin() + [mpqHandle unsignedLongLongValue]);
                methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
            } else {
                methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
            }
        }
    } else if ([call.method isEqualToString:kFileHasFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *mpqHandle = args[@"hMpq"];
        NSString *fileName = args[@"fileName"];

        // check mpqHandle is valid
        if ([mpqHandle unsignedLongLongValue] >= _archives.size()) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_INVALID_HANDLE];
        } else {
            bool success = SFileHasFile(_archives[[mpqHandle unsignedLongLongValue]], [fileName UTF8String]);
            if (success) {
                methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
            } else {
                methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
            }
        }
    } else if ([call.method isEqualToString:kFileCreateFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *mpqHandle = args[@"hMpq"];
        NSString *fileName = args[@"fileName"];
        NSNumber *fileSize = args[@"fileSize"];
        NSNumber *dwFlags = args[@"dwFlags"];

        // check mpqHandle is valid
        if ([mpqHandle unsignedLongLongValue] >= _archives.size()) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_INVALID_HANDLE];
        } else {
            HANDLE fileHandle;
            time_t theTime;
            time(&theTime);
            bool success = SFileCreateFile(_archives[[mpqHandle unsignedLongLongValue]], [fileName UTF8String], theTime, [fileSize unsignedIntValue], 0, [dwFlags unsignedIntValue], &fileHandle);
            if (success) {
                _files.push_back(fileHandle);
                methodResult = [NSNumber numberWithUnsignedLongLong:(unsigned long long)_files.size() - 1];
            } else {
                methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
            }
        }
    } else if ([call.method isEqualToString:kFileWriteFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *fileHandle = args[@"hFile"];
        FlutterStandardTypedData *data = args[@"pvData"];
        NSNumber *dwSize = args[@"dwSize"];
        NSNumber *dwCompression = args[@"dwCompression"];

        bool success = SFileWriteFile(_files[[fileHandle unsignedLongLongValue]], [[data data] bytes], [dwSize unsignedIntValue], [dwCompression unsignedIntValue]);
        if (success) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
        } else {
            methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
        }
    } else if ([call.method isEqualToString:kFileCloseFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *fileHandle = args[@"hMpq"];

        bool success = SFileCloseFile(_files[[fileHandle unsignedLongLongValue]]);
        if (success) {
            _files.erase(_files.begin() + [fileHandle unsignedLongLongValue]);
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
        } else {
            methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
        }
    } else if ([call.method isEqualToString:kFileRemoveFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *mpqHandle = args[@"hMpq"];
        NSString *fileName = args[@"fileName"];

        // check mpqHandle is valid
        if ([mpqHandle unsignedLongLongValue] >= _archives.size()) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_INVALID_HANDLE];
        } else {
            bool success = SFileRemoveFile(_archives[[mpqHandle unsignedLongLongValue]], [fileName UTF8String], 0);
            if (success) {
                methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
            } else {
                methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
            }
        }
    } else if ([call.method isEqualToString:kFileRenameFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *mpqHandle = args[@"hMpq"];
        NSString *oldFileName = args[@"oldFileName"];
        NSString *newFileName = args[@"newFileName"];

        // check mpqHandle is valid
        if ([mpqHandle unsignedLongLongValue] >= _archives.size()) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_INVALID_HANDLE];
        } else {
            bool success = SFileRenameFile(_archives[[mpqHandle unsignedLongLongValue]], [oldFileName UTF8String], [newFileName UTF8String]);
            if (success) {
                methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
            } else {
                methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
            }
        }
    } else if ([call.method isEqualToString:kFileFinishFile]) {
        NSDictionary *args = call.arguments;
        NSNumber *fileHandle = args[@"hFile"];

        bool success = SFileFinishFile(_files[[fileHandle unsignedLongLongValue]]);
        if (success) {
            methodResult = [NSNumber numberWithUnsignedInt:ERROR_SUCCESS];
        } else {
            methodResult = [NSNumber numberWithUnsignedInt:GetLastError()];
        }
    } else {
        methodResult = FlutterMethodNotImplemented;
    }

    result(methodResult);
}

@end
