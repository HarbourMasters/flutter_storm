import 'dart:ffi' as ffi;
import 'flutter_storm_types.dart';

/// Structure for SFileFindFirstFile and SFileFindNextFile
typedef SFILE_FIND_DATA = _SFILE_FIND_DATA;

class _SFILE_FIND_DATA extends ffi.Struct {
  @ffi.Array.multi([1024])
  external ffi.Array<ffi.UnsignedChar> cFileName;

  /// Plain name of the found file
  external ffi.Pointer<ffi.UnsignedChar> szPlainName;

  /// Hash table index for the file (HAH_ENTRY_FREE if no hash table)
  @DWORD()
  external int dwHashIndex;

  /// Block table index for the file
  @DWORD()
  external int dwBlockIndex;

  /// File size in bytes
  @DWORD()
  external int dwFileSize;

  /// MPQ file flags
  @DWORD()
  external int dwFileFlags;

  /// Compressed file size
  @DWORD()
  external int dwCompSize;

  /// Low 32-bits of the file time (0 if not present)
  @DWORD()
  external int dwFileTimeLo;

  /// High 32-bits of the file time (0 if not present)
  @DWORD()
  external int dwFileTimeHi;

  /// Compound of file locale (16 bits) and platform (8 bits)
  @LCID()
  external int lcLocale;
}
