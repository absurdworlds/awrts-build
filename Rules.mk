#
# Copyright (C) 2015  hedede <haddayn@gmail.com>
#
# License LGPLv3 or later:
# GNU Lesser GPL version 3 <http://gnu.org/licenses/lgpl-3.0.html>
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# All project makefiles must define:
# ProjectName
# RootPath
# Objects
# Executable

# Global configuration
Version = 0

EXTRAFLAGS=

# Makefile tricks
comma = ,
space :=
space +=

# User configuration
include $(RootPath)/Config.mk

ifndef CONFIG_TOOLCHAIN

CONFIG_TOOLCHAIN = default

endif

include $(RootPath)/toolchain-$(CONFIG_TOOLCHAIN).mk

ifeq      ($(BuildType),executable)
	InstallDir = $(RootPath)/bin
	NamePrefix = $(executable_prefix)
	NameSuffix = $(executable_suffix)
	Versioning = $(executable_versioning)
else ifeq ($(BuildType),sharedlib)
	InstallDir = $(RootPath)/lib
	NamePrefix = $(sharedlib_prefix)
	NameSuffix = $(sharedlib_suffix)
	Versioning = $(sharedlib_versioning)
	EXTRAFLAGS += -shared
else ifeq ($(BuildType),staticlib)
	InstallDir = $(RootPath)/lib
	NamePrefix = $(staticlib_prefix)
	NameSuffix = $(staticlib_suffix)
	Versioning = $(staticlib_versioning)
	EXTRAFLAGS += -static
else
$(error BuildType is incorrect or not defined.)
endif

ifeq ($(Versioning),true)
	OutputName = $(NamePrefix)$(ProjectName)$(NameSuffix).$(Version)
	OutputShortName = $(NamePrefix)$(ProjectName)$(NameSuffix)
else
	OutputName = $(NamePrefix)$(ProjectName)$(NameSuffix)
endif

# Process config
BuildDir = $(RootPath)/build/$(ProjectName)
Includes = -I$(RootPath)/include
Objects = $(patsubst %.cpp, $(BuildDir)/%.o, $(Sources))
Depends = $(Objects:.o=.d)
ProjectDefines      = $(addprefix $(define_prefix),$(Defines))
ProjectDependencies = $(addprefix $(libpath_prefix),$(Libraries))

ExtraIncludePaths = $(addprefix $(incpath_prefix),$(CONFIG_INCLUDE_PATHS))
ExtraLibraryPaths = $(addprefix $(libpath_prefix),$(CONFIG_LIBRARY_PATHS))
ExtraIncludePaths+= $(addprefix $(incpath_prefix)$(RootPath)/,$(CONFIG_INCLUDE_REL_PATHS))
ExtraLibraryPaths+= $(addprefix $(libpath_prefix)$(RootPath)/,$(CONFIG_LIBRARY_REL_PATHS))

# Tool configuration
cxx_flags  = $(compiler_general) $(compiler_debugsyms) $(cxx_std)
cxx_flags += $(cxx_no_exceptions)
cxx_flags += $(compiler_visibility_public)
cxx_flags_debug   = $(cpp_debug)
cxx_flags_release = $(compiler_optimize_full) $(cpp_nodebug)

cc_flags  = $(compiler_general) $(cc_std)
cpp_flags = $(ProjectDefines) $(Includes) $(ExtraIncludePaths)

linker_flags  = $(linker_relpath) $(linker_libpath)
linker_flags += $(ExtraLibraryPaths)
linker_flags += $(ProjectDependencies)

# Generate dependency files
ifeq ($(CONFIG_MAKE_DEPENDS),true)
cc_flags  += $(make_depends)
cxx_flags += $(make_depends)
endif

# Build rules
all: debug

.PHONY: debug
debug: cxx_flags+=$(cxx_flags_debug)
debug: Build Install

.PHONY: release
release: cxx_flags+=$(cxx_flags_release)
release: Build Install


$(BuildDir)/%.o: %.cpp
	$(PRINTF_BOLD)
	$(ECHO) [Build] Compiling $@
	$(PRINTF_RESET)
	@ $(MKDIR_P) $(dir $@)
	@ $(CXX) $(cpp_flags) $(cxx_flags) -c $< -o $@

Build: $(Objects)
	@ $(MKDIR_P) $(BuildDir)
	$(PRINTF_BOLD)
	$(ECHO) [Build] Linking object files.
	$(PRINTF_RESET)
	@ $(CXX) $(EXTRAFLAGS) -o $(BuildDir)/$(OutputName) \
	$(cpp_flags) $(cxx_flags) $(Objects) $(ld_flags)
	$(PRINTF_BOLD)
	$(ECHO) [Build] Done.
	$(PRINTF_RESET)

Install: Build
	$(PRINTF_BOLD)
	$(ECHO) [Install] Copying $(OutputName)
	$(PRINTF_RESET)
	@ $(MKDIR_P) $(InstallDir)
	@ cp $(BuildDir)/$(OutputName) $(InstallDir)/$(OutputName)
ifeq ($(Versioning),true)
	$(PRINTF_BOLD)
	$(ECHO) [Install] Creating symlink $(OutputShortName) to $(OutputName).
	$(PRINTF_RESET)
	@ ln -sf $(OutputName) $(InstallDir)/$(OutputShortName)
endif
	$(PRINTF_BOLD)
	$(ECHO) [Install] Done.
	$(PRINTF_RESET)

.PHONY : clean
clean: 
	$(PRINTF_BOLD)
	$(ECHO) [Clean] Removing build files
	$(PRINTF_RESET)
	@ rm -f $(Objects) $(BuildDir)/$(OutputName)
	$(PRINTF_BOLD)
	$(ECHO) [Clean] Done.
	$(PRINTF_RESET)

ifeq ($(CONFIG_MAKE_DEPENDS),true)
-include $(Depends)
endif
