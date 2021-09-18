library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment_driver is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    index: out natural;
    value: in natural;
    CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
    AN : out std_logic_vector( 7 downto 0 )
  );

end seven_segment_driver;

architecture Behavioral of seven_segment_driver is
    constant size: natural := 20;
    signal flick_counter : unsigned( size - 1 downto 0 );
    -- The digit is temporarily stored here
    signal digit : std_logic_vector( 3 downto 0 );
    -- Collect the values of the cathodes here
    signal cathodes : std_logic_vector( 7 downto 0 );
begin

  -- Divide the clock
  process (clk, rst) begin
    if rst = '0' then -- active low
      flick_counter <= ( others => '0' );
    elsif rising_edge(clk) then
        flick_counter <= flick_counter + 1;
    end if;
  end process;

  -- Select the anode
  index <= to_integer(flick_counter( size - 1 downto size - 3 ));
  with flick_counter( size - 1 downto size - 3 ) select
    AN <=
      "11111110" when "000",
      "11111101" when "001",
      "11111011" when "010",
      "11110111" when "011",
      "11101111" when "100",
      "11011111" when "101",
      "10111111" when "110",
      "01111111" when others;

  -- Select the digit
    
  -- Decode the digit
  with value select
    cathodes <=
      -- DP, CG, CF, CE, CD, CC, CB, CA
      "11000000" when 0,
      "11111001" when 1,
      "10100100" when 2,
      "10110000" when 3,
      "10011001" when 4,
      "10010010" when 5,
      "10000010" when 6,
      "11111000" when 7,
      "10000000" when 8,
      "10010000" when 9,
      "10001000" when 10,     -- A
      "10000011" when 11,     -- B
      "11000110" when 12,     -- C
      "10100001" when 13,     -- D
      "10000110" when 14,     -- E
      "10001110" when 15,     -- F
      "10111111" when others; -- unexpected

  DP <= cathodes( 7 );
  CG <= cathodes( 6 );
  CF <= cathodes( 5 );
  CE <= cathodes( 4 );
  CD <= cathodes( 3 );
  CC <= cathodes( 2 );
  CB <= cathodes( 1 );
  CA <= cathodes( 0 );

end behavioral;
