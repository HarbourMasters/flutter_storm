// ignore_for_file: constant_identifier_names

enum StormError {
  ERROR_UNKNOWN                (-1),
  ERROR_SUCCESS                (0x0),
  ERROR_FILE_NOT_FOUND         (0x2),
  ERROR_ACCESS_DENIED          (0x1),
  ERROR_INVALID_HANDLE         (0x9),
  ERROR_NOT_ENOUGH_MEMORY      (0xC),
  ERROR_NOT_SUPPORTED          (0x86),
  ERROR_INVALID_PARAMETER      (0x16),
  ERROR_NEGATIVE_SEEK          (0x1D),
  ERROR_DISK_FULL              (0x1C),
  ERROR_ALREADY_EXISTS         (0x11),
  ERROR_INSUFFICIENT_BUFFER    (0x69),
  ERROR_BAD_FORMAT             (0x3E8),
  ERROR_NO_MORE_FILES          (0x3E9),
  ERROR_HANDLE_EOF             (0x3EA),
  ERROR_CAN_NOT_COMPLETE       (0x3EB),
  ERROR_FILE_CORRUPT           (0x3EC),
  ERROR_AVI_FILE               (0x2710),
  ERROR_UNKNOWN_FILE_KEY       (0x2711),
  ERROR_CHECKSUM_ERROR         (0x2712),
  ERROR_INTERNAL_FILE          (0x2713),
  ERROR_BASE_FILE_MISSING      (0x2714),
  ERROR_MARKED_FOR_DELETE      (0x2715),
  ERROR_FILE_INCOMPLETE        (0x2716),
  ERROR_UNKNOWN_FILE_NAMES     (0x2717),
  ERROR_CANT_FIND_PATCH_PREFIX (0x2718),
  ERROR_FAKE_MPQ_HEADER        (0x2719),
  ERROR_FAILED_TO_OPEN_MPQ     (0x20);

  final num error;

  const StormError(this.error);
}

class StormException implements Exception {

  final String message;
  final StormError error;

  StormException({
    required this.message,
    required this.error,
  });

  @override
  String toString() {
    return 'StormException: ${error.name}';
  }
}