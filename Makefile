#------------------------------------------------------------------------------
#
#  Osmium main makefile
#
#------------------------------------------------------------------------------

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifeq ($(uname_S),Linux)
    ROOT_GROUP = root
    ROOT_USER = root
endif
ifeq ($(uname_S),GNU/kFreeBSD)
    ROOT_GROUP = root
    ROOT_USER = root
endif
ifeq ($(uname_S),Darwin)
    ROOT_GROUP = wheel
    ROOT_USER = root
endif

all:

clean:
	rm -fr doc/html

install: doc
	install -m 755 -g $(ROOT_GROUP) -o $(ROOT_USER) -d $(DESTDIR)/usr/include
	install -m 755 -g $(ROOT_GROUP) -o $(ROOT_USER) -d $(DESTDIR)/usr/share/doc/libosmium-dev
	install -m 644 -g $(ROOT_GROUP) -o $(ROOT_USER) README $(DESTDIR)/usr/share/doc/libosmium-dev/README
	install -m 644 -g $(ROOT_GROUP) -o $(ROOT_USER) include/osmium.hpp $(DESTDIR)/usr/include
	cp -r include/osmium $(DESTDIR)/usr/include
	cp -r doc/html $(DESTDIR)/usr/share/doc/libosmium-dev

check:
	cppcheck --enable=all -I include */*.cpp test/*/test_*.cpp

# This will try to compile each include file on its own to detect missing
# #include directives. Note that if this reports [OK], it is not enough
# to be sure it will compile in production code. But if it reports [FAILED]
# we know we are missing something.
check-includes:
	echo "check includes report:" >check-includes-report; \
	for FILE in include/*.hpp include/*/*.hpp include/*/*/*.hpp include/*/*/*/*.hpp; do \
        echo "$${FILE}:" >>check-includes-report; \
        echo -n "$${FILE} "; \
        if `g++ -I include $${FILE} 2>>check-includes-report`; then \
            echo "[OK]"; \
        else \
            echo "[FAILED]"; \
        fi; \
        rm -f $${FILE}.gch; \
	done

indent:
	astyle --style=java --indent-namespaces --indent-switches --pad-header --suffix=none --recursive include/\*.hpp examples/\*.cpp examples/\*.hpp osmjs/\*.cpp test/\*.cpp

doc: doc/html/files.html

doc/html/files.html: include/*.hpp include/*/*.hpp include/*/*/*.hpp
	doxygen >/dev/null

deb:
	debuild -I -us -uc

deb-clean:
	debuild clean

