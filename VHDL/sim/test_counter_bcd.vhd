library ieee;
use ieee.std_logic_1164.all;

entity test_counter_bcd is
--  Port ( );
end test_counter_bcd;

architecture Behavioral of test_counter_bcd is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal value, index: natural;
begin
    clk <= not clk after 5ns;
    counter: entity work.counter_bcd(Behavioral)
        generic map (
            size => 8
        )
        port map (
            clk => clk,
            rst => rst,
            enable => '1',
            value => value,
            index => index
        );
    process is
    begin
        index <= 0;
        wait for 100ns;
        index <= 1;
        wait for 100ns;
        index <= 0;
    end process;
end Behavioral;
