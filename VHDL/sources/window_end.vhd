library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity window_end is
    generic (
        bounds: t_box
    );
    port (
        clk, rst: in std_logic;
        pos: in t_pos;
        tile : out t_tile;
        visible: out std_logic
    );
end window_end;

architecture Behavioral of window_end is
    type t_static is array (0 to 10-1) of t_tile;
    constant bounds_text: t_box := (
        tl => (
            x => (bounds.tl.x + bounds.br.x - t_static'length) / 2,
            y => (bounds.tl.y + bounds.br.y) / 2
        ),
        br => (
            x => (bounds.tl.x + bounds.br.x - t_static'length) / 2 + 10,
            y => (bounds.tl.y + bounds.br.y) / 2 + 3
        )
    );
    -- ROM
    constant row_0: t_static := (tile_g, tile_a, tile_m, tile_e, empty, tile_o, tile_v, tile_e, tile_r, others => empty);
    constant row_1: t_static := (tile_p, tile_r, tile_e, tile_s, tile_s, empty, tile_b, tile_t, tile_n, tile_c, others => empty);
    constant row_2: t_static := (tile_t, tile_o, empty, tile_r, tile_e, tile_s, tile_t, tile_a, tile_r, tile_t, others => empty);
    
    signal pos_rel: t_pos;
    signal index, value: natural;
    signal visible0, visible_text: std_logic;
begin
    e_window: entity work.window(Behavioral)
        generic map (
            bounds => bounds
        )
        port map (
            pos => pos,
            visible => visible0
        );
    e_sub_window: entity work.window(Behavioral)
        generic map (
            bounds => bounds_text
        )
        port map (
            pos => pos,
            visible => visible_text
        );
    visible <= visible0;
    pos_rel <=
        pos - bounds_text.tl;
    tile <=
        empty when visible_text = '0' else
        row_0(to_integer(pos_rel.x)) when pos_rel.y = 0 else
        row_1(to_integer(pos_rel.x)) when pos_rel.y = 1 else
        row_2(to_integer(pos_rel.x)) when pos_rel.y = 2 else
        empty;
end architecture;
