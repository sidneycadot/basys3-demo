library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

entity synchronizer is
    port (
        PORT_SRC_ASYNC : in std_logic;
        PORT_DST_CLK   : in std_logic;
        PORT_DST_SYNC  : out std_logic
    );
end entity synchronizer;


architecture arch of synchronizer is
begin
    
    xpm_cdc_single_instance : xpm_cdc_single
        generic map (
            DEST_SYNC_FF   => 2,
            INIT_SYNC_FF   => 0,
            SIM_ASSERT_CHK => 0,
            SRC_INPUT_REG  => 0
        )
        port map (
            SRC_CLK  => '0',
            SRC_IN   => PORT_SRC_ASYNC,
            DEST_CLK => PORT_DST_CLK,
            DEST_OUT => PORT_DST_SYNC
        );

end architecture arch;
