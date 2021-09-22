library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PRNG is -- Pseudo Random Number Generator
  generic (
        size: integer range 1 to 30 := 4 -- Generate number from 0 to (2^size) - 1, max 2^30 -1
  );
  port (
    clk : in std_logic;
    rst : in std_logic; -- Reset  counter (seed) = 0
    init : in std_logic; -- Stop counter and set initial value (seed) of LFSR   
    enable : in std_logic; -- Generate number
    data : out std_logic_vector(size-1 downto 0) -- Generate one number every clock cycle
  );
end entity PRNG;
 
architecture Behavioral of PRNG is 
    constant num: integer := 30;
    constant max_seed: integer := 1073741822;
    signal r_LFSR : std_logic_vector(num downto 1) := (others => '0');
    signal seed: integer := 0; 
    signal w_XNOR : std_logic;
    signal feedback: std_logic;
    type t_state is (b, c);
    -- b: count enable
    -- c: shift enable
    -- d: ready 
    signal state: t_state := b;
begin
    data <= r_LFSR(size downto 1); -- truncate LFSR
    w_XNOR <= r_LFSR(30) xnor r_LFSR(6) xnor r_LFSR(4) xnor r_LFSR(1); -- XNOR function
    seq: process (clk, rst) is
    begin
        if rising_edge(clk) then
            if rst = '0' then -- reset asyncronous
                state <= b;
                seed <= 0;
            else
                case state is
                    when b =>
                        seed <= seed + 1;
                        if init = '1' then
                            state <= c;
                            r_LFSR <= std_logic_vector(to_unsigned(seed, num));
                        end if;
                    when c =>
                        if enable = '1' then
                            r_LFSR <= r_LFSR(num-1 downto 1) & w_XNOR;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;
