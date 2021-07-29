 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_gen is
    generic(
        divide_value: integer
    );
    port(   
        clk: in std_logic;
        clk_mod: out std_logic
    );
end clk_gen;

architecture Behavioral of clk_gen is

signal counter, divide: integer := 0;

begin
    divide <= divide_value;
process(clk)
begin
    if( rising_edge(clk) ) then
        if(counter < divide/2-1) then
            counter <= counter + 1;
            clk_mod <= '0';
        elsif(counter < divide-1) then
            counter <= counter + 1;
            clk_mod <= '1';
        else
            clk_mod <= '0';
            counter <= 0;
        end if;
    end if;
end process;   

end Behavioral;
