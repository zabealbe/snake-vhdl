library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.test_package.all;
use ieee.numeric_std.all;

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
    signal nrst: std_logic;
    signal u, d, l, r: std_logic;
    signal tailx, taily, headx, heady: unsigned(17 DOWNTO 0);
    signal display_value : std_logic_vector( 31 downto 0 ) := (others => '0');
begin
    snake: entity work.snake
        port map (
            u => u, d => d, l => l, r => r,
            headx => headx, heady => heady,
            tailx => tailx, taily => taily,
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
    display_value(17 downto 0) <=
        std_logic_vector(headx) when SW(4 downto 0) = "00001" else
        std_logic_vector(heady) when SW(4 downto 0) = "00010" else
        std_logic_vector(tailx) when SW(4 downto 0) = "00100" else
        std_logic_vector(taily) when SW(4 downto 0) = "01000" else
        "00" & SW when SW(4 downto 0) = "1----" else
        (others => '0');
end Behavioral;
