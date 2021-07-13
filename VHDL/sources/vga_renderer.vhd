library ieee;
use ieee.numeric_std.all;

package vga is
    type t_window is record
        -- values are in pixels
        h_visible_area: integer;
        h_front_porch: integer;
        h_sync_pulse: integer;
        h_back_porch: integer;
        h_total: integer;
        
        -- values are in pixels
        v_visible_area: integer;
        v_front_porch: integer;
        v_sync_pulse: integer;
        v_back_porch: integer;
        v_total: integer;
    end record;
    
    constant window_640x480: t_window := (
        h_visible_area => 640,
        h_front_porch => 16,
        h_sync_pulse => 96,
        h_back_porch => 48,
        h_total => 800,
        
        v_visible_area => 480,
        v_front_porch => 10,
        v_sync_pulse => 2,
        v_back_porch => 33,
        v_total => 525
    );
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.vga.all;
use work.world_pkg.all;

entity vga_renderer is
generic (
    window: t_window := window_640x480;
    
    -- values are in pixels
    tile_size: integer := 32
    -- x_tile_space: integer := 25; -- 800 // 32
    -- y_tile_space: integer := 18 -- 600 // 32
);
port( 
    clk: in std_logic;
    tile: in t_tile;
    pos: out t_pos;
    vga_hs, vga_vs: out std_logic;
    vga_r, vga_g, vga_b: out std_logic_vector(3 downto 0)
);
end vga_renderer;

architecture Behavioral of vga_renderer is
    signal h_count: integer range 0 to window.h_total - 1 := 0;
    signal v_count: integer range 0 to window.v_total - 1 := 0;

    signal h_visible: std_logic := '0';
    signal v_visible: std_logic := '0';

    signal x_tile: t_posx;
    signal y_tile: t_posy;

    signal x_tile_offset: integer range 0 to tile_size - 1 := 0;
    signal y_tile_offset: integer range 0 to tile_size - 1 := 0;

    signal sheet_tile_type: integer range 0 to work.sheet_rom'width / tile_size - 1 := 2; 
    signal sheet_index: integer range 0 to work.sheet_rom'size - 1 := 0;
    signal sheet_data: std_logic_vector(11 downto 0) := (others => '0');
    
    signal alpha_tile_type: integer range 0 to work.alpha_rom'width / tile_size - 1 := 0;
    signal alpha_index: integer range 0 to work.alpha_rom'size - 1 := 0;
    signal alpha_data: std_logic_vector(11 downto 0) := (others => '0');

    signal title_index: integer range 0 to work.title_rom'size - 1 := 0;

    signal hs, vs: std_logic := '0';
begin
    e_sheet_rom: entity work.sheet_rom port map (
        index => sheet_index,
        data => sheet_data
    );

    e_alpha_rom: entity work.alpha_rom port map (
        index => alpha_index,
        data => alpha_data
    );

    --e_title_rom: entity work.title_rom port map (
    --    index => title_index,
    --    data => title_data
    --);

    e_vga_controller: entity work.vga_controller
    generic map (
        h_visible_area => window.h_visible_area,
        h_front_porch  => window.h_front_porch,
        h_sync_pulse   => window.h_sync_pulse,
        h_back_porch   => window.h_back_porch,
        h_total        => window.h_total,
        v_visible_area => window.v_visible_area,
        v_front_porch  => window.v_front_porch,
        v_sync_pulse   => window.v_sync_pulse,
        v_back_porch   => window.v_back_porch,
        v_total        => window.v_total
    ) 
    port map(
        clk            => clk,
        hs             => hs,
        vs             => vs,
        h_count        => h_count,
        v_count        => v_count
    );

    vga_hs <= hs;
    vga_vs <= vs;

    h_visible <= '1' when h_count < window.h_visible_area else '0';
    v_visible <= '1' when v_count < window.v_visible_area else '0';

    x_tile <= to_unsigned(h_count / tile_size, posx_bits) when h_visible = '1'
        else zero_x;
    y_tile <= to_unsigned(v_count / tile_size, posy_bits) when v_visible = '1'
        else zero_y;

    pos <= (
        x => x_tile,
        y => y_tile
    );

    x_tile_offset <= h_count mod tile_size when h_visible = '1' else 0;
    y_tile_offset <= v_count mod tile_size when v_visible = '1' else 0;
    
    -- title_index <= x_tile + (y_tile * work.title_rom'width) when h_visible = '1' and v_visible = '1' else 0;

    --sheet_tile_type <= to_integer(unsigned(title_data(4 downto 0))) 
    --    when title_data(6) = '0' and not is_x(title_data(4 downto 0)) else 0;
    
    --alpha_tile_type <= to_integer(unsigned(title_data(5 downto 0))) 
    --    when title_data(6) = '1' and not is_x(title_data(5 downto 0)) else 0;

    sheet_index <= (sheet_tile_type * tile_size) + x_tile_offset + (y_tile_offset * work.sheet_rom'width);
    alpha_index <= (alpha_tile_type * tile_size) + x_tile_offset + (y_tile_offset * work.alpha_rom'width);

    process (clk) is
    begin
        vga_r <= (others => '0');
        vga_g <= (others => '0');
        vga_b <= (others => '0');
        if falling_edge(clk) then
            if h_visible = '1' and v_visible = '1' then
                if tile(tile'high(1)) = '1' then -- Check MSB
                    vga_r <= alpha_data(11 downto 8);
                    vga_g <= alpha_data(7 downto 4);
                    vga_b <= alpha_data(3 downto 0);
                else         
                    vga_r <= sheet_data(11 downto 8);
                    vga_g <= sheet_data(7 downto 4);
                    vga_b <= sheet_data(3 downto 0);
                end if;
            end if;
            if h_count = window.h_total - 1 and v_count = window.v_total - 1 then
                report "Created frame!";
            end if;
        end if;
    end process;
end Behavioral;