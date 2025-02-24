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
SRC_FILES = $(SRC_DIR)/cpu.v $(SRC_DIR)/datapath.v $(SRC_DIR)/decode.v $(SRC_DIR)/data_memory.v $(SRC_DIR)/program_memory.v \
            $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v $(SRC_DIR)/memory.v  \
            $(SIM_DIR)/cpu_tb.v

# Output files
VCD_FILE = $(WAVE_DIR)/cpu.vcd
TB_OUT   = $(SIM_OUT_DIR)/cpu_tb.out
MEM_FILE = $(SIM_DIR)/program.mem
MEM_RESULT_FILE = $(SIM_DIR)/expected_results.mem

# Default program number (if not specified)
PROGRAM ?= 1

# Select test program by creating a symbolic link
select_program:
	@echo "📄 Copying program_$(PROGRAM).mem to sim/program.mem..."
	@rm -f $(MEM_FILE) $(MEM_RESULT_FILE)
	@cp -rf $(PROG_DIR)/program_$(PROGRAM).mem $(MEM_FILE)
	@cp -rf $(PROG_DIR)/expected_results_$(PROGRAM).mem $(MEM_RESULT_FILE)

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


# Simulate ALU module
sim_alu:
	@echo "🔨 Compiling ALU testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/alu_tb.out $(SRC_DIR)/alu.v $(SIM_DIR)/alu_tb.v
	@echo "🚀 Running ALU simulation..."
	$(VVP) $(SIM_OUT_DIR)/alu_tb.out
	@echo "📊 Opening GTKWave for ALU waveforms..."
	$(GTK) $(WAVE_DIR)/alu_tb.vcd &

# Simulate Regfile module
sim_regfile:
	@echo "🔨 Compiling Regfile testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/regfile_tb.out $(SRC_DIR)/regfile.v $(SIM_DIR)/regfile_tb.v
	@echo "🚀 Running Regfile simulation..."
	$(VVP) $(SIM_OUT_DIR)/regfile_tb.out
	@echo "📊 Opening GTKWave for Regfile waveforms..."
	$(GTK) $(WAVE_DIR)/regfile_tb.vcd &

# Simulate Control module
sim_control:
	@echo "🔨 Compiling Control testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/control_tb.out $(SRC_DIR)/control.v $(SIM_DIR)/control_tb.v
	@echo "🚀 Running Control simulation..."
	$(VVP) $(SIM_OUT_DIR)/control_tb.out
	@echo "📊 Opening GTKWave for Control waveforms..."
	$(GTK) $(WAVE_DIR)/control_tb.vcd &

# Simulate Decode module
sim_decode:
	@echo "🔨 Compiling Decode testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/decode_tb.out $(SRC_DIR)/decode.v $(SIM_DIR)/decode_tb.v
	@echo "🚀 Running Decode simulation..."
	$(VVP) $(SIM_OUT_DIR)/decode_tb.out
	@echo "📊 Opening GTKWave for Decode waveforms..."
	$(GTK) $(WAVE_DIR)/decode_tb.vcd &

# Simulate Data Memory module
sim_data_memory:
	@echo "🔨 Compiling Data Memory testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/data_memory_tb.out $(SRC_DIR)/data_memory.v $(SIM_DIR)/data_memory_tb.v
	@echo "🚀 Running Data Memory simulation..."
	$(VVP) $(SIM_OUT_DIR)/data_memory_tb.out
	@echo "📊 Opening GTKWave for Data Memory waveforms..."
	$(GTK) $(WAVE_DIR)/data_memory_tb.vcd &

# Simulate Program Memory module
sim_program_memory:
	@echo "🔨 Compiling Program Memory testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/program_memory_tb.out $(SRC_DIR)/program_memory.v $(SIM_DIR)/program_memory_tb.v
	@echo "🚀 Running Program Memory simulation..."
	$(VVP) $(SIM_OUT_DIR)/program_memory_tb.out
	@echo "📊 Opening GTKWave for Program Memory waveforms..."
	$(GTK) $(WAVE_DIR)/program_memory_tb.vcd &

# Simulate Datapath module
sim_datapath:
	@echo "🔨 Compiling Datapath testbench..."
	$(IVERILOG) -o $(SIM_OUT_DIR)/datapath_tb.out $(SRC_DIR)/decode.v $(SRC_DIR)/data_memory.v $(SRC_DIR)/program_memory.v \
            $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v $(SRC_DIR)/memory.v  \
			$(SRC_DIR)/datapath.v $(SIM_DIR)/datapath_tb.v
	@echo "🚀 Running Datapath simulation..."
	$(VVP) $(SIM_OUT_DIR)/datapath_tb.out
	@echo "📊 Opening GTKWave for Datapath waveforms..."
	$(GTK) $(WAVE_DIR)/datapath_tb.vcd &

help:
	@echo "🛠  Available Makefile Commands:"
	@echo "-----------------------------------------------"
	@echo "make help           		- Show this help message"
	@echo "make test PROGRAM=N 		- Run test with program_N.mem (e.g., make test PROGRAM=1)"
	@echo "make compile        		- Compile Verilog files"
	@echo "make simulate       		- Run simulation"
	@echo "make wave           		- Open GTKWave for waveform analysis"
	@echo "make synth          		- Synthesize the design for FPGA"
	@echo "make route          		- Perform FPGA place & route"
	@echo "make clean          		- Remove temporary files"
	@echo "make sim_alu        		- Simulate ALU module"
	@echo "make sim_regfile    		- Simulate Regfile module"
	@echo "make sim_control    		- Simulate Control module"
	@echo "make sim_decode     		- Simulate Decode module"
	@echo "make sim_data_memory 	- Simulate Data Memory module"
	@echo "make sim_program_memory 	- Simulate Program Memory module"
	@echo "make sim_datapath   		- Simulate Datapath module"
	@echo "-----------------------------------------------"


# Color codes
YELLOW=\033[33m
GREEN=\033[32m
RESET=\033[0m