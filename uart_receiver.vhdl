library ieee;

use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

entity uart_receiver is
    port (
        PORT_CLK        : in  std_logic;
        PORT_RESET      : in  std_logic;
        --
        PORT_DIVIDER    : in std_logic_vector(31 downto 0);
        --
        PORT_DATA       : out std_logic_vector(7 downto 0);
        PORT_DATA_VALID : out std_logic;
        PORT_DATA_READY : in  std_logic;
        --
        PORT_UART_RX    : in  std_logic
    );
end entity uart_receiver;

architecture arch of uart_receiver is

type FsmState is (B0, B1, B2, B3, B4, B5, B6, B7, STOP);

type StateType is
    record
        st         : FsmState;
        counter    : unsigned(31 downto 0);
        data       : std_logic_vector(7 downto 0);
        data_valid : std_logic;
    end record StateType;

constant reset_state: StateType := (
        st         => STOP,
        counter    => to_unsigned(0, 32),
        data       => "--------",
        data_valid => '0'
    );

type CombinatorialSignals is
    record
        next_state : StateType;
    end record CombinatorialSignals;

function UpdateCombinatorialSignals(
            current_state : in StateType;
            DIVIDER       : in std_logic_vector(31 downto 0);
            RESET         : std_logic;
            DATA_READY    : std_logic;
            DATA          : std_logic_vector(7 downto 0);
            UART_RX       : std_logic) return CombinatorialSignals is

variable combinatorial: CombinatorialSignals;

variable period_minus_one      : unsigned(31 downto 0);
variable long_period_minus_one : unsigned(31 downto 0);

begin

    period_minus_one      := to_unsigned(to_integer(unsigned(PORT_DIVIDER))         - 1, 32);
    long_period_minus_one := to_unsigned(to_integer(unsigned(PORT_DIVIDER)) * 3 / 2 - 1, 32);

    combinatorial := CombinatorialSignals'(
        next_state => current_state
    );

    if RESET = '1' then
        combinatorial.next_state := reset_state;
    else

        if combinatorial.next_state.data_valid = '1' and DATA_READY = '1' then
            combinatorial.next_state.data  := "--------";
            combinatorial.next_state.data_valid := '0';
        end if;

        if combinatorial.next_state.counter = 0 then
            case combinatorial.next_state.st is
                when B0    => combinatorial.next_state.st := B1  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(0) := UART_RX; combinatorial.next_state.data_valid := '0'; -- drop valid data if still present ("overrun")
                when B1    => combinatorial.next_state.st := B2  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(1) := UART_RX;
                when B2    => combinatorial.next_state.st := B3  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(2) := UART_RX;
                when B3    => combinatorial.next_state.st := B4  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(3) := UART_RX;
                when B4    => combinatorial.next_state.st := B5  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(4) := UART_RX;
                when B5    => combinatorial.next_state.st := B6  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(5) := UART_RX;
                when B6    => combinatorial.next_state.st := B7  ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(6) := UART_RX;
                when B7    => combinatorial.next_state.st := STOP; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.data(7) := UART_RX; combinatorial.next_state.data_valid := '1';
                when STOP  => if UART_RX = '0' then
                                  -- Start bit detected!
                                  combinatorial.next_state.st := B0; combinatorial.next_state.counter := long_period_minus_one; -- wait until we're halfway the first data bit.
                              end if;
            end case;
        else
            combinatorial.next_state.counter := combinatorial.next_state.counter - 1;
        end if;
    end if;

    return combinatorial;

end function UpdateCombinatorialSignals;

signal current_state : StateType := reset_state;
signal combinatorial : CombinatorialSignals;

begin

    combinatorial <= UpdateCombinatorialSignals(current_state, PORT_DIVIDER, PORT_RESET, PORT_DATA_VALID, PORT_DATA, PORT_UART_RX);

    current_state <= combinatorial.next_state when rising_edge(PORT_CLK);

    PORT_DATA       <= current_state.data;
    PORT_DATA_VALID <= current_state.data_valid;

end architecture arch;
