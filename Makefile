PREFIX ?= /usr/local
LUADIR ?= $(PREFIX)/share/lua/5.1

DEST_DIR := $(LUADIR)/lel

MACRO_SOURCE := init-macro.fnl
FENNEL_SOURCE := lel/state.fnl lel/macro-util.fnl
LUA_SOURCE := $(wildcard lel/*.lua)

state.lua: lel/state.fnl
	fennel --compile $< > $@

macro-util.lua: lel/macro-util.fnl
	fennel --compile $< > $@

all: state.lua macro-util.lua

install: $(LUA_SOURCE) state.lua macro-util.lua lel/init-macros.fnl
	@echo INST_PREFIX: $(PREFIX)
	mkdir -p $(DEST_DIR) && cp $^ $(DEST_DIR)/

clean:
	rm *.lua
