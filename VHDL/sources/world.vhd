library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

-- World module
-- holds the current state of the tile grid
--   rst  -> asyncronous reset pin (active-hight)
--           put reset to '1' for at least 1 clock cycle before
--           using this module

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity world is
    generic (
        bounds: t_box := max_box; -- Border of the world
        def_tile: t_tile := empty -- Default tile type
    );
    port (
        in_pos:  in t_pos;
        out_pos: in t_pos;
        wr_en, rd_en: in std_logic;
        
        tile_in: in t_tile;
        tile_out: out t_tile;
        
        clk, rst: in std_logic
    );
end world;

architecture Behavioral of world is
        type REGW is array (0 to to_integer(max_y)) of t_tile;
        type REG is array (0 to to_integer(max_x)) of REGW;
        signal memory: REG := (others => (others => def_tile));
    begin
    tile_out <= memory
        (to_integer(out_pos.x))
        (to_integer(out_pos.y))
        ;
    process (clk, rst) is
    begin
        if rst = '0' then
            memory <= (others => (others => def_tile));
        elsif rising_edge(clk) then
            -- Change a block in the world
            if wr_en = '1' then
                memory
                    (to_integer(in_pos.x))
                    (to_integer(in_pos.y))
                    <= tile_in;
            end if;
            -- Read a block from the world
            --if rd_en = '1' then
            --    tile_out <= memory
            --        (to_integer(out_pos.x))
            --        (to_integer(out_pos.y))
            --        ;
            --end if;
        end if;
    end process;
end Behavioral;

architecture IP of world is
    component dist_mem_gen_0
        port (
            a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            spo : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
    end component;
    signal a: std_logic_vector(5 downto 0);
    signal we: std_logic;
    begin
    fifo: dist_mem_gen_0
        port map(
            a => a,
            d => tile_in,
            clk => clk,
            we => we,
            spo => tile_out
        );
    a <= std_logic_vector(in_pos.x(2 downto 0) & in_pos.y(2 downto 0));
    we <= wr_en;
end IP;
