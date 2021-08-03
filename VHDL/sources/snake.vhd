library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity snake is
    generic (
        bounds: t_box;
        start_pos: t_pos;
        start_mot: t_mot;
        max_length: integer := 256
    );
    port(
        clk, rst:   in std_logic; -- rst: active low
        update:     in std_logic;
        eat:        in std_logic;
        dir:        in std_logic_vector(3 downto 0); -- direction U D L R
        head_pos, neck_pos, tail_pos:    out t_pos;
        head_tile, neck_tile, tail_tile: out t_tile
    );
end snake;

architecture Behavioral of snake is
    type SHIFT_REG is array (0 to max_length-1) of t_pos;

    constant start_neck_pos: t_pos := move(start_pos,      -start_mot);
    constant start_tail_pos: t_pos := move(start_neck_pos, -start_mot);
    constant start_body: SHIFT_REG := (0 => start_tail_pos, 1 => start_neck_pos, 2 => start_pos, others => zero_pos);

    signal head_pos0: t_pos := start_pos;
    signal neck_pos0: t_pos := start_neck_pos;
    signal tail_pos0: t_pos := start_tail_pos;
    
    signal shift: std_logic;
    signal candidate_mot: t_mot;
begin
    head_pos <= head_pos0;
    neck_pos <= neck_pos0;
    tail_pos <= tail_pos0;
    candidate_mot <= 
        mot_u when dir = "1000" else
        mot_d when dir = "0100" else
        mot_l when dir = "0010" else
        mot_r when dir = "0001" else
        mot_n;
    
    process (clk, rst) is
        variable snake_size: integer := 0;
        variable snake_body: SHIFT_REG := start_body;
        
        -- Head
        variable head_mot: t_mot;
        variable pos: t_pos := start_pos;
        
        -- Neck
        variable nb_d, hn_d: t_mot;
        
        -- Tail
        variable tail_mot: t_mot;
    begin
        if rst = '0' then -- active low
            -- Head
            head_mot := start_mot;
            head_pos0 <= start_pos;
            
            -- Neck
            neck_pos0 <= start_neck_pos;
            
            -- Tail
            tail_pos0 <= start_tail_pos;
            snake_body := start_body;
            snake_size := 3;
        elsif rising_edge(clk) and update = '1' then
            -- Head --
            if candidate_mot /= mot_n and
               (candidate_mot.x + head_mot.x) /= "11" and
               (candidate_mot.y + head_mot.y) /= "11" then
                head_mot := candidate_mot;
            end if;
            
            pos := head_pos0;
            if head_mot = mot_u then
                pos.y := pos.y - 1;
                if eat = '1' then
                    head_tile <= snake_head_bite_u;
                else
                    head_tile <= snake_head_u;
                end if;
            end if;
            if head_mot = mot_d then
                pos.y := pos.y + 1;
                if eat = '1' then
                    head_tile <= snake_head_bite_d;
                else
                    head_tile <= snake_head_d;
                end if;
            end if;
            if head_mot = mot_l  then
                pos.x := pos.x - 1;
                if eat = '1' then
                    head_tile <= snake_head_bite_l;
                else
                    head_tile <= snake_head_l;
                end if;
            end if;
            if head_mot = mot_r then
                pos.x := pos.x + 1;
                if eat = '1' then
                    head_tile <= snake_head_bite_r;
                else
                    head_tile <= snake_head_r;
                end if;
            end if;
            head_pos0 <= pos;
                
            -- Neck --
            if pos /= head_pos0 then
                neck_pos0 <= head_pos0;
            end if;
            
            -- neck_body_delta = next neck - next body
            nb_d := direction(head_pos0 - neck_pos0);
            -- head_neck_delta = next head - next neck
            hn_d := direction(pos       - head_pos0);
            
            if    nb_d.x = "00" and hn_d.x = "00" then  -- body and head in the same column
                neck_tile <= snake_body_v;
            elsif nb_d.y = "00" and hn_d.y = "00" then  -- body and head in the same row
                neck_tile <= snake_body_h;
            elsif nb_d.x = "00" and nb_d.y = "10" then  -- neck is on the top    of body
                if hn_d.x = "01" then                   -- head is on the right  of neck
                    neck_tile <= snake_body_dr;
                else                                    -- head is on the left   of neck
                    neck_tile <= snake_body_dl;
                end if;
            elsif nb_d.x = "00" and nb_d.y = "01" then  -- neck is on the bottom of body
                if hn_d.x = "01" then                   -- head is on the right  of neck
                    neck_tile <= snake_body_ur;
                else                                    -- head is on the left   of neck
                    neck_tile <= snake_body_ul;
                end if;
            elsif nb_d.x = "01" and nb_d.y = "00" then  -- neck is on the right  of body
                if hn_d.y = "10" then                   -- head is on the top    of neck
                    neck_tile <= snake_body_ul;
                else                                    -- head is on the bottom of neck
                    neck_tile <= snake_body_dl;
                end if;
            elsif nb_d.x = "10" and nb_d.y = "00" then  -- neck is on the left   of body
                if hn_d.y = "10" then                   -- head is on the top    of neck
                    neck_tile <= snake_body_ur;
                else                                    -- head is on the bottom of neck
                    neck_tile <= snake_body_dr;
                end if;
            else                                        -- unexpected
                neck_tile <= crate;
            end if;
            
            -- Body --
            -- Pop position from fifo
            if eat = '0' then -- TODO: check FIFO not empty
                snake_body := snake_body(1 to max_length-1) & zero_pos;
                if snake_size > 0 then
                    snake_size := snake_size - 1;
                    --empty <= '0';
                else
                    --empty <= '1';
                end if;
            end if;
            -- Push position in fifo
            snake_body(snake_size) := pos;
            if snake_size < max_length then
                snake_size := snake_size + 1;
                --full <= '0';
            else
                --full <= '1';
            end if;
            
            -- Tail --
            tail_pos0 <= snake_body(0);
            -- Calculate tail tile
            tail_mot := direction(snake_body(1) - snake_body(0));
            if    tail_mot = mot_u then    -- body moving up,    tail poiting down
                tail_tile <= snake_tail_d;
            elsif tail_mot = mot_d then    -- body moving down,  tail pointing up
                tail_tile <= snake_tail_u;
            elsif tail_mot = mot_l then    -- body moving left,  tail pointing right
                tail_tile <= snake_tail_r;
            elsif tail_mot = mot_r then    -- body moving right, tail pointing left
                tail_tile <= snake_tail_l;
            else                      -- unexpected
                tail_tile <= crate;
            end if;
        end if;
    end process;
end Behavioral;
