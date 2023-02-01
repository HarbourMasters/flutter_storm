import 'dart:ffi' as ffi;

typedef HANDLE = ffi.Pointer<ffi.Void>;
typedef TCHAR = ffi.NativeType;

typedef DWORD = ffi.UnsignedInt;

typedef LCID = ffi.UnsignedInt;

typedef LPDWORD = ffi.Pointer<DWORD>;
typedef LPOVERLAPPED = ffi.Pointer<ffi.Void>;

typedef ULONGLONG = ffi.UnsignedLongLong;
