BUILD  = build
INPUT  = $(wildcard src/*) $(wildcard include/*)
OUTPUT = $(BUILD)/rom.sfc

.PHONY: all clean

all: $(BUILD) $(OUTPUT)

clean:
	rm -rf $(BUILD)

$(BUILD):
	mkdir -p $(BUILD)

$(OUTPUT): $(INPUT)
	64tass -f -l $(BUILD)/labels.txt -L $(BUILD)/listing.txt -o $@ src/main.asm
