library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity test_snake is
end test_snake;

architecture Behavioral of test_snake is
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal u, d, l, r: std_logic := '0';
    signal head_pos, tail_pos: pos;
    signal grow: std_logic := '0'; -- shift 1 -> not grow, shift 0 -> grow
begin
    snake: entity work.snake
    port map (
        u => u, d => d, l => l, r => r,
        head_pos => head_pos,
        tail_pos => tail_pos,
        grow => grow,
        CLK => clk, RST => rst
    );
    clk <= not clk after 10ns;
    process is
    begin
        rst <= '1';  
        grow <= '1';
        wait for 60ns;
        rst <= '0';
        grow <= '0';
        wait for 100ns;
        d <= '1';
        wait for 100ns;
        d <= '0';
        wait for 100ns;
        grow <= '0';
        r <= '1';
        wait for 200ns;
        grow <= '1';
        wait for 100ns;
        grow <= '0';
        wait;
    end process;
end Behavioral;
