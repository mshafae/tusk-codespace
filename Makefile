#
# Copyright 2023 Michael Shafae
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

TARGET = helloworld
# C++ Source Code Files
CXXFILES = helloworld.cc
# C++ Headers Files
HEADERS = 

DO_UNITTESTS = "False"

CXX = clang++
CXXFLAGS += -g -O3 -Wall -pedantic -pipe -std=c++17
LDFLAGS += -g -O3 -Wall -pedantic -pipe -std=c++17

CXXFLAGS += -D LINUX -nostdinc++ -I/usr/include/c++/11 -I/usr/include/x86_64-linux-gnu/c++/11
LDFLAGS += -L /usr/lib/gcc/x86_64-linux-gnu/11
SED = sed
GTESTINCLUDE = -D LINUX -nostdinc++ -I/usr/include/c++/11 -I/usr/include/x86_64-linux-gnu/c++/11
GTESTLIBS = -L /usr/lib/gcc/x86_64-linux-gnu/11 -lgtest -lgtest_main -lpthread

UNAME_M = $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	CXXFLAGS += -D AMD64
endif
ifneq ($(filter %86,$(UNAME_M)),)
	CXXFLAGS += -D IA32
endif
ifneq ($(filter arm%,$(UNAME_M)),)
	CXXFLAGS += -D ARM
endif

GTEST_OUTPUT_FORMAT ?= "json"
GTEST_OUTPUT_FILE ?= "test_detail.json"

DOXYGEN = doxygen
DOCDIR = doc

MAKEHEADERS := $(shell command -v makeheaders 2>/dev/null)

OBJECTS = $(CXXFILES:.cc=.o)

DEP = $(CXXFILES:.cc=.d)

.SILENT: doc lint format header test

default all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $(TARGET) $(OBJECTS) $(LLDLIBS)

-include $(DEP)

%.d: %.cc
	set -e; $(CXX) -MM $(CXXFLAGS) $<
	| sed 's/\($*\)\.o[ :]*/.o $@ : /g' > $@;
	[ -s $@ ] || rm -f $@

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $<

clean:
	-rm -f $(OBJECTS) core $(TARGET).core

spotless: clean cleanunittest
	-rm -f $(TARGET) $(DEP) a.out
	-rm -rf $(DOCDIR)
	-rm -rf $(TARGET).dSYM
	-rm -f compile_commands.json

doc: $(CXXFILES) $(HEADERS)
	(cat Doxyfile; echo "PROJECT_NAME = $(TARGET)") | $(DOXYGEN) -

compilecmd:
	@echo "$(CXX) $(CXXFLAGS)"

format:
	@echo "make format is not available."

lint:
	@echo "make lint is not available."
	@python3 ../.action/checks.py lint $(LAB_PART)

header:
	@echo "make header is not available."

test:
	@echo "make test is not available."

ifneq ($(DO_UNITTESTS), "True")
unittest:
	@echo "No unit tests avialable."
else
unittest: cleanunittest utest

utest: $(TARGET)_functions.o $(TARGET)_unittest.cc
	@$(CXX) $(GTESTINCLUDE) $(LDFLAGS) -o unittest $(TARGET)_unittest.cc $(TARGET)_functions.o $(GTESTLIBS)
	@./unittest --gtest_output=$(GTEST_OUTPUT_FORMAT):$(GTEST_OUTPUT_FILE)

endif

cleanunittest:
		-@rm -rf unittest.dSYM > /dev/null 2>&1 || true
		-@rm unittest test_detail.json > /dev/null 2>&1 || true

        
