----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- reg_bank.vhd

--! Inputs:
--!     - select: register to read / write
--!     - rd_en_i: enable read from register to data_bus_io. Read is asynchronous
--!     - wr_en_i: enable write from data_bus_io to register. Write synchronous
--! If both read and write functions are enabled, none of them takes effect
--!     
--! Inout:
--!     - data_bus_io
--!
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

entity reg_bank is
    generic (
        data_width_g : integer := 8;
        nb_regs_g    : integer := 10
    );
    port (
        clk_i        : in std_logic;
        rst_i        : in std_logic;
        data_bus_io  : inout std_logic_vector(data_width_g - 1 downto 0);
        select_i     : in std_logic_vector(log2_ceil(nb_regs_g) - 1 downto 0);
        rd_en_i      : in std_logic;
        wr_en_i      : in std_logic;
        regA_o       : out std_logic_vector(data_width_g - 1 downto 0);
        regB_o       : out std_logic_vector(data_width_g - 1 downto 0);
        regACC_o     : out std_logic_vector(data_width_g - 1 downto 0);
        regStatus_o  : out std_logic_vector(data_width_g - 1 downto 0);
        regPC_o      : out std_logic_vector(data_width_g - 1 downto 0);
        regMAR_o     : out std_logic_vector(data_width_g - 1 downto 0);
        regMDR_o     : out std_logic_vector(data_width_g - 1 downto 0);
        regCIR_o     : out std_logic_vector(data_width_g - 1 downto 0)
    );
end reg_bank;

----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------

architecture behavioural of reg_bank is

    subtype reg_t is std_logic_vector(data_width_g - 1 downto 0);
    type reg_bank_t is array (0 to nb_regs_g - 1) of reg_t;
    signal reg_bank_s : reg_bank_t := (others => (others => '1'));

    signal select_s : integer;

begin

    select_s <= to_integer(unsigned(select_i));

    process (clk_i) 
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                reg_bank_s(select_s) <= (others => '0');
            elsif (wr_en_i = '1' and rd_en_i = '0') then
                reg_bank_s(select_s) <= data_bus_io;
            end if;
        end if;
    end process;

    data_bus_io <= reg_bank_s(select_s) when (rd_en_i = '1' and wr_en_i = '0') else (others => 'Z');

    -- Wiring registers directly used from the rest of the system (alu, control registers, ...)
    regA_o       <= reg_bank_s(register_map_t'pos(regA));
    regB_o       <= reg_bank_s(register_map_t'pos(regB));
    regACC_o     <= reg_bank_s(register_map_t'pos(acc));
    regStatus_o  <= reg_bank_s(register_map_t'pos(status));
    regPC_o      <= reg_bank_s(register_map_t'pos(pc));
    regMAR_o     <= reg_bank_s(register_map_t'pos(mar));
    regMDR_o     <= reg_bank_s(register_map_t'pos(mdr));
    regCIR_o     <= reg_bank_s(register_map_t'pos(cir));

end behavioural;
