----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- vunit.vhd
-- First vunit testbench with 2 tests: first passes (checks num_frames_g against
-- num_frames_g) and second fails (checks num_frames_g againsts num_frames_g+1)
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Import of libraries and packages
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library src_lib;

-- Vunit
library vunit_lib;
context vunit_lib.vunit_context;
-- context vunit_lib.com_context; -- where "net" is defined

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------

entity vunit_tb is
    generic (
        runner_cfg     : string;
        num_frames_g   : integer := 4;
        golden_num_frames_g  : integer := 400
    );
end;

----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------

architecture bench of vunit_tb is

    -- Constants
    constant clk_100M_period_c : time := 10 ns;

    -- Clock and reset
    signal clk_100M_s    : std_ulogic := '0';
    signal rst_s         : std_ulogic := '0';   -- GSR

    -- Sync signals
    signal start_s       : boolean := false;
    signal done_s        : boolean := false;
    signal stim_done_s   : boolean := false;

    signal golden_data_s : natural := 0;

begin

    --------------------------------------------------------------
    -- Clock and reset
    --------------------------------------------------------------

    clk_100M_s    <= not clk_100M_s after clk_100M_period_c/2;

    -- rst_s active for 10 first cycles
    p_rst_s : process (clk_100M_s)
        variable cnt : integer := 0;
    begin
        if cnt < 10 then
            rst_s <= '1';
            cnt := cnt + 1;
        else
            rst_s <= '0';
        end if;
    end process;

    --------------------------------------------------------------
    -- Main process
    --------------------------------------------------------------

    main : process
    begin
        
        -- Common code between tests here
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);
        wait for 500 ns;
       
        -- Specific code depending the test
        while test_suite loop
            if run("test1_pass") then
                golden_data_s <= num_frames_g;
                start_s <= true;
            elsif run("test2_fail") then
                golden_data_s <= num_frames_g+1;
                start_s <= true;
            end if;
        end loop;

        -- Common code between tests here
        wait until done_s;
        test_runner_cleanup(runner);

    end process main;

    --------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------

    stimulus : process
    begin

        wait until start_s and rising_edge(clk_100M_s);
        info("Stimulus: start_sing...");

        for z in 0 to num_frames_g - 1 loop
            info("Iteration = " & to_string(z));
        end loop;

        info("Stimulus done_s!");
        stim_done_s <= true;
        wait;

    end process;

    --------------------------------------------------------------
    -- Check
    --------------------------------------------------------------

    check_proc : process
    begin

        wait until stim_done_s and rising_edge(clk_100M_s);
        info("Data: checking...");

        info("Number of frames = " & to_string(num_frames_g));
        check_equal(num_frames_g, golden_data_s, "Nb frames does not match!");

        info("Data checked!");
        done_s <= true;
        wait;

    end process;

end;
