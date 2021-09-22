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

library ieee;
use ieee.std_logic_1164.all;
use work.world_pkg.all;

package vga is
    type t_window is record
        pxl_clk   : real;
        
        h_polarity: std_logic;
        -- values are in pixels
        h_visible_area: integer;
        h_front_porch: integer;
        h_sync_pulse: integer;
        h_back_porch: integer;
        h_total: integer;
        
        v_polarity: std_logic;
        -- values are in pixels
        v_visible_area: integer;
        v_front_porch: integer;
        v_sync_pulse: integer;
        v_back_porch: integer;
        v_total: integer;
    end record;
    
    constant window_640x480: t_window := (
        pxl_clk        => 25.175,
    
        h_polarity     => '0',
        
        h_visible_area => 640,
        h_front_porch  => 16,
        h_sync_pulse   => 96,
        h_back_porch   => 48,
        h_total        => 800,
        
        v_polarity     => '0',
        
        v_visible_area => 480,
        v_front_porch  => 10,
        v_sync_pulse   => 2,
        v_back_porch   => 33,
        v_total        => 525
    );

    constant window_1280x1024: t_window := (
        pxl_clk        => 108.0,

        h_polarity     => '1',
    
        h_visible_area => 1280,
        h_front_porch  => 48,
        h_sync_pulse   => 112,
        h_back_porch   => 248,
        h_total        => 1688,
        
        v_polarity     => '1',

        v_visible_area => 1024,
        v_front_porch  => 1,
        v_sync_pulse   => 3,
        v_back_porch   => 38,
        v_total        => 1066
    );
    
    constant window_1920x1080: t_window := (
        pxl_clk        => 148.5,

        h_polarity     => '1',
    
        h_visible_area => 1920,
        h_front_porch  => 88,
        h_sync_pulse   => 44,
        h_back_porch   => 148,
        h_total        => 2200,
        
        v_polarity     => '1',

        v_visible_area => 1080,
        v_front_porch  => 4,
        v_sync_pulse   => 5,
        v_back_porch   => 36,
        v_total        => 1125
    );
end package;
