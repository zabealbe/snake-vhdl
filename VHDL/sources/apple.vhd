library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity apple is
    generic (
        bounds: t_box
    );
    port (
        clk, rst: in std_logic;
        mov, tick: in std_logic;
        pos: out t_pos
    );
end apple;

architecture Behavioral of apple is
    signal data_random: std_logic_vector(t_posx'length+t_posy'length-1 downto 0);
begin
    e_prng: entity work.PRNG(Behavioral)
    generic map (
        size => t_posx'length + t_posy'length
    )
    port map (
        clk => clk,
        rst => rst,
        init => mov,
        enable => mov,
        data => data_random
    );
    process (clk, rst) is
    begin
        if rising_edge(clk) then
            if rst = '0' then
            
            elsif tick = '1' then
                if mov = '1' then
                    pos <= ( -- TODO: better math
                        x => (unsigned(data_random(data_random'length-1 downto t_posy'length))) mod (bounds.br.x+1),
                        y => (unsigned(data_random(t_posy'length-1 downto 0))) mod (bounds.br.y+1)
                    );
                end if;
            end if;
        end if;
    end process;

end Behavioral;
