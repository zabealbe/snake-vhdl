library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity eden is
    port(
        RST, CLK: in std_logic;
        BTNU, BTND, BTNL, BTNR: in std_logic;
        SW: in std_logic_vector( 15 downto 0 );
        LED: out std_logic_vector( 15 downto 0 );
        CA, CB, CC, CD, CE, CF, CG, DP: out std_logic;
        AN: out std_logic_vector( 7 downto 0 )
    );
end eden;

architecture Behavioral of eden is
    constant clock_speed: integer := 100_000_000;
    constant g_cpf: integer := clock_speed / 60;  -- Graphics update rate, measured in clock cycles per frame
    constant p_cpf: integer := g_cpf * 3;         -- Physics  update rate, measured in clock cycles per frame
    
    signal g_rst, g_init, g_enable, g_tc: std_logic := '0';
    signal p_rst, p_init, p_enable, p_tc: std_logic := '0';
    signal g_count_internal: integer := 0;
    signal p_count_internal: integer := 0;
    
    signal nrst: std_logic;
    signal u, d, l, r: std_logic;
    signal head_pos, tail_pos: t_pos;
    signal display_value : std_logic_vector( 31 downto 0 ) := (others => '0');
    
    -- World
    signal get_pos, set_pos: t_pos;
    signal wr_en, rd_en: std_logic;
    signal tile_in, tile_out: t_tile;
    
    -- Vga
    signal tile: t_tile;
    signal ask_pos: t_pos;
    signal vga_hs, vga_vs: std_logic;
    signal vga_r, vga_g, vga_b: std_logic_vector(3 downto 0);
begin
    world: entity work.world
        port map (
            -- Write side
            wr_en => wr_en,
            in_pos => set_pos,
            tile_in => tile_in,
            
            -- Read side
            rd_en => rd_en,
            out_pos => get_pos,
            tile_out => tile_out,
            
            clk => clk,
            rst => rst
        );
        
    snake: entity work.snake
        port map (
            u => u, d => d, l => l, r => r,
            head_pos => head_pos,
            tail_pos => tail_pos,
            grow => SW(15),
            clk => CLK,
            rst => nrst
        );
    debouncer_u: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTNU,
            pulse => u
        );
    debouncer_d: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTND,
            pulse => d
        );
    debouncer_l: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTNL,
            pulse => l
        );
    debouncer_r: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTNR,
            pulse => r
        );
    e_vga_renderer : entity work.vga_renderer(Behavioral) 
        port map (
            clk => CLK,
            tile => tile,
            pos => ask_pos,
            vga_hs => vga_hs, vga_vs => vga_vs,
            vga_r => vga_r, vga_g => vga_g, vga_b => vga_b
        );
    
    g_counter: entity work.counter generic map (max => g_cpf - 1) port map (
        clk => clk, 
        rst => g_rst, 
        init => g_init, 
        enable => g_enable, 
        tc => g_tc, 
        count => g_count_internal
    );

    p_counter: entity work.counter generic map (max => p_cpf - 1) port map (
        clk => clk,
        rst => p_rst,
        init => p_init,
        enable => p_enable,
        tc => p_tc,
        count => p_count_internal
    );
    
    thedriver : entity work.seven_segment_driver(Behavioral) 
        generic map ( 
            size => 21 
        )
        port map (
            clk => CLK,
            rst => nrst,
            digit0 => display_value( 3 downto 0 ),
            digit1 => display_value( 7 downto 4 ),
            digit2 => display_value( 11 downto 8 ),
            digit3 => display_value( 15 downto 12 ),
            digit4 => display_value( 19 downto 16 ),
            digit5 => display_value( 23 downto 20 ),
            digit6 => display_value( 27 downto 24 ),
            digit7 => display_value( 31 downto 28 ),
            CA     => CA,
            CB     => CB,
            CC     => CC,
            CD     => CD,
            CE     => CE,
            CF     => CF,
            CG     => CG,
            DP     => DP,
            AN     => AN
        );
    nrst <= not RST;
    LED <= SW;
    process (clk) is
    begin
        if rising_edge(clk) then
            if (g_tc = '1') then
                -- Update graphics
                rd_en <= '1';
                get_pos <= ask_pos;
            else
                rd_en <= '0';
            end if;
            if (p_tc = '1') then
                -- Update physics
                wr_en <= '1';
                set_pos <= head_pos;
            else
                wr_en <= '0';
            end if;
        end if;
    end process;
end Behavioral;
