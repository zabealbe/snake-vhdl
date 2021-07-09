library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity snake is
    generic (
        x0, y0: unsigned(17 DOWNTO 0) := (others => '0');
        max_length: integer := 16
    );
    port(
        grow: in std_logic;
        rst, clk: in std_logic;
        u, d, l, r: in std_logic;
        headx, heady: out unsigned(17 DOWNTO 0);
        tailx, taily: out unsigned(17 DOWNTO 0)
    );
end snake;

architecture Behavioral of snake is
    signal clk10HZ: std_logic := '0';
    signal bindx, bindy: unsigned(17 DOWNTO 0);
    signal shift: std_logic;
begin
    head: entity work.head(Behavioral)
        generic map (
            x0 => x0, y0 => y0
        )
        port map (
            u => u, d => d, l => l, r => r,
            currx => bindx, curry => bindy,
            clk => CLK, rst => rst
        );
    tail: entity work.tail(WithFIFO)
        generic map (
            memory_size => max_length
        )
        port map (
            shift => shift,
            inx => bindx, iny => bindy,
            outx => tailx, outy => taily,
            clk => clk, rst => rst
        );
    process (clk) is
        variable count: integer := 0;
    begin
        count := count + 1;
        if count = 100000 then
            clk10HZ <= not clk10HZ;
            count := 0;
        end if;
    end process;
    headx <= bindx;
    heady <= bindy;
    shift <= not grow;
end Behavioral;
