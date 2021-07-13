library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

-- Head module
-- keeps track of current head position
-- updates the position every time one of u, d, l, r changes

entity head is
    generic (
        -- Bounding box
        bounds: t_box := max_box;
        -- Start position of the head
        start_pos: t_pos := zero_pos
    );
    port(
        u, d, l, r: in std_logic;
        clk, rst: in std_logic;
        
        curr_pos: out t_pos := start_pos
    );
end entity;

architecture Behavioral of head is
begin
    process (clk, rst) is
        variable pos: t_pos := start_pos;
    begin
        if rst = '1' then
            pos := start_pos;
        elsif rising_edge(clk) then
            if (u xor d) = '1' then
                if u = '1' and pos.y /= bounds.tl.y then
                    pos.y := pos.y - 1;
                end if;
                if d = '1' and pos.y /= bounds.br.y then
                    pos.y := pos.y + 1;
                end if;
            end if;
            if (l xor r) = '1' then
                if l = '1' and pos.x /= bounds.tl.x then
                    pos.x := pos.x - 1;
                end if;
                if r = '1' and pos.x /= bounds.br.x then
                    pos.x := pos.x + 1;
                end if;
            end if;
        end if;
        curr_pos <= pos;
    end process;
end Behavioral;
