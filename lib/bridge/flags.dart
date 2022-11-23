// MPQ Flags that needs to be implemented

const int MPQ_CREATE_LISTFILE       =  0x00100000;  // Also add the (listfile) file
const int MPQ_CREATE_ATTRIBUTES     =  0x00200000;  // Also add the (attributes) file
const int MPQ_CREATE_SIGNATURE      =  0x00400000;  // Also add the (signature) file
const int MPQ_CREATE_ARCHIVE_V1     =  0x00000000;  // Creates archive of version 1 (size up to 4GB)
const int MPQ_CREATE_ARCHIVE_V2     =  0x01000000;  // Creates archive of version 2 (larger than 4 GB)
const int MPQ_CREATE_ARCHIVE_V3     =  0x02000000;  // Creates archive of version 3
const int MPQ_CREATE_ARCHIVE_V4     =  0x03000000;  // Creates archive of version 4
const int MPQ_CREATE_ARCHIVE_VMASK  =  0x0F000000;  // Mask for archive version

const int MPQ_FILE_IMPLODE          = 0x00000100;  // Implode method (By PKWARE Data Compression Library)
const int MPQ_FILE_COMPRESS         = 0x00000200;  // Compress methods (By multiple methods)
const int MPQ_FILE_ENCRYPTED        = 0x00010000;  // Indicates whether file is encrypted
const int MPQ_FILE_FIX_KEY          = 0x00020000;  // File decryption key has to be fixed
const int MPQ_FILE_PATCH_FILE       = 0x00100000;  // The file is a patch file. Raw file data begin with TPatchInfo structure
const int MPQ_FILE_SINGLE_UNIT      = 0x01000000;  // File is stored as a single unit, rather than split into sectors (Thx, Quantam)
const int MPQ_FILE_DELETE_MARKER    = 0x02000000;  // File is a deletion marker. Used in MPQ patches, indicating that the file no longer exists.
const int MPQ_FILE_SECTOR_CRC       = 0x04000000;  // File has checksums for each sector.
const int MPQ_FILE_SIGNATURE        = 0x10000000;  // Present on STANDARD.SNP\(signature). The only occurence ever observed
const int MPQ_FILE_EXISTS           = 0x80000000;  // Set if file exists, reset when the file was deleted
const int MPQ_FILE_REPLACEEXISTING  = 0x80000000;  // Replace when the file exist (SFileAddFile)
const int MPQ_FILE_COMPRESS_MASK    = 0x0000FF00;  // Mask for a file being compressed
const int MPQ_FILE_DEFAULT_INTERNAL = 0xFFFFFFFF;  // Default flags for internal files

// Compression types for multiple compressions
const int MPQ_COMPRESSION_HUFFMANN         = 0x01;  // Huffmann compression (used on WAVE files only)
const int MPQ_COMPRESSION_ZLIB             = 0x02;  // ZLIB compression
const int MPQ_COMPRESSION_PKWARE           = 0x08;  // PKWARE DCL compression
const int MPQ_COMPRESSION_BZIP2            = 0x10;  // BZIP2 compression (added in Warcraft III)
const int MPQ_COMPRESSION_SPARSE           = 0x20;  // Sparse compression (added in Starcraft 2)
const int MPQ_COMPRESSION_ADPCM_MONO       = 0x40;  // IMA ADPCM compression (mono)
const int MPQ_COMPRESSION_ADPCM_STEREO     = 0x80;  // IMA ADPCM compression (stereo)
const int MPQ_COMPRESSION_LZMA             = 0x12;  // LZMA compression. Added in Starcraft 2. This value is NOT a combination of flags.
