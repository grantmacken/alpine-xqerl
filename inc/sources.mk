# sources
#  ordered list of list library modules to compile
LibraryModuleSource := $(sort $(wildcard src/library_modules/$(DOMAIN)/*.xqm))
MainModuleSource    := $(wildcard src/main_modules/*.xq)
EscriptSource       := $(wildcard src/bin/*.escript)

LibraryModules  := $(patsubst src/library_modules/$(DOMAIN)/%,src/.compiled/library_modules/$(DOMAIN)/%,$(LibraryModuleSource))
MainModules  := $(patsubst src/main_modules/%,src/.compiled/main_modules/%,$(MainModuleSource))
Escripts := $(patsubst src/bin/%.escript,src/.binned/%.escript,$(EscriptSource))
.PHONY: escripts
escripts: $(Escripts) ## copy escripts into docker volume

.PHONY: main-modules
main-modules: $(MainModules) ## copy main-modules into docker volume and compile

.PHONY: library-modules
library-modules: $(LibraryModules) ## ordered sequence copy of library-modules into docker volume and compile

src/.binned/%.escript: src/bin/%.escript
	@echo '| $(notdir $@) |'
	@mkdir -p $(dir $@)
	@docker cp $(<) xq:$(XQERL_HOME)/bin/scripts 
	@cp $(<) $(@)

src/.compiled/main_modules/%.xq: src/main_modules/%.xq
	@echo '| $(notdir $@) |'
	@docker cp $(<) xq:$(XQERL_HOME)/code/src
	@bin/xq compile $< 
	@mkdir -p $(dir $@)
	@cp $< $@
	@echo

src/.compiled/library_modules/$(DOMAIN)/%.xqm: src/library_modules/$(DOMAIN)/%.xqm
	@echo '| $(notdir $@) |'
	@docker cp $(<) xq:$(XQERL_HOME)/code/src
	@#bin/scripts/compile.escript $(notdir $<) 
	@mkdir -p $(dir $@)
	@cp $< $@

