SRC_DIR = src
TB_DIR = tb

TB_MODULE = top_tb
OUT_FILE = sim.vvp
WAVE_FILE = wave.vcd

SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
TB_FILE = $(TB_DIR)/$(TB_MODULE).v

all: wave

compile:
	iverilog -o $(OUT_FILE) $(SRC_FILES) $(TB_FILE)

run: compile
	vvp $(OUT_FILE)

wave: run
	gtkwave $(WAVE_FILE)

clean:
	rm -f $(OUT_FILE) $(WAVE_FILE)