library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.world_pkg.all;

entity vga_controller is
generic (
    h_polarity: std_logic;
    -- values are in pixels
    h_visible_area: natural;
    h_front_porch: natural;
    h_sync_pulse: natural;
    h_back_porch: natural;
    h_total: natural;
    
    v_polarity: std_logic;
    -- values are in pixels
    v_visible_area: natural;
    v_front_porch: natural;
    v_sync_pulse: natural;
    v_back_porch: natural;
    v_total: natural
);
port( 
    pxl_clk: in std_logic;
    hs, vs: out std_logic;
    h_count: out unsigned(11 downto 0) := (others => '0');
    v_count: out unsigned(11 downto 0) := (others => '0')
);
end vga_controller;

architecture Behavioral of vga_controller is
    constant h_pre_sync: integer := h_visible_area + h_front_porch;
    constant h_post_sync: integer := h_visible_area + h_front_porch + h_sync_pulse;
    
    constant v_pre_sync: integer := v_visible_area + v_front_porch;
    constant v_post_sync: integer := v_visible_area + v_front_porch + v_sync_pulse;
    
    signal h_count_internal: unsigned(11 downto 0) := (others => '0');
    signal v_count_internal: unsigned(11 downto 0) := (others => '0');
    
    signal h_rst, h_init, h_enable, h_tc: std_logic := '0';
    signal v_rst, v_init, v_tc: std_logic := '0';
begin
    h_count <= h_count_internal;
    v_count <= v_count_internal;
    
    hs <= h_polarity when h_count_internal >= h_pre_sync and h_count_internal < h_post_sync 
        else not h_polarity;
    vs <= v_polarity when v_count_internal >= v_pre_sync and v_count_internal < v_post_sync
        else not h_polarity;
    
    -- Horizontal counter
    process (pxl_clk)
    begin
        if (rising_edge(pxl_clk)) then
            if (h_count_internal = (h_total - 1)) then
                h_count_internal <= (others =>'0');
            else
                h_count_internal <= h_count_internal + 1;
            end if;
        end if;
    end process;
    
    -- Vertical counter
    process (pxl_clk)
    begin
        if (rising_edge(pxl_clk)) then
            if ((h_count_internal = (h_total - 1)) and (v_count_internal = (v_total - 1))) then
                v_count_internal <= (others =>'0');
            elsif (h_count_internal = (h_total - 1)) then
                v_count_internal <= v_count_internal + 1;
            end if;
        end if;
    end process;
end Behavioral;