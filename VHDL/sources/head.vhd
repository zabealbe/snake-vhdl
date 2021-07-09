library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Head module
-- keeps track of current head position
-- updates the position every time one of u, d, l, r changes

entity head is
    generic (
        min_x, min_y: unsigned(17 DOWNTO 0) := TO_UNSIGNED(0, 18);
        max_x, max_y: unsigned(17 DOWNTO 0) := TO_UNSIGNED(100, 18);
        x0, y0: unsigned := (others => '0')
    );
    port(
        u, d, l, r: in std_logic;
        clk, rst: in std_logic;
        currx: out unsigned(17 DOWNTO 0) := x0;
        curry: out unsigned(17 DOWNTO 0) := y0
    );
end entity;

architecture Behavioral of head is
begin
    process (clk, rst) is
        variable x: unsigned(17 DOWNTO 0) := x0;
        variable y: unsigned(17 DOWNTO 0) := y0;
    begin
        if rst = '1' then
            x := x0;
            y := y0;
        elsif rising_edge(clk) then
            if (u xor d) = '1' then
                if u = '1' and y /= min_y then
                    y := y - 1;
                end if;
                if d = '1' and y /= max_y then
                    y := y + 1;
                end if;
            end if;
            if (l xor r) = '1' then
                if l = '1' and x /= min_x then
                    x := x - 1;
                end if;
                if r = '1' and x /= max_x then
                    x := x + 1;
                end if;
            end if;
        end if;
        currx <= x;
        curry <= y;
    end process;
end Behavioral;
