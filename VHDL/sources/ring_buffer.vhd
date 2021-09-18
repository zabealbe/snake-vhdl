library IEEE;
use IEEE.std_logic_1164.all;
 
entity ring_buffer is
generic (
    width: integer;
    depth: integer
);
port (
    clk, reset: in std_logic;

    -- Write port
    write_enable: in std_logic;
    write_data: in std_logic_vector(width - 1 downto 0);

    -- Read port
    read_enable: in std_logic;
    read_valid: out std_logic;
    read_data: out std_logic_vector(width - 1 downto 0);

    -- Flags
    empty, almost_empty, full, almost_full: out std_logic;

    -- The number of elements in the FIFO
    fill_count: out integer range depth - 1 downto 0
);
end ring_buffer;
 
architecture Behavioral of ring_buffer is
    type ram_type is array (0 to depth - 1) of std_logic_vector(write_data'range);
    signal ram: ram_type := (others => (others => '0'));

    subtype index_type is integer range ram_type'range;
    signal head: index_type;
    signal tail: index_type;

    signal empty_internal: std_logic;
    signal full_internal: std_logic;
    signal fill_count_internal: integer range depth - 1 downto 0;
 
    -- Increment and wrap
    procedure incr(signal index: inout index_type) is begin
        if index = index_type'high then
            index <= index_type'low;
        else
            index <= index + 1;
        end if;
    end procedure;
begin
    -- Copy internal signals to output
    empty <= empty_internal;
    full <= full_internal;
    fill_count <= fill_count_internal;
    
    -- Set the flags
    empty_internal <= '1' when fill_count_internal = 0 else '0';
    almost_empty <= '1' when fill_count_internal <= 1 else '0';
    full_internal <= '1' when fill_count_internal >= depth - 1 else '0';
    almost_full <= '1' when fill_count_internal >= depth - 2 else '0';
 
    -- Update the head pointer in write
    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                head <= 0;
            else
                if write_enable = '1' and full_internal = '0' then
                    incr(head);
                end if;
            end if;
        end if;
    end process;
 
    -- Update the tail pointer on read and pulse valid
    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                tail <= 0;
                read_valid <= '0';
            else
                read_valid <= '0';
                if read_enable = '1' and empty_internal = '0' then
                    incr(tail);
                    read_valid <= '1';
                end if;
            end if;
        end if;
    end process;
 
    -- Write to and read from the RAM
    process (clk) begin
        if rising_edge(clk) then
            ram(head) <= write_data;
            read_data <= ram(tail);
        end if;
    end process;
 
    -- Update the fill count
    process (head, tail) begin
        if head < tail then
            fill_count_internal <= head - tail + depth;
        else
            fill_count_internal <= head - tail;
        end if;
    end process;
end Behavioral;