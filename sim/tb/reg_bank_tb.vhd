----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- reg_bank_tb.vhd
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Import of libraries and packages
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library src_lib;
use work.utils_pkg.all;

-- Vunit
library vunit_lib;
context vunit_lib.vunit_context;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------

entity reg_bank_tb is
    generic (
        runner_cfg     : string;
        data_width_g   : integer := 8;
        nb_regs_g      : integer := 10
    );
end reg_bank_tb;

----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------

architecture behavioural of reg_bank_tb is

    -- Clock and reset

    constant clk_period_ns_c : time := 10 ns; -- 100 MHz
    signal clk_s    : std_ulogic := '0';
    signal rst_s    : std_ulogic := '0';

    -- dut signals

    signal data_bus_s : std_logic_vector(data_width_g - 1 downto 0);
    signal select_s   : std_logic_vector(log2_ceil(nb_regs_g) - 1 downto 0);
    signal rd_en_s, wr_en_s    : std_logic;

    -- Sync signals
    signal start_s       : boolean := false;
    signal done_s        : boolean := false;
    signal stim_done_s   : boolean := false;

begin

    --------------------------------------------------------------
    -- Clock and reset
    --------------------------------------------------------------

    clk_s    <= not clk_s after clk_period_ns_c/2;
    rst_s <= '0', '1' after 10*clk_period_ns_c, '0' after 20*clk_period_ns_c;

    --------------------------------------------------------------
    -- Main process
    --------------------------------------------------------------

    main : process
    begin
        
        -- Common code between tests here
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);
       
        -- Specific code depending the test
        while test_suite loop
            if run("alu_test1") then
                start_s <= true;
            end if;
        end loop;

        -- Common code between tests here
        wait until done_s;
        test_runner_cleanup(runner);

    end process main;

    --------------------------------------------------------------
    -- DUT and other instances
    --------------------------------------------------------------

    reg_bank_inst : entity work.reg_bank
        generic map (
            data_width_g => data_width_g,
            nb_regs_g    => nb_regs_g
        )
        port map (
            clk_i       => clk_s,
            rst_i       => rst_s,
            data_bus_io => data_bus_s,
            select_i    => select_s,
            rd_en_i     => rd_en_s,
            wr_en_i     => wr_en_s
        );


    --------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------
    stimulus : process
    begin

        wait until start_s and rising_edge(clk_s);
        info("Stimulus: start_sing...");

        -- Set initial values for stimulus and wait for initial reset done
        select_s <= (others => '0');
        data_bus_s <= std_logic_vector(to_unsigned(10, data_width_g));
        rd_en_s  <= '0';
        wr_en_s  <= '0';
        wait for 20*clk_period_ns_c;
        -- Read from reg0; value expected: reset value (0)
        data_bus_s <= (others => 'Z');
        rd_en_s  <= '1';
        wait until rising_edge(clk_s);
        check_equal(data_bus_s, 0, "value read does not match the expected one");
        -- Write 5 to reg0
        rd_en_s  <= '0';
        wr_en_s  <= '1';
        data_bus_s <= std_logic_vector(to_unsigned(5, data_width_g));
        wait until rising_edge(clk_s);
        -- Write 3 to reg1
        select_s <= std_logic_vector(to_unsigned(1, log2_ceil(nb_regs_g)));
        data_bus_s <= std_logic_vector(to_unsigned(3, data_width_g));
        wait until rising_edge(clk_s);
        -- Read from reg0; expected: 5
        rd_en_s  <= '1';
        wr_en_s  <= '0';
        select_s <= std_logic_vector(to_unsigned(0, log2_ceil(nb_regs_g)));
        data_bus_s <= (others => 'Z');
        wait until rising_edge(clk_s);
        check_equal(data_bus_s, 5, "value read does not match the expected one");
        -- Read from reg1; expected: 3
        select_s <= std_logic_vector(to_unsigned(1, log2_ceil(nb_regs_g)));
        data_bus_s <= (others => 'Z');
        rd_en_s  <= '1';
        wait until rising_edge(clk_s);
        check_equal(data_bus_s, 3, "value read does not match the expected one");
        wait until rising_edge(clk_s);
        -- Try rd_en and wr_en simultaneosly; select_s should be put into Z
        wr_en_s  <= '1';

        wait for 10*clk_period_ns_c;

        info("Stimulus done_s!");
        stim_done_s <= true;
        wait;

    end process;

    --------------------------------------------------------------
    -- Check
    --------------------------------------------------------------

    check_proc : process
    begin

        wait until stim_done_s and rising_edge(clk_s);
        info("Data: checking...");

        info("Data was already checked. Nothing to do");

        info("Data checked!");
        done_s <= true;
        wait;

    end process;

end behavioural;
