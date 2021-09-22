library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.world_pkg.all;

entity test_vga_renderer is
end test_vga_renderer;

architecture Behavioral of test_vga_renderer is
    signal clk, pixel_clk: std_logic;
    signal vga_hs, vga_vs: std_logic;
    signal vga_r, vga_g, vga_b: std_logic_vector(3 downto 0);

    function to_bstring(sl: std_logic) return string is
        variable sl_str_v: string(1 to 3);  -- std_logic image with quotes around
        begin
        sl_str_v := std_logic'image(sl);
        return "" & sl_str_v(2);  -- "" & character to get string
    end function;
        
    function to_bstring(slv: std_logic_vector) return string is
        alias    slv_norm: std_logic_vector(1 to slv'length) is slv;
        variable sl_str_v: string(1 to 1);  -- String of std_logic
        variable res_v: string(1 to slv'length);
    begin
        for idx in slv_norm'range loop
            sl_str_v := to_bstring(slv_norm(idx));
            res_v(idx) := sl_str_v(1);
        end loop;
        return res_v;
    end function;
begin
    e_vga_renderer: entity work.vga_renderer port map(
        clk => pixel_clk,
        vga_hs => vga_hs,
        vga_vs => vga_vs,
        vga_r => vga_r,
        vga_g => vga_g,
        vga_b => vga_b
    );
    
    clk <= not clk after 19.86ns;
    process (pixel_clk) is
        file simulation: text is out "vga.simulation";
        variable l: line;  
    begin
        if rising_edge(pixel_clk) then
            write(l, now);
            write(l, string'(" "));
            write(l, to_bstring(vga_hs));
            write(l, string'(" "));
            write(l, to_bstring(vga_vs));
            write(l, string'(" "));
            write(l, to_bstring(vga_r));
            write(l, string'(" "));
            write(l, to_bstring(vga_g));
            write(l, string'(" "));
            write(l, to_bstring(vga_b));
            writeline(simulation, l);
        end if;
    end process;
end Behavioral;