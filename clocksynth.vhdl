
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity clocksynth is
    port (
        CLK_100MHz : in  std_logic; -- 100.0 MHz
        CLK_MAIN   : out std_logic; --  60.0 MHz
        CLK_VGA    : out std_logic  -- 148.5 MHz
    );
end entity clocksynth;

architecture arch of clocksynth is

signal MMCM_feedback_clock : std_logic;

begin

    -- Synthesize 148.5 MHz from 100 MHz, via 742.5 MHz VCO frequency.
    MMCM_VGA : MMCME2_BASE
        generic map (
            BANDWIDTH          => "OPTIMIZED",    -- Jitter programming (OPTIMIZED, HIGH, LOW)
            CLKFBOUT_MULT_F    => 37.125,         -- Multiply value for all CLKOUT (2.000-64.000). 100 MHz * (53/5) == 1060 MHz.
            DIVCLK_DIVIDE      => 5,              -- Master division value (1-106)
            --
            CLKFBOUT_PHASE     => 0.0,            -- Phase offset in degrees of CLKFB (-360.000-360.000).
            CLKIN1_PERIOD      => 1000.0 / 100.0, -- Input clock period in ns, to ps resolution. 10.000 ns corresponds to 100 MHz.
            -- Dividers for each CLKOUT (1.000-128.000 for CLKOUT0, 1-128 for others).
            CLKOUT0_DIVIDE_F   => 12.375,      -- CLK_MAIN
            CLKOUT1_DIVIDE     => 5,           -- CLK_VGA
            CLKOUT2_DIVIDE     => 1,           -- (unused)
            CLKOUT3_DIVIDE     => 1,           -- (unused)
            CLKOUT4_DIVIDE     => 1,           -- (unused)
            CLKOUT5_DIVIDE     => 1,           -- (unused)
            CLKOUT6_DIVIDE     => 1,           -- (unused)
            -- Duty cycle for each CLKOUT (0.01-0.99).
            CLKOUT0_DUTY_CYCLE => 0.5,         -- CLK_MAIN
            CLKOUT1_DUTY_CYCLE => 0.5,         -- CLK_VGA
            CLKOUT2_DUTY_CYCLE => 0.5,         -- (unused)
            CLKOUT3_DUTY_CYCLE => 0.5,         -- (unused)
            CLKOUT4_DUTY_CYCLE => 0.5,         -- (unused)
            CLKOUT5_DUTY_CYCLE => 0.5,         -- (unused)
            CLKOUT6_DUTY_CYCLE => 0.5,         -- (unused)
            -- Phase offset for each CLKOUT (-360.000-360.000).
            CLKOUT0_PHASE      =>  0.0,        -- CLK_MAIN
            CLKOUT1_PHASE      =>  0.0,        -- CLK_VGA
            CLKOUT2_PHASE      =>  0.0,        -- (unused)
            CLKOUT3_PHASE      =>  0.0,        -- (unused)
            CLKOUT4_PHASE      =>  0.0,        -- (unused)
            CLKOUT5_PHASE      =>  0.0,        -- (unused)
            CLKOUT6_PHASE      =>  0.0,        -- (unused)
            --
            CLKOUT4_CASCADE    => false,       -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
            REF_JITTER1        => 0.0,         -- Reference input jitter in UI (0.000-0.999).
            STARTUP_WAIT       => true         -- Delays DONE until MMCM is locked (FALSE, TRUE)
        )
        port map (
            -- MMCM clock input
            CLKIN1    => CLK_100MHz,                 -- Clock input (100 MHz XTAL)
            -- MMCM clock output
            CLKOUT0   => CLK_MAIN,                   -- CLK_MAIN
            CLKOUT0B  => open,                       -- (unused)
            CLKOUT1   => CLK_VGA,                    -- CLK_VGA
            CLKOUT1B  => open,                       -- (unused)
            CLKOUT2   => open,                       -- (unused)
            CLKOUT2B  => open,                       -- (unused)
            CLKOUT3   => open,                       -- (unused)
            CLKOUT3B  => open,                       -- (unused)
            CLKOUT4   => open,                       -- (unused)
            CLKOUT5   => open,                       -- (unused)
            CLKOUT6   => open,                       -- (unused)
            -- MMCM feedback clock
            CLKFBOUT  => MMCM_feedback_clock,        -- Feedback clock, output
            CLKFBOUTB => open,                       -- (unused)
            CLKFBIN   => MMCM_feedback_clock,        -- Feedback clock, input
            -- MMCM control
            PWRDWN    => '0',                        -- Power-down
            RST       => '0',                        -- Reset
            -- MMCM status
            LOCKED    => open                        -- Lock indicator
    );

end architecture arch;
