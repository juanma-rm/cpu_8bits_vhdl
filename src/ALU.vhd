----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- ALU.vhd

--! Inputs: operand_a_i, operand_b_i, operation_i, clk_i
--! Outputs: result_o, status_o_FLAG(C, Z, ...)
--! Operators: alu_add, alu_sub, alu_not, alu_or, alu_and, alu_nor, alu_nand, alu_xor

--! @todo: check all flags when needed, improve test
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Import of libraries and packages
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------

entity ALU is
    generic (
        data_width_g : integer	:= 8
    );
    port (
        clk_i        : in std_logic;
        operation_i  : in alu_op_t;
        operand_a_i  : in std_logic_vector(data_width_g-1 downto 0);
        operand_b_i  : in std_logic_vector(data_width_g-1 downto 0);
        result_o     : out std_logic_vector(data_width_g-1 downto 0);
        status_o     : out status_flag_t
    );
end ALU;

----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------

architecture behavioural of ALU is

begin

    process (clk_i)

        variable result_sign_v : signed(data_width_g-1+1 downto 0);
        variable result_lv_v   : std_logic_vector(data_width_g-1 downto 0);
        variable carry_v       : std_logic;
        variable zero_v        : std_logic;
        variable negative_v    : std_logic;

    begin

        if (rising_edge(clk_i)) then

            result_sign_v := to_signed(0, data_width_g + 1);
            result_lv_v   := std_logic_vector(to_unsigned(0, data_width_g));
            carry_v       := '0';
            zero_v        := '0';
            negative_v    := '0';

            case (operation_i) is 

                -- result = a + b
                when alu_add => 
                    result_sign_v := signed(resize(unsigned(operand_a_i), data_width_g+1) + resize(unsigned(operand_b_i), data_width_g+1));
                    result_lv_v := std_logic_vector(result_sign_v(data_width_g-1 downto 0));
                    carry_v := std_logic(result_sign_v(data_width_g));
                    zero_v := '1' when (result_sign_v = 0) else ('0');
                -- result = a - b
                when alu_sub =>
                    result_sign_v := signed(resize(unsigned(operand_a_i), data_width_g+1) - resize(unsigned(operand_b_i), data_width_g+1));                
                    result_lv_v := std_logic_vector(result_sign_v(data_width_g-1 downto 0));
                    zero_v := '1' when (result_sign_v = 0) else ('0');
                    negative_v := std_logic(result_sign_v(data_width_g-1));
                -- result = ~a
                when alu_not =>
                    result_lv_v := not(operand_a_i);
                -- result = a or b
                when alu_or =>
                    result_lv_v := operand_a_i or operand_b_i;
                -- result = a and b
                when alu_and =>
                    result_lv_v := operand_a_i and operand_b_i;
                -- result = a nor b
                when alu_nor =>
                    result_lv_v := operand_a_i nor operand_b_i;
                -- result = a nand b
                when alu_nand =>
                    result_lv_v := operand_a_i nand operand_b_i;
                -- result = a xor b
                when alu_xor =>
                    result_lv_v := operand_a_i xor operand_b_i;                     
                when others =>

            end case;

            -- Output assignment
            result_o          <= result_lv_v;
            status_o.carry    <= carry_v;
            status_o.zero     <= zero_v;
            status_o.sign_neg <= negative_v;
   
        end if;

    end process;

end behavioural;
