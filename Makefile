BUILD  = build
SOURCE = $(wildcard src/*)
INPUT  = src/main.asm
OUTPUT = $(BUILD)/rom.sfc

.PHONY: all clean

all: $(BUILD) $(OUTPUT)

clean:
	rm -rf $(BUILD)

$(BUILD):
	mkdir -p $(BUILD)

$(OUTPUT): $(SOURCE)
	64tass -f -l $(BUILD)/labels.txt -L $(BUILD)/listing.txt -o $@ $(INPUT)
