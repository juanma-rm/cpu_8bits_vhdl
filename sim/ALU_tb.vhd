----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- ALU_tb.vhd
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Import of libraries and packages
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

use std.env.finish;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------

entity ALU_tb is
end ALU_tb;

----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------

architecture tb of ALU_tb is

    constant clk_period_ns_c : time := 100 ns;
    signal clk_s : std_logic;
    signal rst_s : std_logic;

    signal operation_s  : alu_op_t;
    signal operand_a_s  : std_logic_vector(data_width_c - 1 downto 0);
    signal operand_b_s  : std_logic_vector(data_width_c - 1 downto 0);
    signal result_s     : std_logic_vector(data_width_c - 1 downto 0);
    signal status_s     : status_flag_t;

    type operands_t is array (0 to 1) of integer;
    type operands_list_t is array (natural range <>) of operands_t;
    constant operands_list_c : operands_list_t := (
        0 => (80, 40),
        1 => (40, 80),
        2 => (2**data_width_c - 1, 1),
        3 => (1, 2**data_width_c - 1)
    );

    -- report current operands / operation / result
    
    procedure report_header is
    begin
        report HT&HT & "operation" & HT&HT & "operandA" & HT&HT & "operandB" & HT&HT & "result" & HT&HT & "operandA" & HT&HT & "operandB" & HT&HT & "result";
    end procedure; 

    procedure report_current_op ( 
        opA       : in std_logic_vector(data_width_c - 1 downto 0);
        opB       : in std_logic_vector(data_width_c - 1 downto 0);
        operation : in alu_op_t;
        result    : in std_logic_vector(data_width_c - 1 downto 0)
    ) is 
    begin
        report HT&HT &
            to_string(operation)                    & HT&HT & 
            -- std logic vector
            to_string(opA) & HT&HT & to_string(opB) & HT&HT & to_string(result) & HT&HT &
            -- unsigned
            to_string(to_integer(unsigned(opA)))    & HT&HT & 
            to_string(to_integer(unsigned(opB)))    & HT&HT &
            to_string(to_integer(unsigned(result))) ;
    end procedure;

    -- check output
    procedure check_result ( 
        opA       : in std_logic_vector(data_width_c - 1 downto 0);
        opB       : in std_logic_vector(data_width_c - 1 downto 0);
        operation : in alu_op_t;
        result    : in std_logic_vector(data_width_c - 1 downto 0)
    ) is 

        variable opA_sig_v, opB_sig_v, result_sig_v : signed(data_width_c - 1 downto 0);
        variable test_passed_v : boolean := false;

    begin

        case operation is
            when alu_add  => test_passed_v := signed(result) = signed(opA) + signed(opB);
            when alu_sub  => test_passed_v := signed(result) = signed(opA) - signed(opB);
            when alu_not  => test_passed_v := result = not opA; 
            when alu_or   => test_passed_v := result = (opA or opB);
            when alu_and  => test_passed_v := result = (opA and opB);
            when alu_nor  => test_passed_v := result = (opA nor opB);
            when alu_nand => test_passed_v := result = (opA nand opB);
            when alu_xor  => test_passed_v := result = (opA xor opB);
            when others   => test_passed_v := false;
        end case;

        assert (test_passed_v) severity failure;

    end procedure;

begin

    -- ALU instance
    ALU_inst : entity work.ALU
    generic map (
        data_width_g => data_width_c
    )
    port map (
        clk_i       => clk_s,
        operation_i => operation_s,
        operand_a_i => operand_a_s,
        operand_b_i => operand_b_s,
        result_o    => result_s,
        status_o    => status_s
    );

    -- clk and reset stimulation

    clk_proc : process
    begin
        clk_s <= '0';
        wait for clk_period_ns_c/2;
        clk_s <= '1';
        wait for clk_period_ns_c/2;
    end process;

    rst_s <= '0', '1' after 10*clk_period_ns_c, '0' after 20*clk_period_ns_c;

    -- ALU stimulation
    alu_stim_proc : process
    begin
        wait for 30*clk_period_ns_c;
        report_header;
        for operands_iter in operands_list_c'range loop
            -- Select operands
            operand_a_s <= std_logic_vector(to_signed(operands_list_c(operands_iter)(0), data_width_c));
            operand_b_s <= std_logic_vector(to_signed(operands_list_c(operands_iter)(1), data_width_c));
            -- Iterate along all operators
            for operation in alu_op_t'left to alu_op_t'right loop
                operation_s <= operation;
                wait for clk_period_ns_c;
                report_current_op(operand_a_s, operand_b_s, operation_s, result_s);
                check_result(operand_a_s, operand_b_s, operation_s, result_s);
            end loop;
            wait for clk_period_ns_c;
        end loop;
        finish;  
    end process;

end tb;
