library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity snake is
    generic (
        bounds: t_box;
        start_pos: t_pos;
        start_mot: t_mot;
        max_length: integer := 16
    );
    port(
        clk, rst:   in std_logic; -- rst: active low
        update:     in std_logic;
        grow, load: in std_logic;
        dir:        in std_logic_vector(3 downto 0); -- direction U D L R
        head_pos, neck_pos, tail_pos:    out t_pos;
        head_tile, neck_tile, tail_tile: out t_tile := snake_head_r
    );
end snake;

architecture Behavioral of snake is
    signal head_pos0: t_pos;
    signal shift: std_logic;
    signal mot, candidate_mot: t_mot;
begin
    head: entity work.head(Behavioral)
        generic map (
            bounds => bounds,
            start_pos => start_pos,
            start_mot => start_mot
        )
        port map (
            clk => clk, rst => rst,
            mot => mot,
            update => update,
            head_pos => head_pos0,
            neck_pos => neck_pos,
            head_tile => head_tile,
            neck_tile => neck_tile
        );
    tail: entity work.tail(Behavioral)
        generic map (
            memory_size => max_length
        )
        port map (
            clk => clk, rst => rst,
            update => update,
            shift => shift,
            load => load,
            in_pos => head_pos0,
            out_pos => tail_pos
        );
    --neck: entity work.neck(Behavioral)
    --    generic map (
    --        start_neck_pos => (x => start_pos.x - 1, y => start_pos.y - 1),
    --        start_body_pos => (x => start_pos.x - 2, y => start_pos.y - 2)
    --    )
    --    port map (
    --        clk => clk, rst => rst,
    --        update => update0,
    --        head_pos => head_pos0,
    --        neck_pos => neck_pos,
    --        neck_tile => neck_tile
    --    );
    --load <= '1';
    head_pos <= head_pos0;
    shift <= not grow;
    candidate_mot <= 
        mot_u when dir = "1000" else
        mot_d when dir = "0100" else
        mot_l when dir = "0010" else
        mot_r when dir = "0001" else
        mot_n;
        
    process (clk, rst) is
    begin
        if rst = '0' then
            mot <= start_mot;
        elsif rising_edge(clk) and update = '1' then
            -- Restrict snake from making a 180° turn
            if candidate_mot /= mot_n and
               (candidate_mot.x + mot.x) /= "11" and
               (candidate_mot.y + mot.y) /= "11" then
                mot <= candidate_mot;
            end if;
        end if;
    end process;
end Behavioral;
