library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package test_package is
    type SHIFT_REG is array (0 to 16-1) of unsigned(17 DOWNTO 0);
    signal mem_x, mem_y: SHIFT_REG := (others => (others => '0'));
end package;

library ieee;
use ieee.std_logic_1164.all;
use work.test_package.all;
use ieee.numeric_std.all;
entity tail is
    generic (
        memory_size: integer := 16
    );
    port(
        shift: in std_logic;
        inx, iny: in unsigned(17 DOWNTO 0);
        clk, rst: in std_logic;
        
        outx, outy: out unsigned(17 DOWNTO 0);
        empty: out std_logic := '0';
        full: out std_logic := '0'
    );
end tail;

architecture Behavioral of tail is
    type SHIFT_REG is array (0 to 16-1) of unsigned(17 DOWNTO 0);
    signal mem_x, mem_y: SHIFT_REG := (others => (others => '0'));
    signal load: std_logic := '1';
begin
    outx <= mem_x(0);
    outy <= mem_y(0);
    process (clk) is
        variable size: integer := 0;
    begin
        if rising_edge(clk) then
            if shift = '1' then -- TODO: check FIFO not empty
                mem_x <= mem_x(1 to memory_size-1) & "000000000000000000";
                mem_y <= mem_y(1 to memory_size-1) & "000000000000000000";
                if size > 0 then
                    size := size - 1;
                    empty <= '0';
                else
                    empty <= '1';
                end if;
            end if;
            if load = '1' then -- TODO: check FIFO not full
                mem_x(size) <= inx;
                mem_y(size) <= iny;
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
    signal load, shift0: std_logic;
    signal din, dout: std_logic_vector(35 downto 0);
    component fifo_generator_0
        port (
            clk : IN STD_LOGIC;
            srst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    end component;
begin
    fifo: fifo_generator_0 
        port map (
            clk => clk,
            srst => rst,
            rd_en => shift0,
            wr_en => load,
            empty => empty,
            full => full,
            dout => dout,
            din => din
        );
     load <= not rst;
     shift0 <= shift and not rst;
     outx <= unsigned(dout(17 downto 0));
     outy <= unsigned(dout(35 downto 18));
     din <= std_logic_vector(iny) & std_logic_vector(inx);
end WithFIFO;
