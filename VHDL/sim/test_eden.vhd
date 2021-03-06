
library ieee;
use ieee.std_logic_1164.all;

entity test_eden is
end test_eden;

architecture Behavioral of test_eden is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
begin
    e_eden: entity work.eden
        port map (
            CLK => clk, RST => rst,
            BTNU => '0', BTND => '0', BTNL => '0', BTNR => '0', BTNC => '0',
            SW => (others => '0'),
            CA => open, CB => open, CC => open, CD => open, CE => open, CF => open, CG => open, DP => open,
            AN => open
        );
     clk <= not clk after 12ns;
     process is
     begin
        
     end process;
end Behavioral;
