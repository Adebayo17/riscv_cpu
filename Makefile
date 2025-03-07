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
SYNTH       = synth

# Source files
SRC_FILES = $(SRC_DIR)/cpu.v $(SRC_DIR)/datapath.v $(SRC_DIR)/decode.v $(SRC_DIR)/data_memory.v $(SRC_DIR)/program_memory.v \
            $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v
            
TB_FILES = $(SIM_DIR)/alu_tb.v $(SIM_DIR)/regfile_tb.v $(SIM_DIR)/control_tb.v $(SIM_DIR)/decode_tb.v $(SIM_DIR)/data_memory_tb.v \
		   $(SIM_DIR)/program_memory_tb.v $(SIM_DIR)/datapath_tb.v $(SIM_DIR)/cpu_tb.v

# Output files
VCD_FILE = $(WAVE_DIR)/cpu.vcd
TB_OUT   = $(SIM_OUT_DIR)/cpu_tb.out
MEM_FILE = $(SIM_DIR)/program.mem

# Default program number (if not specified)
PROGRAM ?= 0

# Select test program by creating a symbolic link
select_program:
	@echo "📄 Copying program_$(PROGRAM).mem to sim/program.mem..."
	@rm -f $(MEM_FILE)
	@cp -rf $(PROG_DIR)/program_$(PROGRAM).mem $(MEM_FILE)

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

synth_all: synth_cpu synth_datapath synth_alu synth_regfile synth_control synth_decode synth_data_memory synth_program_memory

synth_cpu:
	@echo "🔧 Synthesizing CPU for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top cpu; write_json $(SYNTH)/cpu.json; write_blif $(SYNTH)/cpu.blif"
	netlistsvg $(SYNTH)/cpu.json -o $(SYNTH)/cpu.svg

synth_datapath:
	@echo "🔧 Synthesizing Datapath for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top datapath; write_json $(SYNTH)/datapath.json; write_blif $(SYNTH)/datapath.blif"
	netlistsvg $(SYNTH)/datapath.json -o $(SYNTH)/datapath.svg

synth_alu:
	@echo "🔧 Synthesizing ALU for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top alu; write_json $(SYNTH)/alu.json; write_blif $(SYNTH)/alu.blif"
	netlistsvg $(SYNTH)/alu.json -o $(SYNTH)/alu.svg

synth_regfile:
	@echo "🔧 Synthesizing Regfile for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top regfile; write_json $(SYNTH)/regfile.json; write_blif $(SYNTH)/regfile.blif"
	netlistsvg $(SYNTH)/regfile.json -o $(SYNTH)/regfile.svg

synth_control:
	@echo "🔧 Synthesizing Control for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top control; write_json $(SYNTH)/control.json; write_blif $(SYNTH)/control.blif"
	netlistsvg $(SYNTH)/control.json -o $(SYNTH)/control.svg

synth_decode:
	@echo "🔧 Synthesizing Decode for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top decode; write_json $(SYNTH)/decode.json; write_blif $(SYNTH)/decode.blif"
	netlistsvg $(SYNTH)/decode.json -o $(SYNTH)/decode.svg

synth_data_memory:
	@echo "🔧 Synthesizing Data Memory for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top data_memory; write_json $(SYNTH)/data_memory.json; write_blif $(SYNTH)/data_memory.blif"
	netlistsvg $(SYNTH)/data_memory.json -o $(SYNTH)/data_memory.svg

synth_program_memory:
	@echo "🔧 Synthesizing Program Memory for FPGA..."
	$(YOSYS) -p "read_verilog -DSYNTHESIS $(SRC_FILES); synth -top program_memory; write_json $(SYNTH)/program_memory.json; write_blif $(SYNTH)/program_memory.blif"
	netlistsvg $(SYNTH)/program_memory.json -o $(SYNTH)/program_memory.svg

########################################################################################
# FPGA Place & Route
########################################################################################
route: synth
	@echo "📌 Running placement & routing..."
	$(NEXTPNR) --hx8k --package tq144 --json $(SYNTH)/cpu.json --pcf constraints.pcf --asc $(SYNTH)/cpu.asc


########################################################################################
# Clean generated files
########################################################################################
clean:
	@echo "🧹 Cleaning up..."
	rm -rf $(TB_OUT) $(VCD_FILE)
	rm -rf $(WAVE_DIR)/*.vcd
	rm -rf $(SIM_OUT_DIR)/*.out  $(SIM_OUT_DIR)/*.log 
	rm -rf $(SYNTH)/*.json $(SYNTH)/*.blif $(SYNTH)/*.asc $(SYNTH)/*.svg

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
	$(IVERILOG) -o $(SIM_OUT_DIR)/cpu_tb.out $(SRC_FILES) $(TB_FILES)
	@echo "🚀 Running CPU simulation..."
	$(VVP) $(SIM_OUT_DIR)/cpu_tb.out
	@echo "📊 Opening GTKWave for CPU waveforms..."
	$(GTK) $(WAVE_DIR)/cpu_tb.vcd &


.PHONY: help synth route clean test select_program compile simulate wave sim_alu sim_regfile sim_control sim_decode sim_data_memory sim_program_memory sim_datapath

########################################################################################
# Help message
########################################################################################

help:
	@echo "🛠  Available Makefile Commands:"
	@echo "-----------------------------------------------------------------------------------------------"
	@echo "make help           				- Show this help message"
	@echo "make test PROGRAM=N 				- Run test with program_N.mem (e.g., make test PROGRAM=1)"
	@echo "make compile        				- Compile Verilog files"
	@echo "make simulate       				- Run simulation"
	@echo "make wave           				- Open GTKWave for waveform analysis"
	@echo "make synth          				- Synthesize the design for FPGA"
	@echo "make synth_all      				- Synthesize all modules for FPGA"
	@echo "make synth_cpu      				- Synthesize CPU module for FPGA"
	@echo "make synth_datapath 				- Synthesize Datapath module for FPGA"
	@echo "make synth_alu      				- Synthesize ALU module for FPGA"
	@echo "make synth_regfile  				- Synthesize Regfile module for FPGA"
	@echo "make synth_control  				- Synthesize Control module for FPGA"
	@echo "make synth_decode   				- Synthesize Decode module for FPGA"
	@echo "make synth_data_memory 			- Synthesize Data Memory module for FPGA"
	@echo "make synth_program_memory 		- Synthesize Program Memory module for FPGA"
	@echo "make route          				- Perform FPGA place & route"
	@echo "make clean          				- Remove temporary files"
	@echo "make sim_alu        				- Simulate ALU module"
	@echo "make sim_regfile    				- Simulate Regfile module"
	@echo "make sim_control    				- Simulate Control module"
	@echo "make sim_decode     				- Simulate Decode module"
	@echo "make sim_data_memory 			- Simulate Data Memory module"
	@echo "make sim_program_memory 			- Simulate Program Memory module"
	@echo "make sim_datapath   				- Simulate Datapath module"
	@echo "-----------------------------------------------------------------------------------------------"


# Color codes
YELLOW=\033[33m
GREEN=\033[32m
RESET=\033[0m