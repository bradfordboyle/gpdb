# src/test/modules/Makefile

subdir = src/test/modules
top_builddir = ../../..
include $(top_builddir)/src/Makefile.global

SUBDIRS = \
		  commit_ts \
		  dummy_seclabel \
		  test_ddl_deparse \
		  test_parser \
		  test_rls_hooks \
		  test_shm_mq \
		  worker_spi

# GPDB subdirs
SUBDIRS += test_planner

all: submake-errcodes

submake-errcodes:
	$(MAKE) -C $(top_builddir)/src/backend submake-errcodes

$(recurse)
