alu_sim:
	@ iverilog -o sim_out/alu_tb.out src/alu.v sim/alu_tb.v
	@ vvp sim_out/alu_tb.out

regfile_sim:
	@ iverilog -o sim_out/regfile_tb.out src/regfile.v sim/regfile_tb.v
	@ vvp sim_out/regfile_tb.out

clean_sim_out:
	@ rm -rf sim_out/*