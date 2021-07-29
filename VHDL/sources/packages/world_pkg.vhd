library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

-- World package
-- definitions and macros for a up to 2D coordinate system
package world_pkg is
    -- Representation of different tile types
    constant tile_bits: integer := 6; -- Bits used to represent a tile
    subtype t_tile is std_logic_vector(tile_bits-1 downto 0);
    constant empty: t_tile := "000000";
    constant grass: t_tile := "100110";
    constant apple: t_tile := "100111";
    constant crate: t_tile := "101000";
    constant snake: t_tile := "101001";
    
    -- Representation of x coordinate
    constant posx_bits: integer := 5; -- n of bits
    subtype t_posx is unsigned(posx_bits-1 downto 0);
    
    -- Representation of y coordinate
    constant posy_bits: integer := 5; -- n of bits
    subtype t_posy is unsigned(posy_bits-1 downto 0);
    
    -- 2D position defined by two coordinates
    type t_pos is record
        x: t_posx;
        y: t_posy;
    end record;
    
    -- Box defined by TOP LEFT (tl) and BOTTOM RIGHT (br) corners
    type t_box is record
        tl: t_pos; -- Top Left
        br: t_pos; -- Bottom Right
    end record;
    
    -- Useful macros --

    -- Smallest representable coordinates
    constant min_x: t_posx := (others => '0');
    constant min_y: t_posy := (others => '0');
    constant min_pos: t_pos := (x => min_x, y => min_y);
    -- Biggest  representable coordinates
    constant max_x: t_posx := (others => '1');
    constant max_y: t_posy := (others => '1');
    constant max_pos: t_pos := (x => max_x, y => max_y);
    -- Coordinates of origin
    constant zero_x: t_posx := (others => '0');
    constant zero_y: t_posy := (others => '0');
    constant zero_pos: t_pos := (x => zero_x, y => zero_y);
    -- Biggest representable box
    constant max_box: t_box := (tl => min_pos, br => max_pos);
end package;