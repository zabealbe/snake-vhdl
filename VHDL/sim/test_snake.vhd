library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.test_package.all;
use ieee.numeric_std.all;

use work.test_package;

entity test_snake is
end test_snake;

architecture Behavioral of test_snake is
    signal tmp: std_logic_vector(4 downto 0) := "00001";
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal u, d, l, r: std_logic := '0';
    signal headx, heady: unsigned(17 DOWNTO 0);
    signal tailx, taily: unsigned(17 DOWNTO 0);
    signal grow: std_logic := '0'; -- shift 1 -> not grow, shift 0 -> grow
    signal memx, memy: SHIFT_REG;
begin
    snake: entity work.snake
    port map (
        u => u, d => d, l => l, r => r,
        headx => headx, heady => heady,
        tailx => tailx, taily => taily,
        grow => grow,
        CLK => clk, RST => rst
    );
    clk <= not clk after 10ns;
    memx <= mem_x;
    memy <= mem_y;
    process is
    begin   
        wait for 100ns;
        rst <= '1';
        wait for 100ns;
        rst <= '0';
        grow <= '1';
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
