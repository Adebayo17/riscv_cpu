# Compiler and simulation tools
IVERILOG = iverilog
VVP = vvp
GTK = gtkwave
YOSYS = yosys
NEXTPNR = nextpnr-ice40

# Directories
SRC_DIR 	= src
SIM_DIR 	= sim
SIM_OUT_DIR = sim_out
PROG_DIR 	= programs
WAVE_DIR 	= wave

# Source files
SRC_FILES = $(SRC_DIR)/cpu.v $(SRC_DIR)/datapath.v $(SRC_DIR)/decode.v \
            $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v \
            $(SIM_DIR)/cpu_tb.v

# Output files
VCD_FILE = $(WAVE_DIR)/dump.vcd
TB_OUT   = $(SIM_OUT_DIR)/cpu_tb.out
MEM_FILE = $(SIM_DIR)/program.mem

# Default program number (if not specified)
PROGRAM ?= 1

# Select test program by creating a symbolic link
select_program:
	@echo "📄 Copying program_$(PROGRAM).mem to sim/program.mem..."
	@rm -f $(MEM_FILE)
	@cp -rf $(PROG_DIR)/program_$(PROGRAM).mem $(MEM_FILE)
#	@ln -s $(pwd)/$(PROG_DIR)/program_$(PROGRAM).mem $(MEM_FILE)

# Compilation rule: Compile Verilog sources into simulation binary
compile: select_program
	@echo "🔨 Compiling Verilog source files..."
	$(IVERILOG) -o $(TB_OUT) $(SRC_FILES)

# Simulation rule: Run the testbench
simulate: compile
	@echo "🚀 Running simulation..."
	$(VVP) $(TB_OUT)

# View waveforms in GTKWave
wave: $(VCD_FILE)
	@echo "📊 Opening GTKWave..."
	$(GTK) $(VCD_FILE) &

# FPGA Synthesis using Yosys
synth:
	@echo "🔧 Synthesizing for FPGA..."
	$(YOSYS) -p "read_verilog $(SRC_DIR)/cpu.v; synth_ice40 -top cpu; write_blif cpu.blif"

# FPGA Place & Route using NextPNR
route: synth
	@echo "📌 Running placement & routing..."
	$(NEXTPNR) --hx8k --package tq144 --json cpu.json --pcf constraints.pcf --asc cpu.asc

# Clean generated files
clean:
	@echo "🧹 Cleaning up..."
	rm -f $(TB_OUT) $(VCD_FILE) cpu.blif cpu.json cpu.asc

# Default target
all: compile simulate wave

# Run a test program by specifying PROGRAM=<num>
test: select_program simulate wave
	@echo "✅ Test completed for program_$(PROGRAM).mem!"


help:
	@echo "🛠  Available Makefile Commands:"
	@echo "-----------------------------------------------"
	@echo "make help           - Show this help message"
	@echo "make test PROGRAM=N - Run test with program_N.mem (e.g., make test PROGRAM=1)"
	@echo "make compile        - Compile Verilog files"
	@echo "make simulate       - Run simulation"
	@echo "make wave           - Open GTKWave for waveform analysis"
	@echo "make synth          - Synthesize the design for FPGA"
	@echo "make route          - Perform FPGA place & route"
	@echo "make clean          - Remove temporary files"
	@echo "-----------------------------------------------"

#########################################################################################################################################

# SRC_DIR = src
# SIM_DIR = sim
# SIM_OUT_DIR = sim_out

# MODULES = alu regfile control decode cpu

# # Create the simulation output directory
# $(SIM_OUT_DIR):
# 	mkdir -p $(SIM_OUT_DIR)

# all_sim: $(MODULES:%=%_sim)

# # Static pattern rules for each module
# $(SIM_OUT_DIR)/%_tb.out: $(SRC_DIR)/%.v $(SIM_DIR)/%_tb.v $(SIM_OUT_DIR)
# 	@echo -e "$(YELLOW)************************************************************$(RESET)"
# 	@echo -e "$(GREEN)Start Simulating module: $*$(RESET)"
# 	@echo -e "$(YELLOW)************************************************************$(RESET)"
# 	@iverilog -o $@ $^
# 	@vvp $@
# 	@echo -e "$(YELLOW)************************************************************$(RESET)"
# 	@echo -e "$(GREEN)End Simulating module: $*$(RESET)"
# 	@echo -e "$(YELLOW)************************************************************$(RESET)"
# 	@echo ""

# %_sim: $(SIM_OUT_DIR)/%_tb.out

# clean_sim_out:
# 	rm -rf $(SIM_OUT_DIR)/*

# .PHONY: all_sim clean_sim_out help

# help:
# 	@echo "Usage: make [target]"
# 	@echo ""
# 	@echo "Targets:"
# 	@echo "  all_sim: Run all simulations."
# 	@echo "  <module>_sim: Run simulation for a specific module (e.g., make alu_sim)."
# 	@echo "  clean_sim_out: Remove simulation output files."
# 	@echo "  help: Display this help message."

# # Dependencies for cpu_sim (crucial!)
# alu_sim: $(SIM_OUT_DIR)/alu_tb.out

# regfile_sim: $(SIM_OUT_DIR)/regfile_tb.out

# control_sim: $(SIM_OUT_DIR)/control_tb.out

# decode_sim: $(SIM_OUT_DIR)/decode_tb.out

# cpu_sim: $(SIM_OUT_DIR)/cpu_tb.out

# $(SIM_OUT_DIR)/cpu_tb.out: $(SRC_DIR)/cpu.v $(SRC_DIR)/datapath.v $(SRC_DIR)/decode.v $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v $(SIM_DIR)/cpu_tb.v $(SIM_OUT_DIR)



# Color codes
YELLOW=\033[33m
GREEN=\033[32m
RESET=\033[0m