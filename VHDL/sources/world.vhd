library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package world_pkg is
    -- Number of bits representing x
    constant posx_bits: integer := 18;
    -- Representation of x coordinate
    subtype posx is unsigned(posx_bits-1 downto 0);
    
    -- Number of bits representing y
    constant posy_bits: integer := 18;
    -- Representation of y coordinate
    subtype posy is unsigned(posy_bits-1 downto 0);
    
    -- 2D position defined by two coordinates
    type pos is record
        x: posx;
        y: posy;
    end record;
    
    -- Box defined by TOP LEFT (tl) and BOTTOM RIGHT (br) corners
    type box is record
        tl: pos; -- Top Left
        br: pos; -- Bottom Right
    end record;
    
    -- Block type
    type btype is (empty, snake, apple);
    
    
    -- Constants --

    -- Smallest representable coordinates
    constant min_x: posx := (others => '0');
    constant min_y: posy := (others => '0');
    constant min_pos: pos := (x => min_x, y => min_y);
    -- Biggest  representable coordinates
    constant max_x: posx := (others => '1');
    constant max_y: posy := (others => '1');
    constant max_pos: pos := (x => max_x, y => max_y);
    -- Coordinates of origin
    constant zero_x: posx := (others => '0');
    constant zero_y: posy := (others => '0');
    constant zero_pos: pos := (x => zero_x, y => zero_y);
    -- Biggest representable box
    constant max_box: box := (tl => min_pos, br => max_pos);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;
entity world is
    port (
        in_pos: pos;
        out_pos: pos;
        wr_en, rd_en: in std_logic;
        
        btype_in: in btype;
        btype_out: out btype;
        
        clk, rst: in std_logic
    );
end world;

architecture Behavioral of world is
        type REGW is array (0 to 9) of btype;
        type REG is array (0 to 9) of REGW;
        signal memory: REG;
    begin
    process (clk) is
    begin
        if rst = '1' then
            memory <= (others => (others => empty));
        else
            -- Modify a block in the world
            if wr_en = '1' then
                memory
                    (to_integer(in_pos.x))
                    (to_integer(in_pos.y))
                    <= btype_in;
            end if;
            -- Read   a block in the world
            if rd_en = '1' then
                btype_out <= memory
                    (to_integer(out_pos.x))
                    (to_integer(out_pos.y))
                    ;
            end if;
        end if;
    end process;
end Behavioral;
