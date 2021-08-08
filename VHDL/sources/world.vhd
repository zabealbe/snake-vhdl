library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

-- World module
-- holds the current state of the interactive tile grid
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
        clk, rst: in std_logic;
        
        pos_in, pos_out: in t_pos;
        wr_en, rd_en: in std_logic;
        
        visible: out std_logic;
        tile_in: in t_tile;
        tile_out: out t_tile        
    );
end world;

architecture Behavioral of world is
        type REGW is array (0 to to_integer(bounds.br.x - bounds.tl.x)) of t_tile;
        type REG  is array (0 to to_integer(bounds.br.y - bounds.tl.y)) of REGW;
        signal memory: REG := (others => (others => def_tile));
        signal pos_in_rel, pos_out_rel: t_pos; -- Relative position to border.tl
        signal visible_rd, visible_wr: std_logic;
    begin
    e_window_rd: entity work.window(Behavioral)
        generic map (
            bounds => bounds
        )
        port map (
            pos => pos_out,
            visible => visible_rd
        );
    e_window_wr: entity work.window(Behavioral)
        generic map (
            bounds => bounds
        )
        port map (
            pos => pos_in,
            visible => visible_wr
        );
    visible <= visible_rd;
    pos_in_rel <= pos_in - bounds.tl;
    pos_out_rel <= pos_out - bounds.tl;
    process (clk, rst) is
    begin
        if rising_edge(clk) then
            if rst = '0' then
                memory <= (others => (others => def_tile));
            else
                -- Write a block to the world
                if wr_en = '1' and visible_wr = '1' then
                    memory
                        (to_integer(pos_in_rel.y))
                        (to_integer(pos_in_rel.x))
                        <= tile_in;
                end if;
                -- Read a block from the world
                if rd_en = '1' and visible_rd = '1' then
                    tile_out <= memory
                        (to_integer(pos_out_rel.y))
                        (to_integer(pos_out_rel.x))
                        ;
                end if;
            end if;
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
    a <= std_logic_vector(pos_in.x(2 downto 0) & pos_in.y(2 downto 0));
    we <= wr_en;
end IP;
