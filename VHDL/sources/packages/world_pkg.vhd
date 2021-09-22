library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

-- World package
-- definitions and macros for a up to 2D coordinate system
package world_pkg is
    -- Representation of different tile types
    constant tile_bits: integer := 6; -- Bits used to represent a tile
    subtype t_tile is std_logic_vector(tile_bits-1 downto 0);
    constant empty:          t_tile := "000000";
    -- Alphanumeric tiles
    constant tile_a:         t_tile := "000001"; -- A to Z
    constant tile_b:         t_tile := "000010";
    constant tile_c:         t_tile := "000011";
    constant tile_d:         t_tile := "000100";
    constant tile_e:         t_tile := "000101";
    constant tile_f:         t_tile := "000110";
    constant tile_g:         t_tile := "000111";
    constant tile_h:         t_tile := "001000";
    constant tile_i:         t_tile := "001001";
    constant tile_j:         t_tile := "001010";
    constant tile_k:         t_tile := "001011";
    constant tile_l:         t_tile := "001100";
    constant tile_m:         t_tile := "001101";
    constant tile_n:         t_tile := "001110";
    constant tile_o:         t_tile := "001111";
    constant tile_p:         t_tile := "010000";
    constant tile_q:         t_tile := "010001";
    constant tile_r:         t_tile := "010010";
    constant tile_s:         t_tile := "010011";
    constant tile_t:         t_tile := "010100";
    constant tile_u:         t_tile := "010101";
    constant tile_v:         t_tile := "010110";
    constant tile_w:         t_tile := "010111";
    constant tile_x:         t_tile := "011000";
    constant tile_y:         t_tile := "011001";
    constant tile_z:         t_tile := "011010";
    constant tile_0:         t_tile := "011011"; -- 0 to 9
    constant tile_1:         t_tile := "011100";
    constant tile_2:         t_tile := "011101";
    constant tile_3:         t_tile := "011110";
    constant tile_4:         t_tile := "011111";
    constant tile_5:         t_tile := "100000";
    constant tile_6:         t_tile := "100001";
    constant tile_7:         t_tile := "100010";
    constant tile_8:         t_tile := "100011";
    constant tile_9:         t_tile := "100100";
    
    -- World tiles
    constant short_grass:    t_tile := "100101";
    constant tall_grass:     t_tile := "100110";
    constant apple:          t_tile := "100111";
    constant crate:          t_tile := "101000";
    
    -- Snake tiles
    constant snake_head_d:   t_tile := "101001";      -- Snake head pointing downwards
    constant snake_head_l:   t_tile := "101010";      -- Snake head pointing left
    constant snake_head_u:   t_tile := "101011";      -- Snake head pointing upwards
    constant snake_head_r:   t_tile := "101100";      -- Snake head pointing right
    
    constant snake_body_dr:  t_tile := "101101";      -- Snake body pointing down and bending right
    constant snake_body_dl:  t_tile := "101110";      -- Snake body pointing down and bending left
    constant snake_body_ur:  t_tile := "101111";      -- Snake body pointing up   and bending right
    constant snake_body_ul:  t_tile := "110000";      -- Snake body pointing up   and bending left
    
    constant snake_tail_d:   t_tile := "110001";      -- Snake tail pointing downwards
    constant snake_tail_l:   t_tile := "110010";      -- Snake tail pointing left
    constant snake_tail_u:   t_tile := "110011";      -- Snake tail pointing upwards
    constant snake_tail_r:   t_tile := "110100";      -- Snake tail pointing right
    
    constant snake_body_v:   t_tile := "110101";      -- Snake body vertical
    constant snake_body_h:   t_tile := "110110";      -- Snake body horizontal
    
    constant snake_head_bite_d:  t_tile := "110111"; -- Snake head biting pointing down
    constant snake_head_bite_l:  t_tile := "111000"; -- Snake head biting pointing left
    constant snake_head_bite_u:  t_tile := "111001"; -- Snake head biting pointing up
    constant snake_head_bite_r:  t_tile := "111010"; -- Snake head biting pointing right
    
    constant snake_head_bonk_d:  t_tile := "111011"; -- Snake head bonked pointing down
    constant snake_head_bonk_l:  t_tile := "111100"; -- Snake head bonked pointing left
    constant snake_head_bonk_u:  t_tile := "111101"; -- Snake head bonked pointing up
    constant snake_head_bonk_r:  t_tile := "111110"; -- Snake head bonked pointing right
    
    -- Representation of x coordinate
    constant posx_bits: integer := 7; -- n of bits
    subtype t_posx is unsigned(posx_bits-1 downto 0);
    constant min_x: t_posx :=  (t_posx'high => '1', others => '0');  -- Smallest representable x position
    constant max_x: t_posx :=  (t_posx'high => '0', others => '1');  -- Biggest  representable x position
    constant zero_x: t_posx := (others => '0'); -- X position of origin

    -- Representation of y coordinate
    constant posy_bits: integer := 7; -- n of bits
    subtype t_posy is unsigned(posy_bits-1 downto 0);
    constant min_y: t_posy :=  (t_posy'high => '1', others => '0');  -- Smallest representable y position
    constant max_y: t_posy :=  (t_posy'high => '0', others => '1');  -- Biggest  representable y position
    constant zero_y: t_posy := (others => '0'); -- Y position of origin

    -- 2D position defined by two coordinates
    type t_pos is record
        x: t_posx;
        y: t_posy;
    end record;
    constant min_pos: t_pos := (x => min_x, y => min_y);    -- Smallest representable position
    constant max_pos: t_pos := (x => max_x, y => max_y);    -- Biggest  representable position
    constant zero_pos: t_pos := (x => zero_x, y => zero_y); -- Position of origin
    function to_pos(x, y: integer) return t_pos;               -- Position constructor
    function "+" (L, R: t_pos) return t_pos;                -- Position vector algebra
    function "-" (L, R: t_pos) return t_pos;
    function "/" (L: t_pos; R: integer) return t_pos;

    -- 2D direction represented as a versor centered around the origin
    type t_mot is record
        x: signed(1 downto 0);
        y: signed(1 downto 0);
    end record;
    constant mot_n: t_mot := (x => "00", y => "00"); -- None  direction
    constant mot_u: t_mot := (x => "00", y => "11"); -- Up    direction
    constant mot_d: t_mot := (x => "00", y => "01"); -- Down  direction
    constant mot_r: t_mot := (x => "01", y => "00"); -- Right direction
    constant mot_l: t_mot := (x => "11", y => "00"); -- Left  direction
    function move (pos: t_pos; mot: t_mot) return t_pos;
    function is_h (mot: t_mot) return boolean;
    function is_v (mot: t_mot) return boolean;
    function "-" (mot: t_mot) return t_mot;          -- Invert mot
    function direction(pos: t_pos) return t_mot;     -- Normalizes position

    -- Box defined by TOP LEFT (tl) and BOTTOM RIGHT (br) corners
    type t_box is record
        tl: t_pos; -- Top Left
        br: t_pos; -- Bottom Right
    end record;
    constant max_box: t_box := (tl => min_pos, br => max_pos); -- Biggest representable box
end package;

package body world_pkg is
    -- Vector from tuple of integers
    function to_pos(x, y: integer) return t_pos is
    begin
        return (x => to_unsigned(x, t_posx'length), y => to_unsigned(y, t_posy'length));
    end function;
    
    -- Vector addition
    function "+" (L, R: t_pos) return t_pos is
    begin
        return (x => L.x + R.x, y => L.y + R.y);
    end function;
   
    -- Vector subtraction
    function "-" (L, R: t_pos) return t_pos is
    begin
        return (x => L.x - R.x, y => L.y - R.y);
    end function;
    
    function move (pos: t_pos; mot: t_mot) return t_pos is
    begin
        return (x => unsigned(signed(pos.x) + mot.x), y => unsigned(signed(pos.y) + mot.y));
    end function;
    
    function is_h (mot: t_mot) return boolean is
    begin
        return mot.x(0) = '1';
    end function;
    
    function is_v (mot: t_mot) return boolean is
    begin
        return mot.y(0) = '1';
    end function;
           
    function "-" (mot: t_mot) return t_mot is
    begin
        return (x => -mot.x, y => -mot.y);
    end function;
    
    function "/" (L: t_pos; R: integer) return t_pos is
    begin
        return (x => L.x / R, y => L.y / R);
    end function;
    
    function direction(pos: t_pos) return t_mot is
    begin
        return (
            x => (1 => pos.x(t_posx'high), 0 => pos.x(t_posx'high) or pos.x(0)), 
            y => (1 => pos.y(t_posy'high), 0 => pos.y(t_posy'high) or pos.y(0)));
    end function;
end package body;