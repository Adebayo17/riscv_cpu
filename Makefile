SRC_DIR = src
SIM_DIR = sim
SIM_OUT_DIR = sim_out

MODULES = alu regfile control decode cpu

# Create the simulation output directory
$(SIM_OUT_DIR):
	mkdir -p $(SIM_OUT_DIR)

all_sim: $(MODULES:%=%_sim)

# Static pattern rules for each module
$(SIM_OUT_DIR)/%_tb.out: $(SRC_DIR)/%.v $(SIM_DIR)/%_tb.v $(SIM_OUT_DIR)
	@echo -e "$(YELLOW)************************************************************$(RESET)"
	@echo -e "$(GREEN)Start Simulating module: $*$(RESET)"
	@echo -e "$(YELLOW)************************************************************$(RESET)"
	@iverilog -o $@ $^
	@vvp $@
	@echo -e "$(YELLOW)************************************************************$(RESET)"
	@echo -e "$(GREEN)End Simulating module: $*$(RESET)"
	@echo -e "$(YELLOW)************************************************************$(RESET)"
	@echo ""

%_sim: $(SIM_OUT_DIR)/%_tb.out

clean_sim_out:
	rm -rf $(SIM_OUT_DIR)/*

.PHONY: all_sim clean_sim_out help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all_sim: Run all simulations."
	@echo "  <module>_sim: Run simulation for a specific module (e.g., make alu_sim)."
	@echo "  clean_sim_out: Remove simulation output files."
	@echo "  help: Display this help message."

# Dependencies for cpu_sim (crucial!)
alu_sim: $(SIM_OUT_DIR)/alu_tb.out

regfile_sim: $(SIM_OUT_DIR)/regfile_tb.out

control_sim: $(SIM_OUT_DIR)/control_tb.out

decode_sim: $(SIM_OUT_DIR)/decode_tb.out

cpu_sim: $(SIM_OUT_DIR)/cpu_tb.out

$(SIM_OUT_DIR)/cpu_tb.out: $(SRC_DIR)/cpu.v $(SRC_DIR)/datapath.v $(SRC_DIR)/decode.v $(SRC_DIR)/control.v $(SRC_DIR)/regfile.v $(SRC_DIR)/alu.v $(SIM_DIR)/cpu_tb.v $(SIM_OUT_DIR)



# Color codes
YELLOW=\033[33m
GREEN=\033[32m
RESET=\033[0m