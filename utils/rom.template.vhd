library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.graphics_pkg.all;

entity $name is
port (
    tile_index: in integer range 0 to $tile_count - 1;
    tile_offx: in t_tile_offx;
    tile_offy: in t_tile_offy;
    data: out std_logic_vector($data_width - 1 downto 0)
);
end $name;

architecture Behavioral of $name is
    type t_rom0 is array (0 to $tile_width - 1)  of std_logic_vector($data_width - 1 downto 0);
    type t_rom1 is array (0 to $tile_height - 1) of t_rom0;
    type t_rom  is array (0 to $tile_count - 1) of t_rom1;
    signal rom: t_rom := ($rom);
begin
    data <= rom(tile_index)(to_integer(tile_offy))(to_integer(tile_offx));
end Behavioral; 