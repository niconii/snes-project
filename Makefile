BUILD           = build
DIRS            = $(BUILD) $(BUILD)/tools $(BUILD)/graphics

ROM_SRC         = $(wildcard src/*)
ROM_MAP         = src/rom.asm
ROM             = $(BUILD)/rom.sfc

TOOLS_SRC       = $(wildcard tools/*.c)
TOOLS           = $(TOOLS_SRC:tools/%.c=$(BUILD)/tools/%)
GRAPHICS_SRC    = $(wildcard graphics/*.gif)
GRAPHICS        = $(GRAPHICS_SRC:graphics/%.gif=$(BUILD)/graphics/%)

.PHONY: all clean

all: $(ROM)

clean:
	rm -rf $(BUILD)

$(DIRS):
	mkdir -p $@

$(ROM): $(ROM_SRC) $(GRAPHICS) | $(DIRS)
	64tass -Wall -f -l $(BUILD)/labels.txt -L $(BUILD)/listing.txt -o $@ $(ROM_MAP)

$(TOOLS): | $(DIRS)

$(BUILD)/tools/gif2sfc: tools/gif2sfc.c
	$(CC) $< -o $@ -lgif

$(GRAPHICS): | $(DIRS)

$(BUILD)/graphics/%.2bpp: graphics/%.2bpp.gif $(TOOLS)
	$(BUILD)/tools/gif2sfc 2 $< $@

$(BUILD)/graphics/%.4bpp: graphics/%.4bpp.gif $(TOOLS)
	$(BUILD)/tools/gif2sfc 4 $< $@

$(BUILD)/graphics/%.8bpp: graphics/%.8bpp.gif $(TOOLS)
	$(BUILD)/tools/gif2sfc 8 $< $@
