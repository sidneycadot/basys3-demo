
library ieee;
use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

entity toplevel is
    port (
        XTAL_CLK      : in    std_logic;
        --
        SW_ASYNC      : in    std_logic_vector(15 downto 0);
        BTN_C_ASYNC   : in    std_logic;
        BTN_U_ASYNC   : in    std_logic;
        BTN_L_ASYNC   : in    std_logic;
        BTN_R_ASYNC   : in    std_logic;
        BTN_D_ASYNC   : in    std_logic;
        --
        LED           : out   std_logic_vector(15 downto 0);
        SSEG_SEGMENT  : out   std_logic_vector(7 downto 0);
        SSEG_ANODE    : out   std_logic_vector(3 downto 0);
        --
        PMOD_A_p1     : out   std_logic;
        PMOD_A_p2     : out   std_logic;
        PMOD_A_p3     : out   std_logic;
        PMOD_A_p4     : out   std_logic;
        PMOD_A_p7     : out   std_logic;
        PMOD_A_p8     : out   std_logic;
        PMOD_A_p9     : out   std_logic;
        PMOD_A_p10    : out   std_logic;
        --
        PMOD_B_p1     : out   std_logic;
        PMOD_B_p2     : out   std_logic;
        PMOD_B_p3     : out   std_logic;
        PMOD_B_p4     : out   std_logic;
        PMOD_B_p7     : out   std_logic;
        PMOD_B_p8     : out   std_logic;
        PMOD_B_p9     : out   std_logic;
        PMOD_B_p10    : out   std_logic;
        --
        PMOD_C_p1     : out   std_logic;
        PMOD_C_p2     : out   std_logic;
        PMOD_C_p3     : out   std_logic;
        PMOD_C_p4     : out   std_logic;
        PMOD_C_p7     : out   std_logic;
        PMOD_C_p8     : out   std_logic;
        PMOD_C_p9     : out   std_logic;
        PMOD_C_p10    : out   std_logic;
        --
        PMOD_X_p1     : out   std_logic;
        PMOD_X_p2     : out   std_logic;
        PMOD_X_p3     : out   std_logic;
        PMOD_X_p4     : out   std_logic;
        PMOD_X_p7     : out   std_logic;
        PMOD_X_p8     : out   std_logic;
        PMOD_X_p9     : out   std_logic;
        PMOD_X_p10    : out   std_logic;
        --
        VGA_R         : out   std_logic_vector(3 downto 0);
        VGA_G         : out   std_logic_vector(3 downto 0);
        VGA_B         : out   std_logic_vector(3 downto 0);
        VGA_VSYNC     : out   std_logic;
        VGA_HSYNC     : out   std_logic;
        --
        UART_RX_ASYNC : in    std_logic;
        UART_TX       : out   std_logic;
        --
        PS2_CLK       : inout std_logic;
        PS2_DATA      : inout std_logic;
        --
        QSPI_DATA     : inout std_logic_vector(3 downto 0);
        QSPI_CSn      : out   std_logic
    );
end entity toplevel;


architecture arch of toplevel is

constant CLK_MAIN_FREQ : real :=  60.0e6;
constant CLK_VGA_FREQ  : real := 148.5e6;

constant UART_BAUDRATE : real := 115200.0;
constant UART_DIVIDER : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(natural(CLK_MAIN_FREQ / UART_BAUDRATE), 32));

signal CLK_MAIN : std_logic; -- Clock for everything except VGA (60 MHz).
signal CLK_VGA  : std_logic; -- Clock for 1920x1080p timing (148.5 MHz).

signal RESET_MAIN : std_logic;
signal RESET_VGA  : std_logic;

-- Signals for connecting the seven-segment display to the seven-segment counter.
signal D3, D2, D1, D0 : std_logic_vector(3 downto 0);
signal D3_EN, D2_EN, D1_EN, D0_EN : std_logic;
signal D3_LDOT, D2_LDOT, D1_LDOT, D0_LDOT : std_logic;

-- Signals for the UART_RX -> ROT13 -> UART_TX chain

signal UART_RX              : std_logic;
signal UART_RX_BYTE_VALID   : std_logic;
signal UART_RX_BYTE         : std_logic_vector(7 downto 0);
signal ROT13_IN_READY       : std_logic;
signal ROT13_OUT_BYTE       : std_logic_vector(7 downto 0);
signal ROT13_OUT_BYTE_VALID : std_logic;
signal UART_TX_IN_READY     : std_logic;

