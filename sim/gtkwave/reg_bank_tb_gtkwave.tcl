# add_waves.tcl 
set sig_list [list clk_s rst_s reg_bank_s\[0\] reg_bank_s\[1\] rd_en_i wr_en_i select_i data_bus_io]
gtkwave::addSignalsFromList $sig_list

# Zoom full (Shift + Alt + F)
gtkwave::/Time/Zoom/Zoom_Full

# Change signal formats
# gtkwave::/Edit/Highlight_Regexp "my_signal_s"
# gtkwave::/Edit/Data_Format/Decimal
