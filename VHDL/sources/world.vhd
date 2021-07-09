library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package world_pkg is
    -- Position
    subtype posx is unsigned(17 downto 0);
    subtype posy is unsigned(17 downto 0);
    type pos is record
        x: posx;
        y: posy;
    end record;
    -- Block type
    type btype is (empty, snake, apple);
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
            if wr_en = '1' then
                memory
                    (to_integer(in_pos.x))
                    (to_integer(in_pos.y))
                    <= btype_in;
            end if;
            if rd_en = '1' then
                btype_out <= memory
                    (to_integer(out_pos.x))
                    (to_integer(out_pos.y))
                    ;
            end if;
        end if;
    end process;
end Behavioral;
