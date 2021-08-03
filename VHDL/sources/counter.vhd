library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    generic (
        max: integer
    );
    port (
        clk, rst, enable: in std_logic;
        tc: out std_logic;
        count: out integer range 0 to max
    );
end counter;

architecture Behavioral of counter is
    signal value: integer range 0 to max := 0;
begin
    process (clk, rst) begin
        if rst = '0' then
            value <= 0; 
        elsif rising_edge(clk) then
            if enable = '1' then
                if value = max then
                    value <= 0;
                else
                    value <= value + 1;
                end if;                
            end if; 
        end if;
    end process;
    
    tc <= '1' when value = max and enable = '1' else '0';
end Behavioral;