library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity vga_controller is
generic (
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
    v_total: integer
);
port( 
    clk: in std_logic;
    hs, vs: out std_logic;
    h_count: out integer range 0 to h_total - 1;
    v_count: out integer range 0 to v_total - 1
);
end vga_controller;

architecture Behavioral of vga_controller is
    constant h_pre_sync: integer := h_visible_area + h_front_porch;
    constant h_post_sync: integer := h_visible_area + h_front_porch + h_sync_pulse;
    
    constant v_pre_sync: integer := v_visible_area + v_front_porch;
    constant v_post_sync: integer := v_visible_area + v_front_porch + v_sync_pulse;
    
    signal h_count_internal: integer range 0 to h_total - 1 := 0;
    signal v_count_internal: integer range 0 to v_total - 1 := 0;
    
    signal h_rst, h_init, h_enable, h_tc: std_logic := '0';
    signal v_rst, v_init, v_enable, v_tc: std_logic := '0';
begin
    h_enable <= '1';
    v_enable <= h_tc;

    h_counter: entity work.counter generic map (max => h_total - 1) port map (
        clk => clk, 
        rst => h_rst, 
        init => h_init, 
        enable => h_enable, 
        tc => h_tc, 
        count => h_count_internal
    );

    v_counter: entity work.counter generic map (max => v_total - 1) port map (
        clk => clk,
        rst => v_rst,
        init => v_init,
        enable => v_enable,
        tc => v_tc,
        count => v_count_internal
    );

    h_count <= h_count_internal;
    v_count <= v_count_internal;
    
    hs <= '0' when h_count_internal >= h_pre_sync and h_count_internal < h_post_sync else '1';
    vs <= '0' when v_count_internal >= v_pre_sync and v_count_internal < v_post_sync else '1';
end Behavioral;