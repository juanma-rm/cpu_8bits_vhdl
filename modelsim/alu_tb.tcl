# Open (manually) modelsim from workspace with simulations

# --------------------------------------------------------------------------
# Create project folder, project and add sources
# --------------------------------------------------------------------------

if {[file exist sim_alu_tb]} {
    if {[file isdirectory sim_alu_tb]} {
        file delete -force sim_alu_tb
    }
}
file mkdir sim_alu_tb
cd ./sim_alu_tb

# Create project
project new ./ sim_alu_tb work ../modelsim_vhdl2008.ini
project open sim_alu_tb

# Add source files
set sim_list [glob -directory "../../sim/" -- "*.vhd"]
foreach file $sim_list {
	project addfile $file
}
set sources_list [glob -directory "../../src/" -- "*.vhd"]
foreach file $sources_list {
	project addfile $file
}

# --------------------------------------------------------------------------
# Compile
# --------------------------------------------------------------------------

project calculateorder
#project compileorder
set compcmd [project compileall -n]
# project compileall

# --------------------------------------------------------------------------
# Simulate
# --------------------------------------------------------------------------

#vsim work.alu_tb -do "restart"
vsim work.alu_tb -do "
	add wave -position end  sim:/alu_tb/clk_s
	add wave -position end  sim:/alu_tb/rst_s
	add wave -position end  sim:/alu_tb/operation_s
	add wave -position end  sim:/alu_tb/operand_a_s
	add wave -position end  sim:/alu_tb/operand_b_s
	add wave -position end  sim:/alu_tb/result_s
	add wave -position end  sim:/alu_tb/status_s
	
	radix signal			sim:/alu_tb/operand_a_s decimal
	radix signal			sim:/alu_tb/operand_b_s decimal
	radix signal			sim:/alu_tb/result_s decimal
	
	run 1000 us
"
#vsim work.alu_tb -do "run -all"



# --------------------------------------------------------------------------
# Misc for vhdl2008 finally not used 
# --------------------------------------------------------------------------

# Modelsim.ini for vhdl2008 (VHDL93 = 2008)
#file copy ../modelsim.ini ./

# Modify project file (mpf)
# set modelsim_file [open [file normalize ./sim_alu_tb.mpf] r]
# set data [read -nonewline $modelsim_file]
# close $modelsim_file
# set new1 [string map {"VHDL93 = 2002" "VHDL93 = 2008"} $data]
# set new2 [string map {"vhdl_use93 2002" "vhdl_use93 2008"} $new1]
# set modelsim_file [open [file normalize ./sim_alu_tb.mpf] w]
# puts $modelsim_file $new2
# close $modelsim_file

# Alternative to compile file by file: vcom -2008 -work work alu.vhd
#vcom -2008 -work work alu.vhd

