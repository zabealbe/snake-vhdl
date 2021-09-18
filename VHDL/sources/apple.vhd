library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity apple is
    generic (
        bounds: t_box
    );
    port (
        clk, rst: in std_logic;
        mov, tick: in std_logic;
        pos: out t_pos
    );
end apple;

architecture Behavioral of apple is
    signal data_random: std_logic_vector(t_posx'length+t_posy'length-1 downto 0);
    constant bounds_delta: t_pos := bounds.br - bounds.tl;
begin
    e_prng: entity work.PRNG(Behavioral)
    generic map (
        size => t_posx'length + t_posy'length
    )
    port map (
        clk => clk,
        rst => rst,
        init => mov,
        enable => mov,
        data => data_random
    );
    pos <= ( -- TODO: better math
        x => (unsigned(data_random(data_random'length-1 downto t_posy'length)))
            mod (bounds_delta.x+1) + bounds.tl.x,
        y => (unsigned(data_random(t_posy'length-1 downto 0)))
            mod (bounds_delta.y+1) + bounds.tl.y
    );
end Behavioral;
