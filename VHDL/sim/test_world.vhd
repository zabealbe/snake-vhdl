library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity test_world is
end test_world;

architecture Behavioral of test_world is
    signal clk, rst: std_logic := '0';
    signal add_pos, del_pos: t_pos := zero_pos;
    signal wr_en, rd_en: std_logic := '0';
    signal btype_in, btype_out: t_btype := empty;
begin
    world: entity work.world(Behavioral)
        port map (
            -- Write side
            wr_en => wr_en,
            in_pos => add_pos,
            btype_in => btype_in,
            
            -- Read side
            rd_en => rd_en,
            out_pos => del_pos,
            btype_out => btype_out,
            
            clk => clk,
            rst => rst
        );
    clk <= not clk after 10ns;
    process is
        variable pos1: t_pos := (x => to_unsigned(10, posx_bits), y => to_unsigned(10, posy_bits));
        variable pos2: t_pos := (x => to_unsigned(10, posx_bits), y => to_unsigned(10, posy_bits));
    begin
        -- Reset to initialize
        rst <= '1';
        wait for 40ns;
        rst <= '0';
        wr_en <= '1';
        rd_en <= '1';
        btype_in <= snake;
        add_pos <= pos1;
        del_pos <= pos1;
        wait for 40ns;
        wr_en <= '1';
        btype_in <= apple;
        add_pos <= pos2;
        del_pos <= pos2;
        wait for 40ns;
        wr_en <= '1';
        btype_in <= apple;
        add_pos <= pos1;
        del_pos <= pos1;
        wait for 40ns;
        rst <= '0';
    end process;
end Behavioral;
