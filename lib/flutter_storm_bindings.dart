import 'dart:ffi' as ffi;
import 'dart:io';
import 'flutter_storm_types.dart';
import 'flutter_storm_structs.dart';

class FlutterStormBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  FlutterStormBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  FlutterStormBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// -----------------------------------------------------------------------------
  /// Functions for archive manipulation
  bool SFileOpenArchive(
    ffi.Pointer<TCHAR> szMpqName,
    int dwPriority,
    int dwFlags,
    ffi.Pointer<HANDLE> phMpq,
  ) {
    return _SFileOpenArchive(
      szMpqName,
      dwPriority,
      dwFlags,
      phMpq,
    );
  }

  late final _SFileOpenArchivePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TCHAR>, DWORD, DWORD,
              ffi.Pointer<HANDLE>)>>('SFileOpenArchive');
  late final _SFileOpenArchive = _SFileOpenArchivePtr.asFunction<
      bool Function(ffi.Pointer<TCHAR>, int, int, ffi.Pointer<HANDLE>)>();

  bool SFileCreateArchive(
    ffi.Pointer<TCHAR> szMpqName,
    int dwCreateFlags,
    int dwMaxFileCount,
    ffi.Pointer<HANDLE> phMpq,
  ) {
    return _SFileCreateArchive(
      szMpqName,
      dwCreateFlags,
      dwMaxFileCount,
      phMpq,
    );
  }

  late final _SFileCreateArchivePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TCHAR>, DWORD, DWORD,
              ffi.Pointer<HANDLE>)>>('SFileCreateArchive');
  late final _SFileCreateArchive = _SFileCreateArchivePtr.asFunction<
      bool Function(ffi.Pointer<TCHAR>, int, int, ffi.Pointer<HANDLE>)>();

  bool SFileCloseArchive(
    HANDLE hMpq,
  ) {
    return _SFileCloseArchive(
      hMpq,
    );
  }

  late final _SFileCloseArchivePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(HANDLE)>>(
          'SFileCloseArchive');
  late final _SFileCloseArchive =
      _SFileCloseArchivePtr.asFunction<bool Function(HANDLE)>();

  /// -----------------------------------------------------------------------------
  /// Functions for file searching
  HANDLE SFileFindFirstFile(
    HANDLE hMpq,
    ffi.Pointer<TCHAR> szMask,
    ffi.Pointer<SFILE_FIND_DATA> lpFindFileData,
    ffi.Pointer<TCHAR> szListFile,
  ) {
    return _SFileFindFirstFile(
      hMpq,
      szMask,
      lpFindFileData,
      szListFile,
    );
  }

  late final _SFileFindFirstFilePtr = _lookup<
      ffi.NativeFunction<
          HANDLE Function(
              HANDLE,
              ffi.Pointer<TCHAR>,
              ffi.Pointer<SFILE_FIND_DATA>,
              ffi.Pointer<TCHAR>)>>('SFileFindFirstFile');
  late final _SFileFindFirstFile = _SFileFindFirstFilePtr.asFunction<
      HANDLE Function(HANDLE, ffi.Pointer<TCHAR>, ffi.Pointer<SFILE_FIND_DATA>,
          ffi.Pointer<TCHAR>)>();

  bool SFileFindNextFile(
    HANDLE hFind,
    ffi.Pointer<SFILE_FIND_DATA> lpFindFileData,
  ) {
    return _SFileFindNextFile(
      hFind,
      lpFindFileData,
    );
  }

  late final _SFileFindNextFilePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              HANDLE, ffi.Pointer<SFILE_FIND_DATA>)>>('SFileFindNextFile');
  late final _SFileFindNextFile = _SFileFindNextFilePtr.asFunction<
      bool Function(HANDLE, ffi.Pointer<SFILE_FIND_DATA>)>();

  bool SFileFindClose(
    HANDLE hFind,
  ) {
    return _SFileFindClose(
      hFind,
    );
  }

  late final _SFileFindClosePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(HANDLE)>>('SFileFindClose');
  late final _SFileFindClose =
      _SFileFindClosePtr.asFunction<bool Function(HANDLE)>();

  /// -----------------------------------------------------------------------------
  /// Support for adding files to the MPQ
  bool SFileCreateFile(
    HANDLE hMpq,
    ffi.Pointer<TCHAR> szArchivedName,
    int FileTime,
    int dwFileSize,
    int lcFileLocale,
    int dwFlags,
    ffi.Pointer<HANDLE> phFile,
  ) {
    return _SFileCreateFile(
      hMpq,
      szArchivedName,
      FileTime,
      dwFileSize,
      lcFileLocale,
      dwFlags,
      phFile,
    );
  }

  late final _SFileCreateFilePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(HANDLE, ffi.Pointer<TCHAR>, ULONGLONG, DWORD, LCID,
              DWORD, ffi.Pointer<HANDLE>)>>('SFileCreateFile');
  late final _SFileCreateFile = _SFileCreateFilePtr.asFunction<
      bool Function(HANDLE, ffi.Pointer<TCHAR>, int, int, int, int,
          ffi.Pointer<HANDLE>)>();

  bool SFileWriteFile(
    HANDLE hFile,
    ffi.Pointer<ffi.Void> pvData,
    int dwSize,
    int dwCompression,
  ) {
    return _SFileWriteFile(
      hFile,
      pvData,
      dwSize,
      dwCompression,
    );
  }

  late final _SFileWriteFilePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              HANDLE, ffi.Pointer<ffi.Void>, DWORD, DWORD)>>('SFileWriteFile');
  late final _SFileWriteFile = _SFileWriteFilePtr.asFunction<
      bool Function(HANDLE, ffi.Pointer<ffi.Void>, int, int)>();

  int SFileFinishFile(
    HANDLE hFile,
  ) {
    return _SFileFinishFile(
      hFile,
    );
  }

  late final _SFileFinishFilePtr =
      _lookup<ffi.NativeFunction<ffi.Char Function(HANDLE)>>('SFileFinishFile');
  late final _SFileFinishFile =
      _SFileFinishFilePtr.asFunction<int Function(HANDLE)>();

  /// Reading from MPQ file
  bool SFileOpenFileEx(
    HANDLE hMpq,
    ffi.Pointer<TCHAR> szFileName,
    int dwSearchScope,
    ffi.Pointer<HANDLE> phFile,
  ) {
    return _SFileOpenFileEx(
      hMpq,
      szFileName,
      dwSearchScope,
      phFile,
    );
  }

  late final _SFileOpenFileExPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(HANDLE, ffi.Pointer<TCHAR>, DWORD,
              ffi.Pointer<HANDLE>)>>('SFileOpenFileEx');
  late final _SFileOpenFileEx = _SFileOpenFileExPtr.asFunction<
      bool Function(HANDLE, ffi.Pointer<TCHAR>, int, ffi.Pointer<HANDLE>)>();

  int SFileGetFileSize(
    HANDLE hFile,
    LPDWORD pdwFileSizeHigh,
  ) {
    return _SFileGetFileSize(
      hFile,
      pdwFileSizeHigh,
    );
  }

  late final _SFileGetFileSizePtr =
      _lookup<ffi.NativeFunction<DWORD Function(HANDLE, LPDWORD)>>(
          'SFileGetFileSize');
  late final _SFileGetFileSize =
      _SFileGetFileSizePtr.asFunction<int Function(HANDLE, LPDWORD)>();

  bool SFileReadFile(
    HANDLE hFile,
    ffi.Pointer<ffi.Void> lpBuffer,
    int dwToRead,
    LPDWORD pdwRead,
    LPOVERLAPPED lpOverlapped,
  ) {
    return _SFileReadFile(
      hFile,
      lpBuffer,
      dwToRead,
      pdwRead,
      lpOverlapped,
    );
  }

  late final _SFileReadFilePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(HANDLE, ffi.Pointer<ffi.Void>, DWORD, LPDWORD,
              LPOVERLAPPED)>>('SFileReadFile');
  late final _SFileReadFile = _SFileReadFilePtr.asFunction<
      bool Function(
          HANDLE, ffi.Pointer<ffi.Void>, int, LPDWORD, LPOVERLAPPED)>();

  bool SFileCloseFile(
    HANDLE hFile,
  ) {
    return _SFileCloseFile(
      hFile,
    );
  }

  late final _SFileCloseFilePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(HANDLE)>>('SFileCloseFile');
  late final _SFileCloseFile =
      _SFileCloseFilePtr.asFunction<bool Function(HANDLE)>();

  /// -----------------------------------------------------------------------------
  /// Utilities

  int GetLastError() {
    return _GetLastError();
  }

  late final _GetLastErrorPtr =
      _lookup<ffi.NativeFunction<DWORD Function()>>('GetLastError');
  late final _GetLastError = _GetLastErrorPtr.asFunction<int Function()>();
}
