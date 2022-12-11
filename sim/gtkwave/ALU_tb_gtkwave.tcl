# add_waves.tcl 
set sig_list [list clk_s rst_s operand_a_s operand_b_s operation_s result_s status_s]
gtkwave::addSignalsFromList $sig_list

# Zoom full (Shift + Alt + F)
gtkwave::/Time/Zoom/Zoom_Full

# Change signal formats
gtkwave::/Edit/Highlight_Regexp "operand_a_s"
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Highlight_Regexp "operand_b_s"
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Highlight_Regexp "result_s"
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/UnHighlight_All