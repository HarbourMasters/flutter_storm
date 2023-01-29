import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'flutter_storm_bindings_generated.dart';

const int ERROR_NO_MORE_FILES = 1001;

class StormLibException {
  final int code;
  final String message;

  StormLibException(this.code, this.message);

  @override
  String toString() => message;
}

class FindFileHandle {
  // char   cFileName[MAX_PATH];              // Name of the found file
  // char * szPlainName;                      // Plain name of the found file
  // DWORD  dwHashIndex;                      // Hash table index for the file
  // DWORD  dwBlockIndex;                     // Block table index for the file
  // DWORD  dwFileSize;                       // Uncompressed size of the file, in bytes
  // DWORD  dwFileFlags;                      // MPQ file flags
  // DWORD  dwCompSize;                       // Compressed file size
  // DWORD  dwFileTimeLo;                     // Low 32-bits of the file time (0 if not present)
  // DWORD  dwFileTimeHi;                     // High 32-bits of the file time (0 if not present)
  // LCID   lcLocale;                         // Locale version

  late HANDLE _handle = calloc();
  final Pointer<SFILE_FIND_DATA> _data = calloc();

  /// Closes a find handle that has been created by SFileFindFirstFile.
  void close() {
    _bindings.SFileFindClose(_handle);
    // calloc.free(_handle);
    calloc.free(_data);
  }

  String? fileName() {
    if (_data.ref.cFileName[0] == 0) {
      return null;
    }

    return String.fromCharCodes(_data.ref.spreadCFileName());
  }
}

class MPQFile {
  final Pointer<HANDLE> _handle = calloc();

  /// Wwrites data to the archive.
  void write(Uint8List data, int fileSize, int compression) {
    final pointer = calloc<Uint8>(data.length);
    for (int i = 0; i < data.length; i++) {
      pointer[i] = data[i];
    }
    final voidStar = pointer.cast<Void>();

    final int ret = _bindings.SFileWriteFile(
        _handle.value, voidStar, fileSize, compression);
    calloc.free(pointer);
    if (ret == 0) {
      int error = _bindings.GetLastError();
      throw StormLibException(error, 'SFileWriteFile failed with error $error');
    }
  }
}

class MPQArchive {
  final Pointer<HANDLE> _handle = calloc();

  /// Opens a MPQ archive. During the open operation, the archive is checked for corruptions, internal (listfile) and (attributes) are loaded, unless specified otherwise.
  /// The archive is open for read and write operations, unless MPQ_OPEN_READ_ONLY is specified.
  MPQArchive.open(String path, int priority, int flags) {
    final mpqName = path.toNativeUtf8().cast<Char>();

    final int ret =
        _bindings.SFileOpenArchive(mpqName, priority, flags, _handle);
    malloc.free(mpqName);

    if (ret == 0) {
      int error = _bindings.GetLastError();
      throw StormLibException(
          error, 'SFileOpenArchive failed with error $error');
    }
  }

  /// Opens or creates the MPQ archive. The function can also convert an existing file to MPQ archive.
  /// The MPQ archive is always open for write operations.
  MPQArchive.create(String name, int flags, int maxFileCount) {
    final mpqName = name.toNativeUtf8().cast<Char>();

    final int ret =
        _bindings.SFileCreateArchive(mpqName, flags, maxFileCount, _handle);
    malloc.free(mpqName);

    if (ret == 0) {
      int error = _bindings.GetLastError();
      throw StormLibException(
          error, 'SFileCreateArchive failed with error $error');
    }
  }

  /// Closes the MPQ archive. All in-memory data are freed and also any unsaved MPQ tables are saved to the archive.
  /// After this function finishes, the Archive object is no longer valid and may not be used in any MPQ operations.
  void close() {
    _bindings.SFileCloseArchive(_handle.value);
    calloc.free(_handle);
  }

  /// Searches the MPQ archive and returns name of the first file that matches the given search mask and exists in the MPQ archive.
  /// When the caller finishes searching, the given find file handle must be freed by calling close().
  void findFirstFile(String searchMask, FindFileHandle findFileHandle,
      String? additionalListFile) {
    final szMask = searchMask.toNativeUtf8().cast<Char>();
    final szListFile = additionalListFile != null
        ? additionalListFile.toNativeUtf8().cast<Char>()
        : nullptr;

    HANDLE ret = _bindings.SFileFindFirstFile(
        _handle.value, szMask, findFileHandle._data, szListFile);

    // free the memory
    malloc.free(szMask);
    if (szListFile != nullptr) {
      malloc.free(szListFile);
    }

    if (ret == nullptr) {
      int error = _bindings.GetLastError();
      throw StormLibException(
          error, 'SFileFindFirstFile failed with error $error');
    }

    findFileHandle._handle = ret;
  }

  /// Continues search that has been initiated by findFirstFile.
  /// When the caller finishes searching, the referenced file handle must be freed by calling close.
  void findNextFile(FindFileHandle findFileHandle) {
    final ret = _bindings.SFileFindNextFile(
        findFileHandle._handle, findFileHandle._data);

    if (ret == 0) {
      int error = _bindings.GetLastError();
      throw StormLibException(
          error, 'SFileFindNextFile failed with error $error');
    }
  }

  /// Creates a new file within archive and prepares it for storing the data.
  MPQFile createFile(
      String name, int fileTime, int fileSize, int locale, int flags) {
    final szFileName = name.toNativeUtf8().cast<Char>();
    MPQFile file = MPQFile();

    final ret = _bindings.SFileCreateFile(_handle.value, szFileName, fileTime,
        fileSize, locale, flags, file._handle);

    malloc.free(szFileName);

    if (ret == 0) {
      int error = _bindings.GetLastError();
      throw StormLibException(
          error, 'SFileCreateFile failed with error $error');
    }

    return file;
  }
}

const String _libName = 'storm';
const String _libVersion = '9.22.0';
/// The dynamic library in which the symbols for [FlutterStormBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so.$_libVersion');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final FlutterStormBindings _bindings = FlutterStormBindings(_dylib);

// Helper extensions

extension FileFindData on SFILE_FIND_DATA {
  Iterable<int> spreadCFileName() sync* {
    for (var i = 0; i < 1024; i++) {
      final value = cFileName[i];
      if (value == 0) {
        return;
      }

      yield value;
    }
  }
}
