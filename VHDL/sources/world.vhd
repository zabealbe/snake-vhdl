library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- World package
-- definitions and macros for a up to 2D coordinate system

package world_pkg is
    -- Representation of x coordinate
    constant posx_bits: integer := 4; -- n of bits
    subtype t_posx is unsigned(posx_bits-1 downto 0);
    
    -- Representation of y coordinate
    constant posy_bits: integer := 4; -- n of bits
    subtype t_posy is unsigned(posy_bits-1 downto 0);
    
    -- 2D position defined by two coordinates
    type t_pos is record
        x: t_posx;
        y: t_posy;
    end record;
    
    -- Box defined by TOP LEFT (tl) and BOTTOM RIGHT (br) corners
    type t_box is record
        tl: t_pos; -- Top Left
        br: t_pos; -- Bottom Right
    end record;
    
    -- Block type
    subtype t_tile is std_logic_vector(3 downto 0);
    constant empty: t_tile := "0000";
    constant snake: t_tile := "0001";
    constant apple: t_tile := "0010";
    constant crate: t_tile := "0011";
    
    -- Useful macros --

    -- Smallest representable coordinates
    constant min_x: t_posx := (others => '0');
    constant min_y: t_posy := (others => '0');
    constant min_pos: t_pos := (x => min_x, y => min_y);
    -- Biggest  representable coordinates
    constant max_x: t_posx := (others => '1');
    constant max_y: t_posy := (others => '1');
    constant max_pos: t_pos := (x => max_x, y => max_y);
    -- Coordinates of origin
    constant zero_x: t_posx := (others => '0');
    constant zero_y: t_posy := (others => '0');
    constant zero_pos: t_pos := (x => zero_x, y => zero_y);
    -- Biggest representable box
    constant max_box: t_box := (tl => min_pos, br => max_pos);
end package;

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
        border: t_box := max_box
    );
    port (
        in_pos: t_pos;
        out_pos: t_pos;
        wr_en, rd_en: in std_logic;
        
        tile_in: in t_tile;
        tile_out: out t_tile;
        
        clk, rst: in std_logic
    );
end world;

architecture Behavioral of world is
        type REGW is array (0 to to_integer(max_y)) of t_tile;
        type REG is array (0 to to_integer(max_x)) of REGW;
        signal memory: REG;
    begin
    process (clk, rst) is
    begin
        if rst = '1' then
            memory <= (others => (others => empty));
        elsif rising_edge(clk) then
            -- Change a block in the world
            if wr_en = '1' then
                memory
                    (to_integer(in_pos.x))
                    (to_integer(in_pos.y))
                    <= tile_in;
            end if;
            -- Read a block from the world
            if rd_en = '1' then
                tile_out <= memory
                    (to_integer(out_pos.x))
                    (to_integer(out_pos.y))
                    ;
            end if;
        end if;
    end process;
end Behavioral;

architecture IP of world is
    component dist_mem_gen_0
        port (
            a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component;
    signal a: std_logic_vector(5 downto 0);
    signal d, spo: std_logic_vector(3 downto 0);
    signal we: std_logic;
    begin
    fifo: dist_mem_gen_0
        port map(
            a => a,
            d => d,
            clk => clk,
            we => we,
            spo => spo
        );
    we <= wr_en;
    d <= tile_in;
    tile_out <= spo;
end IP;
