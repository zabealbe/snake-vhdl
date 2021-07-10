library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity test_tail is
end test_tail;

architecture Behavioral of test_tail is
    constant clock_period: time := 50ns;
    signal shift, load, empty, full, clk, rst: std_logic := '0';
    signal in_pos: pos := 
        (x => to_unsigned(2, posx_bits),
         y => to_unsigned(2, posx_bits));
    signal out_pos: pos;
begin
    hh: entity work.tail(WithFIFO)
        port map (
            shift => shift,
            load => load,
            rst => rst,
            in_pos => in_pos,
            clk => clk, 
            out_pos => out_pos,
            empty => empty,
            full => full
        );
    clk <= not clk after clock_period/2;
    process (clk) is
        variable count: integer := 0;
    begin
        count := count + 1;
        if count < 7 then
            count := count + 1;
        else
            if (rising_edge(clk)) then
                in_pos <= (x => in_pos.x + 1, y => in_pos.y + 3);
            end if;
        end if;
    end process;
    process is
    begin
        rst <= '1';
        wait for clock_period;
        rst <= '0';
        wait for 500ns;
        shift <= '1';
        load <= '1';
        wait for 100ns;
        --shift <= '0';
        wait for 100ns;
        shift <= '1';
        wait for 100ns;
        --shift <= '0';
        wait for 100ns;
        shift <= '1';
        wait for 100ns;
        rst <= '1';
        wait;
    end process;
end Behavioral;
