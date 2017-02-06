ifeq ($(RTE_SDK),)
$(error "Please define RTE_SDK environment variable")
endif
ifeq ($(RTE_TARGET),)
$(error "Please define RTE_TARGET environment variable")
endif

# This file more or less copies rte.app.sdk, but we cannot use directly DPDK's one because its heavy modifications on the compile variables would break Click build process

# Save C flags
DPDK_OLD_CFLAGS := $(CFLAGS)
DPDK_OLD_CXXFLAGS := $(CXXFLAGS)
DPDK_OLD_LDFLAGS := $(LDFLAGS)

include $(RTE_SDK)/mk/rte.vars.mk

DPDK_INCLUDE=$(RTE_SDK)/include

# default path for libs
_LDLIBS-y += -L$(RTE_SDK_BIN)/lib

#
# Order is important: from higher level to lower level
#

# Link only the libraries used in the application
LDFLAGS += --as-needed

_LDLIBS-y += -Wl,--whole-archive

_LDLIBS-$(CONFIG_RTE_BUILD_COMBINE_LIBS)    += -lintel_dpdk

_LDLIBS-y += $(EXECENV_LDLIBS)
_LDLIBS-y += -Wl,--no-whole-archive

DPDK_LIB=$(_LDLIBS-y) $(CPU_LDLIBS) $(EXTRA_LDLIBS)

# Eliminate duplicates without sorting
DPDK_LIB := $(shell echo $(DPDK_LIB) | \
    awk '{for (i = 1; i <= NF; i++) { if (!seen[$$i]++) print $$i }}')


RTE_SDK_FULL=`readlink -f $RTE_SDK`

CFLAGS += -I$(DPDK_INCLUDE)

# Merge and rename flags
CXXFLAGS := $(CXXFLAGS) $(CFLAGS) $(EXTRA_CFLAGS)

include $(RTE_SDK)/mk/internal/rte.build-pre.mk


override LDFLAGS := $(DPDK_OLD_LDFLAGS) $(DPDK_LIB)
