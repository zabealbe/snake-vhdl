library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

-- Head module
-- keeps track of current head position
-- updates the position every time one of u, d, l, r changes

entity head is
    generic (
        -- Bounding box
        bounds: t_box := max_box;
        -- Start position of the head
        start_pos: t_pos;
        start_mot: t_mot;
        -- Tiles for the 4 orientations of head
        right_tile:    t_tile := snake_head_r;
        left_tile:     t_tile := snake_head_l;
        down_tile :    t_tile := snake_head_d;
        up_tile:       t_tile := snake_head_u;
        -- Tiles for the neck
        vertical_tile :  t_tile := snake_body_v;
        horizontal_tile: t_tile := snake_body_h;
        down_left_tile : t_tile := snake_body_dl;
        down_right_tile: t_tile := snake_body_dr;
        up_left_tile:    t_tile := snake_body_ul;
        up_right_tile:   t_tile := snake_body_ur
    );
    port(
        clk, rst: in std_logic;
        update: in std_logic;
        
        mot: in t_mot;
        
        head_pos: out t_pos := start_pos;
        neck_pos: out t_pos;
        head_tile, neck_tile: out t_tile
    );
end entity;

architecture Behavioral of head is
    constant start_neck_pos: t_pos := move(start_pos,      -start_mot);
    constant start_body_pos: t_pos := move(start_neck_pos, -start_mot);
    signal head_pos0: t_pos := start_pos;
    signal neck_pos0: t_pos := start_neck_pos;
    signal body_pos0: t_pos := start_body_pos;    
begin
    head_pos <= head_pos0;
    neck_pos <= neck_pos0;
    process (clk, rst) is
        variable pos: t_pos := start_pos;
        variable nb_d, hn_d: t_mot;
    begin
        if rst = '0' then -- active low
            head_pos0 <= start_pos;
            neck_pos0  <= start_neck_pos;
            --body_pos0  <= start_body_pos;
        elsif rising_edge(clk) and update = '1' then
            -- Head
            pos := head_pos0;
            if mot = mot_u then
                pos.y := pos.y - 1;
                head_tile <= up_tile;
            end if;
            if mot = mot_d then
                pos.y := pos.y + 1;
                head_tile <= down_tile;
            end if;
            if mot = mot_l  then
                pos.x := pos.x - 1;
                head_tile <= left_tile;
            end if;
            if mot = mot_r then
                pos.x := pos.x + 1;
                head_tile <= right_tile;
            end if;
            head_pos0 <= pos;
                
            -- Neck
            if pos /= head_pos0 then
                neck_pos0 <= head_pos0;
            end if;
            
            -- neck_body_delta = next neck - next body
            nb_d := direction(head_pos0 - neck_pos0);
            -- head_neck_delta = next head - next neck
            hn_d := direction(pos       - head_pos0);
            
            if    nb_d.x = "00" and hn_d.x = "00" then  -- body and head in the same column
                neck_tile <= vertical_tile;
            elsif nb_d.y = "00" and hn_d.y = "00" then  -- body and head in the same row
                neck_tile <= horizontal_tile;
            elsif nb_d.x = "00" and nb_d.y = "10" then  -- neck is on the top    of body
                if hn_d.x = "01" then                   -- head is on the right  of neck
                    neck_tile <= down_right_tile;
                else                                    -- head is on the left   of neck
                    neck_tile <= down_left_tile;
                end if;
            elsif nb_d.x = "00" and nb_d.y = "01" then  -- neck is on the bottom of body
                if hn_d.x = "01" then                   -- head is on the right  of neck
                    neck_tile <= up_right_tile;
                else                                    -- head is on the left   of neck
                    neck_tile <= up_left_tile;
                end if;
            elsif nb_d.x = "01" and nb_d.y = "00" then  -- neck is on the right  of body
                if hn_d.y = "10" then                   -- head is on the top    of neck
                    neck_tile <= up_left_tile;
                else                                    -- head is on the bottom of neck
                    neck_tile <= down_left_tile;
                end if;
            elsif nb_d.x = "10" and nb_d.y = "00" then  -- neck is on the left   of body
                if hn_d.y = "10" then                   -- head is on the top    of neck
                    neck_tile <= up_right_tile;
                else                                    -- head is on the bottom of neck
                    neck_tile <= down_right_tile;
                end if;
            else                                        -- unexpected
                neck_tile <= crate;
            end if;
            
        end if;
    end process;
end Behavioral;
