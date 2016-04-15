#
# Copyright (C) 2015  hedede <haddayn@gmail.com>
#
# License LGPLv3 or later:
# GNU Lesser GPL version 3 <http://gnu.org/licenses/lgpl-3.0.html>
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
#
sharedlib_prefix = lib
sharedlib_suffix = .so
sharedlib_versioning = true

staticlib_prefix = lib
staticlib_suffix = .a
staticlib_versioning = true

executable_prefix =
executable_suffix =
executable_versioning = false

cpp_debug   = -DDEBUG -D_DEBUG
cpp_nodebug = -DNDEBUG

cxx_no_exceptions = -fno-exceptions
cxx_no_rtti       = -fno-rtti

cxx_std = -std=c++14
cc_std  = -std=c11

linker_relpath = -Wl,-R,'$$ORIGIN/../lib'
linker_libpath = -Wl,-rpath-link,$(RootPath)/lib -L$(RootPath)/lib

compiler_debugsyms = -g

compiler_optimize_full  = -O3
compiler_optimize_debug = -Og

compiler_visibility_hidden = -fvisibility=hidden
compiler_visibility_public = -fvisibility=default
compiler_general = -fdiagnostics-color=auto -fPIC

make_depends = -MMD -MP

define_prefix  = -D
library_prefix = -l
libpath_prefix = -L
include_preifx = -i
incpath_prefix = -I

# Tools
MKDIR_P = mkdir -p
ECHO    = @echo
RM_F    = rm -f

# Colors
PRINTF = @printf
PRINTF_BOLD =$(PRINTF) '\033[1m'
PRINTF_RED  =$(PRINTF) '\033[31m'
PRINTF_RESET=$(PRINTF) '\033[0m'
