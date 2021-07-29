library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity snake is
    generic (
        bounds: t_box;
        start_pos: t_pos;
        max_length: integer := 16
    );
    port(
        grow, load: in std_logic;
        rst, clk: in std_logic; -- rst: active low
        u, d, l, r: in std_logic;
        head_pos: out t_pos;
        tail_pos: out t_pos
    );
end snake;

architecture Behavioral of snake is
    signal bind: t_pos;
    signal shift: std_logic;
    --signal shift, load: std_logic;
begin
    head: entity work.head(Behavioral)
        generic map (
            bounds => bounds,
            start_pos => zero_pos
        )
        port map (
            u => u, d => d, l => l, r => r,
            curr_pos => bind,
            clk => clk, rst => rst
        );
    tail: entity work.tail(WithFIFO)
        generic map (
            memory_size => max_length
        )
        port map (
            shift => shift,
            load => load,
            in_pos => bind,
            out_pos => tail_pos,
            clk => clk, rst => rst
        );
    --load <= '1';
    head_pos <= bind;
    shift <= not grow;
end Behavioral;
