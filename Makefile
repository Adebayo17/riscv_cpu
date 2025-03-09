# Compiler and simulation tools
IVERILOG = iverilog
VVP = vvp
GTK = gtkwave
YOSYS = yosys
NEXTPNR = nextpnr-ice40

# Assembler and tools
AS = riscv64-unknown-elf-as
OBJCOPY = riscv64-unknown-elf-objcopy
PYTHON = python3

# Directories
ASM_DIR 		= asm
SRC_DIR 		= src
SIM_DIR 		= sim
SIM_OUT_DIR 	= sim_out
PROG_DIR 		= programs
WAVE_DIR 		= wave
SYNTH_DIR       = synth
SCRIPTS_DIR     = scripts

# Source files
SRC_FILES = $(SRC_DIR)/cpu.v $(SRC_DIR)/datapath.v $(SRC_DIR)/decode.v $(SRC_DIR)/data_memory.v $(SRC_DIR)/program_memory.v \
            $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v
            
TB_FILES = $(SIM_DIR)/alu_tb.v $(SIM_DIR)/regfile_tb.v $(SIM_DIR)/control_tb.v $(SIM_DIR)/decode_tb.v $(SIM_DIR)/data_memory_tb.v \
		   $(SIM_DIR)/program_memory_tb.v $(SIM_DIR)/datapath_tb.v $(SIM_DIR)/cpu_tb.v

# Output files
VCD_FILE = $(WAVE_DIR)/$(MODULE).vcd
TB_OUT   = $(SIM_OUT_DIR)/$(MODULE)_tb.out
MEM_FILE = $(SIM_DIR)/program.mem

# Default program number (if not specified)
PROGRAM ?= 0

# Default module for synthesis and simulation
MODULE ?= cpu

########################################################################################
# Program selection
########################################################################################

