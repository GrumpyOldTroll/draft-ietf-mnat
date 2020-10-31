LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
#	cp -r ../i-d-template $(LIBDIR)
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b yang-support https://github.com/GrumpyOldTroll/i-d-template $(LIBDIR)
endif
