library ieee;
use ieee.numeric_std.all;
use work.world_pkg.all;

package graphics_pkg is   
    -- Representation of tile offset along x coordinate
    constant tile_offx_bits: integer := 3;        -- Number of bits
    subtype t_tile_offx
        is unsigned(tile_offx_bits - 1 downto 0); -- Horizontal tile offset
    
    -- Representation of tile offset along y coordinate
    constant tile_offy_bits: integer := 3;        -- Number of bits                                                           
    subtype t_tile_offy
        is unsigned(tile_offy_bits - 1 downto 0); -- Vertical   tile offset
        
    -- Representation pixel h coordinate
    constant posh_bits: integer :=
        posx_bits +                               -- Number of bits for tile pos
        tile_offx_bits;                           -- Number of bits for tile offset
    subtype t_posh
        is unsigned(posh_bits - 1 downto 0);      -- Horizontal position within the display
        
    -- Representation pixel v coordinate
    constant posv_bits: integer :=
        posy_bits +                               -- Number of bits for tile pos
        tile_offy_bits;                           -- Number of bits for tile offset
    subtype t_posv 
        is unsigned(posv_bits - 1 downto 0);      -- Vertical   position within the display
        
    -- Useful macros --

    -- Smallest representable pixel  coordinates
    constant min_h: t_posh := (others => '0');
    constant min_v: t_posv := (others => '0');
    -- Biggest  representable coordinates
    constant max_h: t_posh := (others => '1');
    constant max_v: t_posv := (others => '1');
    -- Zero tile offset
    constant zero_tile_offx: t_tile_offx := (others => '0');
    constant zero_tile_offy: t_tile_offy := (others => '0');
    -- Max  tile offset
    constant max_tile_offx: t_tile_offx := (others => '1');
    constant max_tile_offy: t_tile_offy := (others => '1');
    -- Min  tile offset
    constant min_tile_offx: t_tile_offx := (others => '0');
    constant min_tile_offy: t_tile_offy := (others => '0');
end package;