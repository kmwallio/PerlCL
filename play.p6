#!/usr/bin/env perl6
use v6;
use NativeCall;


constant LIB = ($*DISTRO.name eq 'macosx') ?? './OpenCL' !! 'OpenCL';

constant cl_int = int32;
constant cl_uint = uint32;
constant cl_char = int8;
constant cl_uchar = uint8;
constant cl_short = int16;
constant cl_ushort = uint16;
constant cl_float = num32;

constant cl_platform_id = int32;
constant cl_device_id = uint64;
constant cl_device_info = uint32;
constant cl_device_type = uint32;
constant cl_context_properties = Pointer;
constant cl_program = uint64;

constant cl_context = Pointer[void];

# CL Device Types
constant CL_DEVICE_TYPE_DEFAULT = (1 +< 0);
constant CL_DEVICE_TYPE_CPU = (1 +< 1);
constant CL_DEVICE_TYPE_GPU = (1 +< 2);
constant CL_DEVICE_TYPE_ACCELERATOR = (1 +< 3);
constant CL_DEVICE_TYPE_CUSTOM = (1 +< 4);
constant CL_DEVICE_TYPE_ALL = 0xFFFFFFFF;

# CL Context Properties
constant CL_CONTEXT_PLATFORM = 0x1084;
constant CL_CONTEXT_INTEROP_USER_SYNC = 0x1085;

# CL Error Codes
constant CL_SUCCESS = 0;
constant CL_DEVICE_NOT_FOUND = -1;
constant CL_DEVICE_NOT_AVAILABLE = -2;
constant CL_COMPILER_NOT_AVAILABLE = -3;
constant CL_MEM_OBJECT_ALLOCATION_FAILURE = -4;
constant CL_OUT_OF_RESOURCES = -5;
constant CL_OUT_OF_HOST_MEMORY = -6;
constant CL_PROFILING_INFO_NOT_AVAILABLE = -7;
constant CL_MEM_COPY_OVERLAP = -8;
constant CL_IMAGE_FORMAT_MISMATCH = -9;
constant CL_IMAGE_FORMAT_NOT_SUPPORTED = -10;
constant CL_BUILD_PROGRAM_FAILURE = -11;
constant CL_MAP_FAILURE = -12;
constant CL_MISALIGNED_SUB_BUFFER_OFFSET = -13;
constant CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST = -14;
constant CL_COMPILE_PROGRAM_FAILURE = -15;
constant CL_LINKER_NOT_AVAILABLE = -16;
constant CL_LINK_PROGRAM_FAILURE = -17;
constant CL_DEVICE_PARTITION_FAILED = -18;
constant CL_KERNEL_ARG_INFO_NOT_AVAILABLE = -19;

constant CL_INVALID_VALUE = -30;
constant CL_INVALID_DEVICE_TYPE = -31;
constant CL_INVALID_PLATFORM = -32;
constant CL_INVALID_DEVICE = -33;
constant CL_INVALID_CONTEXT = -34;
constant CL_INVALID_QUEUE_PROPERTIES = -35;
constant CL_INVALID_COMMAND_QUEUE = -36;
constant CL_INVALID_HOST_PTR = -37;
constant CL_INVALID_MEM_OBJECT = -38;
constant CL_INVALID_IMAGE_FORMAT_DESCRIPTOR = -39;
constant CL_INVALID_IMAGE_SIZE = -40;
constant CL_INVALID_SAMPLER = -41;
constant CL_INVALID_BINARY = -42;
constant CL_INVALID_BUILD_OPTIONS = -43;
constant CL_INVALID_PROGRAM = -44;
constant CL_INVALID_PROGRAM_EXECUTABLE = -45;
constant CL_INVALID_KERNEL_NAME = -46;
constant CL_INVALID_KERNEL_DEFINITION = -47;
constant CL_INVALID_KERNEL = -48;
constant CL_INVALID_ARG_INDEX = -49;
constant CL_INVALID_ARG_VALUE = -50;
constant CL_INVALID_ARG_SIZE = -51;
constant CL_INVALID_KERNEL_ARGS = -52;
constant CL_INVALID_WORK_DIMENSION = -53;
constant CL_INVALID_WORK_GROUP_SIZE = -54;
constant CL_INVALID_WORK_ITEM_SIZE = -55;
constant CL_INVALID_GLOBAL_OFFSET = -56;
constant CL_INVALID_EVENT_WAIT_LIST = -57;
constant CL_INVALID_EVENT = -58;
constant CL_INVALID_OPERATION = -59;
constant CL_INVALID_GL_OBJECT = -60;
constant CL_INVALID_BUFFER_SIZE = -61;
constant CL_INVALID_MIP_LEVEL = -62;
constant CL_INVALID_GLOBAL_WORK_SIZE = -63;
constant CL_INVALID_PROPERTY = -64;
constant CL_INVALID_IMAGE_DESCRIPTOR = -65;
constant CL_INVALID_COMPILER_OPTIONS = -66;
constant CL_INVALID_LINKER_OPTIONS = -67;
constant CL_INVALID_DEVICE_PARTITION_COUNT = -68;
constant CL_INVALID_PIPE_SIZE = -69;
constant CL_INVALID_DEVICE_QUEUE = -70;

