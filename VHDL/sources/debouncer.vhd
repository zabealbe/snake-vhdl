library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is  
generic (
        counter_size : integer := 13
    );
port (
        clk, rst : in std_logic;
        bouncy : in std_logic;
        pulse : out std_logic
    );
end debouncer;

architecture Behavioral of debouncer is

  -- The counter that keeps track of the when the signal is stable
  signal counter : unsigned( counter_size - 1 downto 0 );
  -- Keep track of the candidate stable value
  signal candidate_value : std_logic;
  -- Keep track of the actual stable value
  signal stable_value : std_logic;
  -- A delayed version of the stable value allows us to check when it has a transition
  signal delayed_stable_value : std_logic;

begin

  process (clk, rst) begin
  if rst = '0' then -- active low
      counter <= ( others => '1' );
      candidate_value <= '0';
      stable_value <= '0';
  elsif rising_edge(clk) then
      -- See if the signal is stable
      if bouncy = candidate_value then
         -- It is. Check if it has been stable for long time
         if counter = 0 then
         -- The signal is stable. Update the stable signal value
         stable_value <= candidate_value;
         else
         -- We still need to wait for the counter to go down
         counter <= counter - 1;
         end if;
      else
        -- The signal is not stable. Reset the counter and the candidate stable value
        candidate_value <= bouncy;
        counter <= ( others => '1' );
      end if;
  end if;
  end process;

  -- Create a delayed version of the stable signal
  process (clk, rst) begin
    if rst = '0' then -- active low
        delayed_stable_value <= '0';
    elsif rising_edge(clk) then
        delayed_stable_value <= stable_value;
    end if;
  end process;

  -- Generate the pulse
  pulse <= '1' when stable_value = '1' and delayed_stable_value = '0' else '0';

end behavioral;

