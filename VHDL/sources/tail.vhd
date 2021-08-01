library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

-- Tail module
-- works as a fifo keeping track of in_pos
--
--   shift  -> shift = '0' the fifo consuming last position
--             shift = '1' -> freezes the output position
--   rst    -> reset pin
--             in architecture WIthFIFO the rst signal needs to be followed by a
--             pause of 3 clock cycles where shift and load remain 0

entity tail is
    generic (
        memory_size: integer := 16
    );
    port(
        clk, rst: in std_logic;
        update: in std_logic;
        shift, load: in std_logic;
        in_pos: in t_pos;
        
        out_pos: out t_pos;
        empty: out std_logic := '1';
        full: out std_logic := '0'
    );
end tail;

architecture Behavioral of tail is
    type SHIFT_REG is array (0 to memory_size-1) of t_pos;
    signal mem: SHIFT_REG := (others => zero_pos);
begin
    out_pos <= mem(0);
    process (clk) is
        variable size: integer := 0;
    begin
        if rising_edge(clk) and update = '1' then
            if shift = '1' then -- TODO: check FIFO not empty
                mem <= mem(1 to memory_size-1) & zero_pos;
                if size > 0 then
                    size := size - 1;
                    empty <= '0';
                else
                    empty <= '1';
                end if;
            end if;
            if load = '1' then -- TODO: check FIFO not full
                mem(size) <= in_pos;
                if size < memory_size then
                    size := size + 1;
                    full <= '0';
                else
                    full <= '1';
                end if;
            end if;
        end if;
    end process;
end Behavioral;

architecture WithFIFO of tail is
    signal shift0, load0: std_logic;
    signal din, dout: std_logic_vector(35 downto 0);
    component fifo_generator_0
        port (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    end component;
begin
    -- Fifo with data width of 36
    -- least significant 18 bits represent X
    -- most  significant 18 bits represent Y
    fifo: fifo_generator_0
        port map (
            clk => clk,
            rst => rst,
            rd_en => shift0,
            wr_en => load0,
            empty => empty,
            full => full,
            dout => dout,
            din => din
        );
     load0 <= load   and rst and update;
     shift0 <= shift and rst and update;
     out_pos.x <= t_posx(dout(posx_bits-1 downto 0));
     out_pos.y <= t_posy(dout(posy_bits+posx_bits-1 downto posx_bits));
     din(posx_bits+posy_bits-1 downto 0) <= std_logic_vector(in_pos.y) & std_logic_vector(in_pos.x);
end WithFIFO;
