library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity test_head is
end test_head;

architecture Behavioral of test_head is
    signal u, d, l, r: std_logic := '0';
    signal curr_pos: t_pos;
    signal clk, rst: std_logic := '0';
begin
    hh: entity work.head 
    generic map (
        bounds => max_box,
        start_pos => zero_pos
    )
    port map (
        u => u, d => d, l => l, r => r, 
        clk => clk, rst => rst, 
        curr_pos => curr_pos
    );
    clk <= not clk after 50ns;
    process is
    begin
        wait for 100ns;
        d <= '1';
        r <= '1';
        wait for 100ns;
        d <= '0';
        wait for 100ns;
        d <= '1';
        r <= '0';
        wait for 100ns;
        wait;
    end process;
end Behavioral;