# Convert all assembly programs in ASM_DIR to program_<N>.mem
asm_to_mem_all:
	@echo "🛠  Assembling all programs..."
	@for file in $(ASM_DIR)/*.s; do \
		$(AS) -march=rv32i -mabi=ilp32 -o $(ASM_DIR)/$$(basename $$file .s).o $$file; \
		$(OBJCOPY) -O verilog $(ASM_DIR)/$$(basename $$file .s).o $(ASM_DIR)/$$(basename $$file .s).hex; \
		$(PYTHON) $(SCRIPTS_DIR)/hex_to_mem.py $(ASM_DIR)/$$(basename $$file .s).hex $(PROG_DIR)/$$(basename $$file .s).mem; \
	done
	@echo "✅ All programs assembled and converted to program_<N>.mem!"

# Convert assemply to program.mem
asm_to_mem:
	@echo "🛠  Assembling program_$(PROGRAM).s..."
	$(AS) -march=rv32i -mabi=ilp32 -o $(ASM_DIR)/program_$(PROGRAM).o $(ASM_DIR)/program_$(PROGRAM).s
	@echo "🔧 Converting to hexadecimal..."
	$(OBJCOPY) -O verilog $(ASM_DIR)/program_$(PROGRAM).o $(ASM_DIR)/program_$(PROGRAM).hex
	@echo "📄 Generating program.mem..."
	$(PYTHON) $(SCRIPTS_DIR)/hex_to_mem.py $(ASM_DIR)/program_$(PROGRAM).hex $(PROG_DIR)/program_$(PROGRAM).mem
	@echo "✅ program_$(PROGRAM).mem generated!"

# Select test program by creating a symbolic link
select_program: asm_to_mem
	@echo "📄 Copying program_$(PROGRAM).mem to sim/program.mem..."
	@rm -f $(MEM_FILE)
	@cp -rf $(PROG_DIR)/program_$(PROGRAM).mem $(MEM_FILE)


########################################################################################
# Simulation
########################################################################################

# Compilation rule: Compile Verilog sources into simulation binary
compile: select_program
	@echo "🔨 Compiling Verilog source files..."
	$(IVERILOG) -o $(TB_OUT) $(SRC_FILES) $(TB_FILES)

# Simulation rule: Run the testbench
simulate: compile
	@echo "🚀 Running simulation..."
	$(VVP) $(TB_OUT)

# View waveforms in GTKWave
wave: $(VCD_FILE)
	@echo "📊 Opening GTKWave..."
	$(GTK) $(VCD_FILE) &

########################################################################################
# FPGA Synthesis
########################################################################################

# Synthesis command
synth:
	@echo "🔧 Synthesizing $(MODULE) for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top $(MODULE); write_json $(SYNTH_DIR)/$(MODULE).json; write_blif $(SYNTH_DIR)/$(MODULE).blif"
	netlistsvg $(SYNTH_DIR)/$(MODULE).json -o $(SYNTH_DIR)/$(MODULE).svg

# Synthesize all modules
synth_all: synth_cpu synth_datapath synth_alu synth_regfile synth_control synth_decode synth_data_memory synth_program_memory

synth_cpu:
	$(MAKE) synth MODULE=cpu

synth_datapath:
	$(MAKE) synth MODULE=datapath

synth_alu:
	$(MAKE) synth MODULE=alu

synth_regfile:
	$(MAKE) synth MODULE=regfile

synth_control:
	$(MAKE) synth MODULE=control

synth_decode:
	$(MAKE) synth MODULE=decode

synth_data_memory:
	$(MAKE) synth MODULE=data_memory

synth_program_memory:
	$(MAKE) synth MODULE=program_memory

########################################################################################
# FPGA Place & Route
########################################################################################
route: synth
	@echo "📌 Running placement & routing..."
	$(NEXTPNR) --hx8k --package tq144 --json $(SYNTH_DIR)/$(MODULE).json --pcf constraints.pcf --asc $(SYNTH_DIR)/$(MODULE).asc


########################################################################################
# Default target
########################################################################################
all: compile simulate wave

########################################################################################
# Test target : Run a test program by specifying PROGRAM=<num>
########################################################################################
test: select_program simulate wave
	@echo "✅ Test completed for program_$(PROGRAM).mem!"


########################################################################################
# Simulation targets
########################################################################################

# Simulation command
sim:
	@echo "🔨 Compiling $(MODULE) testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/$(MODULE)_tb.out $(SRC_DIR)/$(MODULE).v $(SIM_DIR)/$(MODULE)_tb.v
	@echo "🚀 Running $(MODULE) simulation..."
	$(VVP) $(SIM_OUT_DIR)/$(MODULE)_tb.out
	@echo "📊 Opening GTKWave for $(MODULE) waveforms..."
	$(GTK) $(WAVE_DIR)/$(MODULE)_tb.vcd &

# Simulate ALU module
sim_alu:
	$(MAKE) sim MODULE=alu

# Simulate Regfile module
sim_regfile:
	$(MAKE) sim MODULE=regfile

# Simulate Control module
sim_control:
	$(MAKE) sim MODULE=control

# Simulate Decode module
sim_decode:
	$(MAKE) sim MODULE=decode

# Simulate Data Memory module
sim_data_memory:
	$(MAKE) sim MODULE=data_memory

# Simulate Program Memory module
sim_program_memory:
	$(MAKE) sim MODULE=program_memory

# Simulate Datapath module
sim_datapath: select_program
	@echo "🔨 Compiling Datapath testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/datapath_tb.out $(SRC_DIR)/decode.v $(SRC_DIR)/data_memory.v $(SRC_DIR)/program_memory.v \
            $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v \
			$(SRC_DIR)/datapath.v $(SIM_DIR)/datapath_tb.v
	@echo "🚀 Running Datapath simulation..."
	$(VVP) $(SIM_OUT_DIR)/datapath_tb.out
	@echo "📊 Opening GTKWave for Datapath waveforms..."
	$(GTK) $(WAVE_DIR)/datapath_tb.vcd &

# Simulate CPU module
sim_cpu: select_program
	@echo "🔨 Compiling CPU testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/cpu_tb.out $(SRC_FILES) $(SIM_DIR)/cpu_tb.v
	@echo "🚀 Running CPU simulation..."
	$(VVP) $(SIM_OUT_DIR)/cpu_tb.out
	@echo "📊 Opening GTKWave for CPU waveforms..."
	$(GTK) $(WAVE_DIR)/cpu_tb.vcd &


.PHONY: help synth sim route clean test select_program compile simulate wave sim_alu sim_regfile sim_control sim_decode sim_data_memory sim_program_memory sim_datapath sim_cpu asm_to_mem_all asm_to_mem


########################################################################################
# Clean generated files
########################################################################################
clean:
	@echo "🧹 Cleaning up..."
	rm -rf $(TB_OUT) $(VCD_FILE)
	rm -rf $(WAVE_DIR)/*.vcd
	rm -rf $(SIM_OUT_DIR)/*.out  $(SIM_OUT_DIR)/*.log 
	rm -rf $(SYNTH_DIR)/*.json $(SYNTH_DIR)/*.blif $(SYNTH_DIR)/*.asc $(SYNTH_DIR)/*.svg
	rm -rf $(ASM_DIR)/*.o $(ASM_DIR)/*.hex $(PROG_DIR)/*.mem
	rm -rf $(MEM_FILE)
	@echo "✅ Cleaned up!"

########################################################################################
# Git Commands
########################################################################################

# Git commands
git: clean
	@echo "🔧 Adding all files to git..."
	git add .
	@echo "📝 Enter commit message:"
	@read message; git commit -m "$$message"
	@echo "🚀 Pushing to remote repository..."
	git push -u origin master



########################################################################################
# Help message
########################################################################################

help:
	@echo "🛠  Available Makefile Commands:"
	@echo "-----------------------------------------------------------------------------------------------"
	@echo "make help                       - Show this help message"
	@echo "make asm_to_mem_all             - Assemble all programs in asm/ directory"
	@echo "make asm_to_mem                 - Assemble program_N.s and convert to program_N.mem"
	@echo "make select_program PROGRAM=N   - Select program_N.mem for simulation"
	@echo "make test PROGRAM=N             - Run test with program_N.mem (e.g., make test PROGRAM=1)"
	@echo "make compile                    - Compile Verilog files"
	@echo "make simulate                   - Run simulation"
	@echo "make wave                       - Open GTKWave for waveform analysis"
	@echo "make synth MODULE=<module>      - Synthesize a specific module for FPGA (e.g., make synth MODULE=cpu)"
	@echo "make synth_all                  - Synthesize all modules for FPGA"
	@echo "make route                      - Perform FPGA place & route"
	@echo "make clean                      - Remove temporary files"
	@echo "make sim MODULE=<module>        - Simulate a specific module (e.g., make sim MODULE=alu)"
	@echo "make sim_datapath               - Simulate Datapath module"
	@echo "make sim_cpu                    - Simulate CPU module"
	@echo "-----------------------------------------------------------------------------------------------"

# Color codes
YELLOW=\033[33m
GREEN=\033[32m
RESET=\033[0m