library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity eden is
    port(
        CLK, RST: in std_logic;
        -- Cross buttons
        BTNU, BTND, BTNL, BTNR, BTNC: in std_logic;
        -- Switches
        SW: in std_logic_vector( 15 downto 0 );
        -- 7 segments
        CA, CB, CC, CD, CE, CF, CG, DP: out std_logic := '0';
        AN: out std_logic_vector( 7 downto 0 ) := (others => '1');
        -- VGA connector
        VGA_HS, VGA_VS: out std_logic;
        VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0)
    );
end eden;

architecture Behavioral of eden is  
    -- Eden
    type t_game_state is (game_idle, game_setup, game_play, game_score, game_end);       -- idle, setup, playing, end
    signal game_state: t_game_state := game_idle;
    type t_snake_state is (i, m, e, d);        -- idle, moving, eating, dead
    signal snake_state: t_snake_state := m;
    signal curr_pos: t_pos;               -- Current tile pos being draw
    signal draw_tile: t_tile;
    signal background_visible: std_logic;
    
    -- World
    constant world_bounds: t_box := (
        tl => to_pos(3,  4),
        br => to_pos(56, 31)
    );
    signal get_pos, set_pos: t_pos;
    signal wr_en: std_logic := '0';
    signal rd_en: std_logic := '1';
    signal set_tile_world, get_tile_world, get_tile_score: t_tile;
    signal world_visible: std_logic;
    
    -- Score
    signal score_enable: std_logic := '0';
    constant score_top_left: t_pos := world_bounds.tl - to_pos(0, 3);
    signal score_visible: std_logic;

    -- Apple
    signal apple_pos : t_pos;
    signal apple_move: std_logic;
    
    -- Snake
    constant start_pos: t_pos      := world_bounds.tl + to_pos(2, 0);
    signal snake_eat, snake_die, snake_move: std_logic;
    signal tick: std_logic;
    signal head_pos, neck_pos, tail_pos, last_tail_pos: t_pos;
    signal head_tile, neck_tile, tail_tile: t_tile;
    signal dir: std_logic_vector(3 downto 0); -- Direction given by user
    
    -- Vga
    signal pxl_clk: std_logic; -- pxl_clk
    signal tile: t_tile;
    signal enable_write, enable_write0: std_logic;
    component clk_wiz_0
        port (
            clk_in1 : IN STD_LOGIC;
            clk_100  : OUT STD_LOGIC
        );
    end component;
begin
    e_apple: entity work.apple(Behavioral)
        generic map (
            bounds => world_bounds
        )
        port map (
            clk => pxl_clk, rst => RST,
            
            tick => tick,
            mov => apple_move,
            pos => apple_pos
        );
    
    e_counter_tick: entity work.counter(Behavioral)
        generic map (
            max => 20000
        )
        port map (
            clk => pxl_clk, rst => rst,
            
            enable => enable_write,
            tc => tick,
            count => open
        );
        
    -- Game logic
    e_score: entity work.score_tiler(Behavioral)
        generic map (
            size => 8,
            top_left => score_top_left
        )
        port map (
            clk => pxl_clk, rst => RST,
            
            pos => curr_pos,
            enable => score_enable,
            tile => get_tile_score,
            visible => score_visible
        );
    e_world: entity work.world(Behavioral)
        generic map (
            def_tile => tall_grass,
            bounds => world_bounds
        )
        port map (
            clk => pxl_clk, rst => RST,
            
            -- Write side
            wr_en => wr_en,
            pos_in => set_pos,
            tile_in => set_tile_world,
            
            -- Read side
            rd_en => '1',
            pos_out => get_pos,
            tile_out => get_tile_world,
            visible => world_visible
        );
    e_snake: entity work.snake
        generic map (
            start_pos => start_pos,
            start_mot => mot_r,
            bounds => world_bounds
        )
        port map (
            clk => pxl_clk, rst => RST,
            
            mov       => snake_move,
            eat       => snake_eat,
            die       => snake_die,
            tick      => tick,

            
            dir       => dir,
            head_pos  => head_pos,
            head_tile => head_tile,
            
            tail_pos  => tail_pos,
            tail_tile => tail_tile,
            
            neck_pos  => neck_pos,
            neck_tile => neck_tile
        );
        
    e_clk_gen : clk_wiz_0
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

    snake_eat  <= '1' when game_state = game_score else '0';
    snake_die  <= '1' when game_state = game_end else '0';
    snake_move <= '1' when game_state = game_play or game_state = game_score else '0';
    apple_move <= '1' when game_state = game_score or game_state = game_setup else '0';
    score_enable <= '1' when game_state = game_score and tick = '1' else '0';
    
    draw_tile <= 
        get_tile_world when world_visible = '1' else
        get_tile_score when score_visible = '1' else
        crate;
        
--    set_tile_world <=
--        head_tile  when set_pos = head_pos else
--        neck_tile  when set_pos = neck_pos else
--        tail_tile  when set_pos = tail_pos else
--        tall_grass when set_pos = last_tail_pos else
--        apple      when set_pos = apple_pos;
        
    dir <= BTNU & BTND & BTNL & BTNR;
    get_pos <= curr_pos;

    process (pxl_clk, RST) is
    begin
        if rising_edge(pxl_clk) then
            if RST = '0' then
                last_tail_pos <= tail_pos;           -- reset last tail pos
                game_state <= game_idle;
                wr_en <= '0';
            else
                enable_write0 <= enable_write;
                wr_en <= '0';
                
                if enable_write = '1' then         -- Update world
                    set_pos <= curr_pos;             -- set curr pos as write position for world                   
                    if curr_pos = neck_pos then      -- Check if neck moved to curr pos
                        wr_en <= '1';                  -- update world tile
                        set_tile_world <= neck_tile;
                    end if;
                    
                    if curr_pos = tail_pos then      -- Check if tail moved to curr pos
                        wr_en <= '1';                  -- update world tile
                        set_tile_world <= tail_tile;
                    end if;
                    
                    if curr_pos = last_tail_pos then -- Check if curr pos was previus tail pos
                        wr_en <= '1';                  -- update world tile
                        set_tile_world <= tall_grass;
                    end if;
                    
                    if curr_pos = apple_pos then     -- Check if apple moved to curr pos
                        wr_en <= '1';                  -- update world tile
                        set_tile_world <= apple;
                    end if;
                    
                    if curr_pos = head_pos then      -- Check if head moved to curr pos
                        wr_en <= '1';                -- update world tile
                        set_tile_world <= head_tile;
                    end if;
                end if;
                        
                case game_state is
                    when game_idle => -- idle
                        if BTNC = '1' then
                            game_state <= game_setup;
                        end if;
                    when game_setup => -- setup
                        if tick = '1' then
                            game_state <= game_play;
                        end if;
                    when game_play => -- playing
                        last_tail_pos <= tail_pos; -- store tail old position
                        -- Next state logic
                        if head_pos = apple_pos then
                            game_state <= game_score;
                        end if;
                        if curr_pos = head_pos then
                            if enable_write0 = '1' and get_tile_world /= short_grass and
                                 get_tile_world /= tall_grass and
                                 get_tile_world /= apple then
                                game_state <= game_end;
                             end if;
                         end if;
                    when game_score =>
                        -- Next state logic
                        if tick = '1' then
                            game_state <= game_play;
                        end if;
                    when game_end => -- end
                        if BTNC = '1' then
                            game_state <= game_setup;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
