library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.vga.all;
use work.graphics_pkg.all;
use work.world_pkg.all;

entity vga_renderer is
generic (
    window: t_window;
    scale: integer   := 1                 -- exponential, 1 pixel is stretched to 2^(scale - 1) pixels
);
port( 
    pxl_clk: in std_logic;
    tile: in t_tile;
    pos: out t_pos;
    enable_write, enable_read: out std_logic; -- TODO: remove
    vga_hs, vga_vs: out std_logic;
    vga_r, vga_g, vga_b: out std_logic_vector(3 downto 0)
);
end vga_renderer;

architecture Behavioral of vga_renderer is
    -- MSB: tile t_posx, LSB: t_tile_offx
    signal pos_h: t_posh;
    -- MSB: tile t_posy, LSB: t_tile_offy
    signal pos_v: t_posv;
    
    signal visible: std_logic := '0';

    signal tile_offx: t_tile_offx := (others => '0');
    signal tile_offy: t_tile_offy := (others => '0');
    
    signal texture_data: std_logic_vector(95 downto 0) := (others => '0');
    signal pixel_data: std_logic_vector(11 downto 0) := (others => '0');

    -- Vga controller
    signal h_count_ctr, v_count_ctr: unsigned(11 downto 0);
    signal hs, vs: std_logic;
begin
    e_tileset_rom: entity work.tileset_rom 
        port map (
            tile_index => to_integer(unsigned(tile)),
            tile_offx => tile_offx,
            tile_offy => tile_offy,
            data => pixel_data
        );
    
    e_vga_controller: entity work.vga_controller
        generic map (
            h_polarity     => window.h_polarity,
            h_visible_area => window.h_visible_area,
            h_front_porch  => window.h_front_porch,
            h_sync_pulse   => window.h_sync_pulse,
            h_back_porch   => window.h_back_porch,
            h_total        => window.h_total,
            
            v_polarity     => window.v_polarity,
            v_visible_area => window.v_visible_area,
            v_front_porch  => window.v_front_porch,
            v_sync_pulse   => window.v_sync_pulse,
            v_back_porch   => window.v_back_porch,
            v_total        => window.v_total
        ) 
        port map(
            pxl_clk              => pxl_clk,
            hs                   => hs,
            vs                   => vs,
            h_count              => h_count_ctr,
            v_count              => v_count_ctr
        );
    
    pos_h <= h_count_ctr(t_posh'high+scale-1 downto scale-1);
    pos_v <= v_count_ctr(t_posv'high+scale-1 downto scale-1);
    
    vga_hs <= hs;
    vga_vs <= vs;

    visible <= '1' when 
        h_count_ctr < window.h_visible_area and
        v_count_ctr < window.v_visible_area
        else '0';

    pos <= (
        x => pos_h(t_posh'high downto t_tile_offx'length),
        y => pos_v(t_posv'high downto t_tile_offy'length)
    );

    tile_offx <= pos_h(t_tile_offx'high downto 0) when visible = '1' else (others => '0');
    tile_offy <= pos_v(t_tile_offy'high downto 0) when visible = '1' else (others => '0');

    enable_write <= '1' when 
        h_count_ctr(t_tile_offx'high+scale-1 downto 0) = (t_tile_offy'high+scale-1 downto 0 => '1') and 
        v_count_ctr(t_tile_offy'high+scale-1 downto 0) = (t_tile_offy'high+scale-1 downto 0 => '1')
        else '0';
    enable_read <= '1' when 
        h_count_ctr(t_tile_offx'high+scale-1 downto 0) = (t_tile_offy'high+scale-1 downto 0 => '0') and 
        v_count_ctr(t_tile_offy'high+scale-1 downto 0) = (t_tile_offy'high+scale-1 downto 0 => '0')
        else '0'; 
        
    process (pxl_clk) is
    begin
        if rising_edge(pxl_clk) then
            -- Set color values to 0 when out of the visible area
            vga_r <= (others => '0');
            vga_g <= (others => '0');
            vga_b <= (others => '0');
            -- Check inside visible area
            if visible = '1' then                   
                vga_r <= pixel_data(11 downto 8);
                vga_g <= pixel_data(7 downto 4);
                vga_b <= pixel_data(3 downto 0);
            end if;
        end if;
    end process;
end Behavioral;