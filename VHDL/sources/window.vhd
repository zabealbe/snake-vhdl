library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.world_pkg.all;

entity window is
    generic(
        bounds: t_box
    );
    port (
        pos: in t_pos;
        enable_display: out std_logic
    );
end window;

architecture Behavioral of window is
begin
    enable_display <= 
        '1' when
            pos.x >= bounds.tl.x and pos.y >= bounds.tl.y and  -- Check if pos is after  top    left  corner
            pos.x <= bounds.br.x and pos.y <= bounds.br.y      -- Check if pos is before bottom right corner
        else '0';
end Behavioral;