begin

    clocksynth_instance : entity work.clocksynth
        port map (
            CLK_100MHz => XTAL_CLK,
            CLK_MAIN   => CLK_MAIN,
            CLK_VGA    => CLK_VGA
        );

    synchronize_reset_main :entity work.synchronizer
        port map (
            PORT_SRC_ASYNC => BTN_C_ASYNC,
            PORT_DST_CLK   => CLK_MAIN,
            PORT_DST_SYNC  => RESET_MAIN
        );

    synchronize_reset_vga :entity work.synchronizer
        port map (
            PORT_SRC_ASYNC => BTN_C_ASYNC,
            PORT_DST_CLK   => CLK_VGA,
            PORT_DST_SYNC  => RESET_VGA
        );

    LED <= SW_ASYNC xor ("00000000000" & BTN_C_ASYNC & BTN_U_ASYNC & BTN_L_ASYNC & BTN_R_ASYNC & BTN_D_ASYNC);

    seven_segment_display_driver : entity work.seven_segment_display
        port map (
            CLK             => CLK_MAIN,
            --
            PORT_RESET      => RESET_MAIN,
            --
            PORT_D3         => D3,
            PORT_D2         => D2,
            PORT_D1         => D1,
            PORT_D0         => D0,
            PORT_D3_EN      => D3_EN,
            PORT_D2_EN      => D2_EN,
            PORT_D1_EN      => D1_EN,
            PORT_D0_EN      => D0_EN,
            PORT_D3_LDOT    => D3_LDOT,
            PORT_D2_LDOT    => D2_LDOT,
            PORT_D1_LDOT    => D1_LDOT,
            PORT_D0_LDOT    => D0_LDOT,
            --
            PORT_SEG_C      => SSEG_SEGMENT,
            PORT_SEG_AN     => SSEG_ANODE
        );

    seven_segment_counter_instance : entity work.seven_segment_counter
        port map (
            CLK          => CLK_MAIN,
            PORT_RESET   => RESET_MAIN,
            --
            PORT_D3      => D3,
            PORT_D2      => D2,
            PORT_D1      => D1,
            PORT_D0      => D0,
            PORT_D3_EN   => D3_EN,
            PORT_D2_EN   => D2_EN,
            PORT_D1_EN   => D1_EN,
            PORT_D0_EN   => D0_EN,
            PORT_D3_LDOT => D3_LDOT,
            PORT_D2_LDOT => D2_LDOT,
            PORT_D1_LDOT => D1_LDOT,
            PORT_D0_LDOT => D0_LDOT
        );

    vga_driver : entity work.vga
        port map (
            CLK            => CLK_VGA,
            PORT_RESET     => RESET_VGA,
            PORT_VGA_R     => VGA_R,
            PORT_VGA_G     => VGA_G,
            PORT_VGA_B     => VGA_B,
            PORT_VGA_VSYNC => VGA_VSYNC,
            PORT_VGA_HSYNC => VGA_HSYNC
        );

    pmod_a_p1_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 11.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p1 );
    pmod_a_p2_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 12.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p2 );
    pmod_a_p3_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 13.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p3 );
    pmod_a_p4_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 14.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p4 );
    pmod_a_p7_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 15.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p7 );
    pmod_a_p8_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 16.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p8 );
    pmod_a_p9_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 17.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p9 );
    pmod_a_p10_fm : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 18.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_A_p10);

    pmod_b_p1_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 21.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p1 );
    pmod_b_p2_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 22.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p2 );
    pmod_b_p3_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 23.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p3 );
    pmod_b_p4_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 24.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p4 );
    pmod_b_p7_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 25.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p7 );
    pmod_b_p8_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 26.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p8 );
    pmod_b_p9_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 27.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p9 );
    pmod_b_p10_fm : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 28.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_B_p10);

    pmod_c_p1_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 31.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p1 );
    pmod_c_p2_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 32.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p2 );
    pmod_c_p3_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 33.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p3 );
    pmod_c_p4_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 34.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p4 );
    pmod_c_p7_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 35.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p7 );
    pmod_c_p8_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 36.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p8 );
    pmod_c_p9_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 37.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p9 );
    pmod_c_p10_fm : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 38.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_C_p10);

    pmod_x_p1_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 41.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p1 );
    pmod_x_p2_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 42.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p2 );
    pmod_x_p3_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 43.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p3 );
    pmod_x_p4_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 44.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p4 );
    pmod_x_p7_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 45.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p7 );
    pmod_x_p8_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 46.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p8 );
    pmod_x_p9_fm  : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 47.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p9 );
    pmod_x_p10_fm : entity work.frequency_maker generic map (num_counter_bits => 32, clk_frequency => CLK_MAIN_FREQ, target_frequency => 48.0e3, duty_cycle => 50.0) port map(CLK => CLK_MAIN, PORT_RESET => RESET_MAIN, PORT_OUTPUT => PMOD_X_p10);

    synchronize_uart_rx :entity work.synchronizer
        port map (
            PORT_SRC_ASYNC => UART_RX_ASYNC,
            PORT_DST_CLK   => CLK_MAIN,
            PORT_DST_SYNC  => UART_RX
        );

    uart_rx_driver : entity work.uart_receiver
        port map (
            PORT_CLK        => CLK_MAIN,
            PORT_RESET      => RESET_MAIN,
            --
            PORT_DIVIDER    => UART_DIVIDER,
            --
            PORT_DATA       => UART_RX_BYTE,
            PORT_DATA_VALID => UART_RX_BYTE_VALID, 
            PORT_DATA_READY => UART_TX_IN_READY,
            --
            PORT_UART_RX    => UART_RX
        );

    rot13_driver : entity work.rot13
        port map (
            CLK                 => CLK_MAIN,
            PORT_RESET          => RESET_MAIN,
            --
            PORT_BYTE_IN        => UART_RX_BYTE,
            PORT_BYTE_IN_VALID  => UART_RX_BYTE_VALID,
            PORT_BYTE_IN_READY  => ROT13_IN_READY,
            --
            PORT_BYTE_OUT       => ROT13_OUT_BYTE,
            PORT_BYTE_OUT_VALID => ROT13_OUT_BYTE_VALID,
            PORT_BYTE_OUT_READY => UART_TX_IN_READY
        );

    uart_tx_driver : entity work.uart_transmitter
        port map (
            PORT_CLK        => CLK_MAIN,
            PORT_RESET      => RESET_MAIN,
            --
            PORT_DIVIDER    => UART_DIVIDER,
            --
            PORT_DATA       => ROT13_OUT_BYTE,
            PORT_DATA_VALID => ROT13_OUT_BYTE_VALID, 
            PORT_DATA_READY => UART_TX_IN_READY,
            --
            PORT_UART_TX    => UART_TX
        );

    QSPI_DATA <= "ZZZZ";
    QSPI_CSn  <= '1';

    PS2_CLK  <= 'Z';
    PS2_DATA <= 'Z';

end architecture arch;
