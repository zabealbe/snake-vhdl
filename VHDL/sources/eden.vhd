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
    signal set_tile, get_tile: t_tile;
    
    -- Vga
    signal tile: t_tile;
    signal ask_pos: t_pos;
    signal vga_hs, vga_vs: std_logic;
    signal vga_r, vga_g, vga_b: std_logic_vector(3 downto 0);
begin
    e_world: entity work.world
        port map (
            -- Write side
            wr_en => wr_en,
            in_pos => set_pos,
            tile_in => set_tile,
            
            -- Read side
            rd_en => rd_en,
            out_pos => get_pos,
            tile_out => get_tile,
            
            clk => clk,
            rst => rst
        );
        
    e_snake: entity work.snake
        port map (
            u => u, d => d, l => l, r => r,
            head_pos => head_pos,
            tail_pos => tail_pos,
            grow => SW(15),
            clk => CLK,
            rst => nrst
        );
    e_debouncer_u: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTNU,
            pulse => u
        );
    e_debouncer_d: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTND,
            pulse => d
        );
    e_debouncer_l: entity work.debouncer(Behavioral)
        port map (
            clk => CLK,
            rst => nrst,
            bouncy => BTNL,
            pulse => l
        );
    e_debouncer_r: entity work.debouncer(Behavioral)
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
    
    e_g_counter: entity work.counter generic map (max => g_cpf - 1) port map (
        clk => clk, 
        rst => g_rst, 
        init => g_init, 
        enable => g_enable, 
        tc => g_tc, 
        count => g_count_internal
    );

    e_p_counter: entity work.counter generic map (max => p_cpf - 1) port map (
        clk => clk,
        rst => p_rst,
        init => p_init,
        enable => p_enable,
        tc => p_tc,
        count => p_count_internal
    );
    
    e_thedriver : entity work.seven_segment_driver(Behavioral) 
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
        variable index: unsigned(posy_bits+posx_bits-1 downto 0) := (others => '0');
        variable curr_pos: t_pos;
    begin
        if rising_edge(clk) then
            curr_pos := (
                x => index mod 32,
                y => index   / 32
            );
            
            if ask_pos = curr_pos then
                rd_en <= '1';
                get_pos <= ask_pos;
            else
                rd_en <= '0';
            end if;
            
            -- TODO: check pixel position is bottom right of tile
            if head_pos = curr_pos then
                wr_en <= '1';
                set_pos <= head_pos;
                set_tile <= snake;
            else
                wr_en <= '0';
            end if;
            
            if tail_pos = curr_pos then
                wr_en <= '1';
                set_pos <= tail_pos;
                set_tile <= grass;
            else
                wr_en <= '0';
            end if;
            
            index := index + 1;
        end if;
    end process;
end Behavioral;
