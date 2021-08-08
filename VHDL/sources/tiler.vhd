library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity score_tiler is
    generic (
        size: integer;
        top_left: t_pos
    );
    port (
        clk, rst: in std_logic;
        enable: in std_logic;
        pos: in t_pos;
        tile : out t_tile;
        visible: out std_logic
    );
end score_tiler;

architecture Behavioral of score_tiler is
    constant bounds: t_box := (
        tl => top_left,
        br => top_left + to_pos(size-1, 1)
    );
    
    type t_static is array (0 to size-1) of t_tile;
    constant static: t_static := (tile_s, tile_c, tile_o, tile_r, tile_e, others => empty);
    
    signal pos_rel: t_pos;
    signal index, value: natural;
    signal visible0: std_logic;
begin
    e_window: entity work.window(Behavioral)
        generic map (
            bounds => bounds
        )
        port map (
            pos => pos,
            visible => visible0
        );
    e_counter_score: entity work.counter_bcd(Behavioral)
        generic map (
            size => size
        )
        port map (
            clk => clk, rst => rst,
            enable => enable,
            index => index,
            value => value
        );
    visible <= visible0;
    pos_rel <=
        pos - bounds.tl when visible0 = '1'
        else zero_pos;
    index <= 
        to_integer(size - 1 - pos_rel.x) when visible0 = '1'
        else 0;
    tile <=
        empty when visible0 = '0' else
        static(to_integer(pos_rel.x)) when pos_rel.y = 0 else
        tile_0 when pos_rel.y = 1 and value = 0 else
        tile_1 when pos_rel.y = 1 and value = 1 else
        tile_2 when pos_rel.y = 1 and value = 2 else
        tile_3 when pos_rel.y = 1 and value = 3 else
        tile_4 when pos_rel.y = 1 and value = 4 else
        tile_5 when pos_rel.y = 1 and value = 5 else
        tile_6 when pos_rel.y = 1 and value = 6 else
        tile_7 when pos_rel.y = 1 and value = 7 else
        tile_8 when pos_rel.y = 1 and value = 8 else
        tile_9 when pos_rel.y = 1 and value = 9;
end architecture;
