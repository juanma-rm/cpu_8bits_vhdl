library ieee;
use ieee.std_logic_1164.all;

package utils is

    constant data_width_c : integer	:= 8;

    type alu_op_t is (alu_nop, alu_add, alu_sub, alu_not, alu_or, alu_and, alu_nor, alu_nand, alu_xor);
    type status_flag_t is record
        zero     : std_logic;
        carry    : std_logic;
        sign_neg : std_logic;
        overflow : std_logic;
        unused   : std_logic_vector(data_width_c - 1 - 4 downto 0);
    end record;

end package;