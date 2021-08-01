library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity eden is
    port(
        CLK, RST: in std_logic;
        -- Cross buttons
        BTNU, BTND, BTNL, BTNR: in std_logic;
        -- Switches
        SW: in std_logic_vector( 15 downto 0 );
        --LED: out std_logic_vector( 15 downto 0 );
        -- 7 segments display
        CA, CB, CC, CD, CE, CF, CG, DP: out std_logic;
        AN: out std_logic_vector( 7 downto 0 );
        -- VGA connector
        VGA_HS, VGA_VS: out std_logic;
        VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0)
    );
end eden;

architecture Behavioral of eden is
    constant world_bounds: t_box := (
        tl => (x => zero_x + 3,  y => zero_y + 1),
        br => (x => max_x  - 3,  y => max_y  - 1)
    );
    
    signal nrst: std_logic;
    signal dir: std_logic_vector(3 downto 0);
    signal head_pos,  neck_pos,  tail_pos:  t_pos;
    signal head_tile, neck_tile, tail_tile: t_tile;
    signal display_value : std_logic_vector( 31 downto 0 ) := (others => '0');
    
    signal tick: std_logic;
    
    -- World
    signal world_pos: t_pos;
    signal get_pos, set_pos: t_pos;
    signal wr_en: std_logic := '0';
    signal rd_en: std_logic := '1';
    signal set_tile_world, get_tile_world: t_tile;
    
    -- Graphics
    signal curr_pos: t_pos;                      -- Current tile pos being draw
    signal draw_tile: t_tile;
    
    signal enable_display_world: std_logic;      -- Trigger signal to enable pixel data from world
    signal enable_display_background: std_logic; -- Trigger signal to enable pixel data from background
    
    -- Vga
    signal pxl_clk: std_logic; -- pxl_clk
    signal tile: t_tile;
    signal ask_pos: t_pos;
    signal enable_write: std_logic;
    component clk_wiz_0
        port (
            clk_in1 : IN STD_LOGIC;
            clk_100  : OUT STD_LOGIC
        );
    end component;
begin
    -- Input cleaning
    --e_debouncer_u: entity work.debouncer(Behavioral)
    --    port map (
    --        clk => CLK,
    --        rst => RST,
    --        bouncy => BTNU,
    --        pulse => u
    --    );
    --e_debouncer_d: entity work.debouncer(Behavioral)
    --    port map (
    --        clk => CLK,
    --        rst => RST,
    --        bouncy => BTND,
    --        pulse => d
    --    );
    --e_debouncer_l: entity work.debouncer(Behavioral)
    --    port map (
    --        clk => CLK,
    --        rst => RST,
    --        bouncy => BTNL,
    --        pulse => l
    --    );
    --e_debouncer_r: entity work.debouncer(Behavioral)
    --    port map (
    --        clk => CLK,
    --        rst => RST,
    --        bouncy => BTNR,
    --        pulse => r
    --    );
    
    e_counter_tick: entity work.counter(Behavioral)
        generic map (
            max => 20000000
        )
        port map (
            clk => pxl_clk, rst => rst,
            enable => '1',
            tc => tick,
            count => open
        );
        
    -- Game logic
    e_world: entity work.world(Behavioral)
        generic map (
            def_tile => apple,
            bounds => world_bounds
        )
        port map (
            -- Write side
            wr_en => wr_en,
            in_pos => set_pos,
            tile_in => set_tile_world,
            
            -- Read side
            rd_en => rd_en,
            out_pos => get_pos,
            tile_out => get_tile_world,
            
            clk => pxl_clk,
            rst => RST
        );
    e_snake: entity work.snake
        generic map (
            start_pos => world_bounds.tl,
            start_mot => mot_r,
            bounds => world_bounds
        )
        port map (
            clk => pxl_clk, rst => RST,
            
            update => tick,
            
            dir => dir,
            head_pos  => head_pos,
            head_tile => head_tile,
            
            tail_pos  => tail_pos,
            tail_tile => tail_tile,
            
            neck_pos  => neck_pos,
            neck_tile => neck_tile,
            
            grow      => SW(15),
            load      => SW(14)
        );
        
    -- Graphics
    e_window_world: entity work.window(Behavioral)
        generic map (
            bounds => world_bounds
        )
        port map (
            pos => curr_pos,
            enable_display => enable_display_world
        );
    e_clk_wiz : clk_wiz_0
        port map (
            clk_in1 => CLK,
            clk_100 => pxl_clk
        );
    e_vga_renderer : entity work.vga_renderer(Behavioral) 
        generic map (
            scale => 3
        )
        port map (
            pxl_clk => pxl_clk,
            tile => draw_tile,
            pos => curr_pos,
            enable_write => enable_write,
            vga_hs => VGA_HS, vga_vs => VGA_VS,
            vga_r => VGA_R, vga_g => VGA_G, vga_b => VGA_B
        );
    
    e_thedriver : entity work.seven_segment_driver(Behavioral) 
        generic map ( 
            size => 21 
        )
        port map (
            clk => CLK,
            rst => RST,
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
        
    draw_tile <= get_tile_world when enable_display_world = '1' 
                 else crate;
    
    nrst <= not RST;
    display_value(t_posx'high downto 0) <=
        std_logic_vector(head_pos.x) when SW(4 downto 0) = "00001" else
        std_logic_vector(head_pos.y) when SW(4 downto 0) = "00010" else
        std_logic_vector(tail_pos.x) when SW(4 downto 0) = "00100" else
        std_logic_vector(tail_pos.y) when SW(4 downto 0) = "01000" else
        (others => '0');
    get_pos <= curr_pos;
    dir <= BTNU & BTND & BTNL & BTNR;
    
    process (pxl_clk) is
    begin
        if rising_edge(pxl_clk) then
            set_pos <= curr_pos;
            
            wr_en <= '0';
            if enable_write = '1' then
                -- TODO: check pixel position is bottom right of tile
                if head_pos = curr_pos then
                    wr_en <= '1';
                    set_tile_world <= head_tile;
                end if;
                
                if neck_pos = curr_pos then
                    wr_en <= '1';
                    set_tile_world <= neck_tile;
                end if;
                
                if tail_pos = curr_pos then
                --    wr_en <= '1';
                --    set_tile_world <= short_grass;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
