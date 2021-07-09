library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_tail is
end test_tail;

architecture Behavioral of test_tail is
    signal load, shift, empty, full, clk: std_logic := '0';
    signal inx, iny: unsigned(17 DOWNTO 0) := to_unsigned(11, 18);
    signal outx, outy: unsigned(17 DOWNTO 0);
begin
    hh: entity work.tail
        port map (
            shift=>shift, 
            rst=>'0',
            inx=>inx, iny=>iny, 
            clk=>clk, 
            outx => outx,
            outy=>outy, 
            empty=>empty,
            full=>full
        );
    clk <= not clk after 50ns;
    inx <= inx + 1 after 100ns;
    iny <= iny - 1 after 100ns;
    process is
    begin
        wait for 100ns;
        shift <= '1';
        wait for 100ns;
        shift <= '0';
        wait for 100ns;
        shift <= '1';
        load <= '1';
        wait for 100ns;
        shift <= '0';
        load <= '1';
        wait for 100ns;
        load <= '0';
        shift <= '1';
        wait for 100ns;
        wait;
    end process;
end Behavioral;
