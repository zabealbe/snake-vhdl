library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_head is
end test_head;

architecture Behavioral of test_head is
    signal u, d, l, r: std_logic := '0';
    signal currx, curry: unsigned(17 downto 0);
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
begin
    hh: entity work.head 
    generic map (
        x0 => to_unsigned(1, 18), y0 => to_unsigned(1, 18)
    )
    port map (u, d, l, r, clk, rst, currx, curry);
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