sub clGetPlatformIDs(cl_uint, cl_platform_id is rw, cl_uint is rw) returns cl_int is native(LIB) { * }

sub clGetDeviceIDs(cl_platform_id, cl_device_type, cl_uint, CArray[cl_device_id], cl_uint is rw) returns cl_int is native(LIB) { * }

sub clGetDeviceInfo(CArray[cl_device_id], cl_device_info, size_t, Pointer[void], size_t is rw) returns cl_int is native(LIB) { * }

# callback(Str, Pointer[void], size_t, Pointer[void])
sub clCreateContext(cl_context_properties, cl_uint, CArray[cl_device_id], &callback (Str, Pointer[void], size_t, Pointer[void]), Pointer[void], cl_int is rw) returns cl_context is native(LIB) { * }
sub no-handle(Str $err-info, Pointer[void] $private-info, size_t $cb, Pointer[void] $user-data) {
  say $err-info;
}

sub clCreateProgramWithSource(cl_context, cl_uint, CArray[Str], CArray[size_t], cl_int is rw) returns cl_program is native(LIB) { * };

sub clBuildProgram(cl_program, cl_uint, CArray[cl_device_id], Str, &callback (cl_program, Pointer[void]), Pointer[void]) returns cl_int is native(LIB) { * };

sub MAIN() {
  my cl_uint $type = 1;
  my cl_platform_id $id = 0;
  my cl_uint $number-of-entries = 0;

  my $device-id := CArray[cl_device_id].new();
  $device-id[0] = 0;
  my cl_uint $num-of-devices = 0;

  my cl_context $device-context;
  my cl_int $err-code;

  my cl_program $program;
  my @program-source := CArray[Str].new();
  @program-source[0] = q:to/END/;
  __kernel void add_numbers(__global float4* data,
        __local float* local_result, __global float* group_result) {

     float sum;
     float4 input1, input2, sum_vector;
     uint global_addr, local_addr;

     global_addr = get_global_id(0) * 2;
     input1 = data[global_addr];
     input2 = data[global_addr+1];
     sum_vector = input1 + input2;

     local_addr = get_local_id(0);
     local_result[local_addr] = sum_vector.s0 + sum_vector.s1 +
                                sum_vector.s2 + sum_vector.s3;
     barrier(CLK_LOCAL_MEM_FENCE);

     if(get_local_id(0) == 0) {
        sum = 0.0f;
        for(int i=0; i<get_local_size(0); i++) {
           sum += local_result[i];
        }
        group_result[get_group_id(0)] = sum;
     }
  }
  END
  my @program-lengths := CArray[size_t].new();
  @program-lengths[0] = @program-source[0].chars;
  my cl_uint $program-lines = 1;

  # Get a device
  say "Query devices: " ~ (CL_SUCCESS == clGetPlatformIDs($type, $id, $number-of-entries));
  say "Number of OpenCL Devices: " ~ $number-of-entries;
  say "Select Graphics Card: " ~ (CL_SUCCESS == clGetDeviceIDs($id, CL_DEVICE_TYPE_GPU, 1, $device-id, $num-of-devices));
  say "Got " ~ $num-of-devices ~ " graphics card(s)";

  # Create a context.
  $device-context = clCreateContext(cl_context_properties, $num-of-devices, $device-id, Code, Pointer, $err-code);
  say "Context created: " ~ ($err-code == CL_SUCCESS);

  # Create the program
  $program = clCreateProgramWithSource($device-context, $program-lines, @program-source, @program-lengths, $err-code);
  say "Program created: " ~ ($err-code == CL_SUCCESS);

  $err-code = clBuildProgram($program, 0, CArray[cl_device_id], Str, Code, Pointer);
  say "Program compiled: " ~ ($err-code == CL_SUCCESS);
  say $err-code;
}
