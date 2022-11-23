
import 'flutter_storm_platform_interface.dart';

const int MPQ_CREATE_LISTFILE       =  0x00100000;  // Also add the (listfile) file
const int MPQ_CREATE_ATTRIBUTES     =  0x00200000;  // Also add the (attributes) file
const int MPQ_CREATE_SIGNATURE      =  0x00400000;  // Also add the (signature) file
const int MPQ_CREATE_ARCHIVE_V1     =  0x00000000;  // Creates archive of version 1 (size up to 4GB)
const int MPQ_CREATE_ARCHIVE_V2     =  0x01000000;  // Creates archive of version 2 (larger than 4 GB)
const int MPQ_CREATE_ARCHIVE_V3     =  0x02000000;  // Creates archive of version 3
const int MPQ_CREATE_ARCHIVE_V4     =  0x03000000;  // Creates archive of version 4
const int MPQ_CREATE_ARCHIVE_VMASK  =  0x0F000000;  // Mask for archive version

class FlutterStorm {

}
