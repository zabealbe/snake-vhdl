library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_bcd is
    generic(
        size: natural
    );
    port(
        clk, rst: in std_logic;
        enable:   in std_logic;
        index:    in natural range 0 to size-1;
        value:    out natural range 0 to 9
    );
end counter_bcd;

architecture Behavioral of counter_bcd is
    type arr is array (0 to size-1) of natural;
    signal tc: std_logic_vector(size downto 0);
    signal values: arr;
begin
    tc(0) <= enable;
    value <= values(index);
    gen_cnt: for I in 0 to size-1 generate
      cntx: entity work.counter
        generic map (
            max => 9
        )
        port map (
            clk => clk, rst => rst,
            enable => tc(I),
            tc => tc(I+1),
            count => values(I)
        );
    end generate;
end Behavioral;
