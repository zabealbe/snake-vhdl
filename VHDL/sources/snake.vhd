library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity snake is
    generic (
        start_pos: t_pos;
        start_mot: t_mot;
        max_length: integer := 256
    );
    port(
        clk, rst:            in std_logic; -- rst: active low, syncronous
        eat, die, mov, tick: in std_logic;
        dir:                 in std_logic_vector(3 downto 0); -- direction U D L R
        head_pos, neck_pos, tail_pos:    out t_pos;
        head_tile, tail_tile: out t_tile;
        neck_tile: out t_tile := snake_body_h
    );
end snake;

architecture Behavioral of snake is
    type t_body is array (0 to max_length-1) of t_pos;
    
    signal ate: std_logic := '0';
    
    constant start_neck_pos: t_pos := move(start_pos,      -start_mot);
    constant start_tail_pos: t_pos := move(start_neck_pos, -start_mot);
    constant start_body: t_body := (0 => start_tail_pos, 1 => start_neck_pos, 2 => start_pos, others => zero_pos);

    signal head_mot, tail_mot: t_mot := start_mot;

    signal head_pos0: t_pos := start_pos;
    signal neck_pos0: t_pos := start_neck_pos;
    signal tail_pos0: t_pos := start_tail_pos;
    
    signal shift: std_logic;
    signal head_mot_next: t_mot := start_mot;
begin
    head_pos <= head_pos0;
    neck_pos <= neck_pos0;
    tail_pos <= tail_pos0;
    head_mot_next <= 
        mot_u when dir = "1000" and head_mot /= mot_d else
        mot_d when dir = "0100" and head_mot /= mot_u else
        mot_l when dir = "0010" and head_mot /= mot_r else
        mot_r when dir = "0001" and head_mot /= mot_l else
        head_mot;
    head_tile <=
        snake_head_bite_u when head_mot = mot_u and ate = '1' else
        snake_head_bite_d when head_mot = mot_d and ate = '1' else
        snake_head_bite_l when head_mot = mot_l and ate = '1' else
        snake_head_bite_r when head_mot = mot_r and ate = '1' else
        snake_head_bonk_u when head_mot = mot_u and die = '1' else
        snake_head_bonk_d when head_mot = mot_d and die = '1' else
        snake_head_bonk_l when head_mot = mot_l and die = '1' else
        snake_head_bonk_r when head_mot = mot_r and die = '1' else
        snake_head_u      when head_mot = mot_u else
        snake_head_d      when head_mot = mot_d else
        snake_head_l      when head_mot = mot_l else
        snake_head_r      when head_mot = mot_r;
    tail_tile <=
        snake_tail_d when tail_mot = mot_u else
        snake_tail_u when tail_mot = mot_d else
        snake_tail_r when tail_mot = mot_l else
        snake_tail_l when tail_mot = mot_r;
    process (clk, rst) is        
        -- Head
        variable pos: t_pos;
        -- Neck
        
        
        -- Body
        variable snake_size: integer   := 3;
        variable snake_body: t_body := start_body;
        
        -- Tail
    begin
        if rising_edge(clk) then
            if rst = '0' then
                ate <= '0';
             
                -- Head
                head_mot   <= start_mot;
                head_pos0  <= start_pos;
                
                -- Neck
                neck_pos0  <= start_neck_pos;
                neck_tile  <= snake_body_h;
                
                -- Body
                snake_size := 3;
                snake_body := start_body;
                
                -- Tail
                tail_mot   <= start_mot;
                tail_pos0  <= start_tail_pos;
            else
                if eat = '1' then
                    ate <= '1';
                end if;
                if mov = '1' then
                    -- CALCULATE NEW SNAKE STATE
                    -- Head --    
                    head_mot <= head_mot_next;
                    head_pos0 <= move(head_pos0, head_mot_next);
                        
                    -- Neck --
                    neck_pos0 <= head_pos0;
                    
                    if head_mot = head_mot_next  then  -- body and head in a straight line
                        if is_h(head_mot) then           -- same row
                            neck_tile <= snake_body_h;
                        else                             -- same column
                            neck_tile <= snake_body_v;
                        end if;
                    elsif head_mot = mot_u then                 -- neck is on the top    of body
                        if head_mot_next = mot_r then           -- head is on the right  of neck
                            neck_tile <= snake_body_dr;
                        else                                    -- head is on the left   of neck
                            neck_tile <= snake_body_dl;
                        end if;
                    elsif head_mot = mot_d then                 -- neck is on the bottom of body
                        if head_mot_next = mot_r then           -- head is on the right  of neck
                            neck_tile <= snake_body_ur;
                        else                                    -- head is on the left   of neck
                            neck_tile <= snake_body_ul;
                        end if;
                    elsif head_mot = mot_r then                 -- neck is on the right  of body
                        if head_mot_next = mot_u then           -- head is on the top    of neck
                            neck_tile <= snake_body_ul;
                        else                                    -- head is on the bottom of neck
                            neck_tile <= snake_body_dl;
                        end if;
                    elsif head_mot = mot_l then                 -- neck is on the left   of body
                        if head_mot_next = mot_d then           -- head is on the bottom of neck
                            neck_tile <= snake_body_dr;
                        else                                    -- head is on the bottom of neck
                            neck_tile <= snake_body_ur;
                        end if;
                    else                                        -- unexpected
                        neck_tile <= crate;
                    end if;
                    
                    -- Body --
                    if ate = '1' then
                        snake_size := snake_size + 1;
                        ate <= '0';
                    else
                        snake_body := snake_body(1 to t_body'high) & zero_pos;
                    end if;                    
                    snake_body(snake_size-1) := move(head_pos0, head_mot_next);
                    
                    -- Tail --
                    tail_pos0 <= snake_body(0);
                    tail_mot  <= direction(snake_body(1) - snake_body(0));
                end if;
            end if;
        end if;
    end process;
end Behavioral;
